//
// Created by Guilherme M. Trein on 1/27/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ABCameraManager.h"
#import "ABInteractionService.h"
#import "ABConstants.h"
#import "UIImage+Resize.h"


@interface ABCameraManager ()
@property(nonatomic, weak) UIViewController *controller;

@property(nonatomic, strong) UIImagePickerController *picker;
@property(nonatomic, strong) AVCaptureStillImageOutput *cameraOutput;
@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureDevice *device;
@end

@implementation ABCameraManager

- (instancetype)initWithController:(UIViewController *)controller {
    self = [super init];
    if (self) {
        self.controller = controller;
    }
    return self;
}


- (void)takePicture {
    BOOL usePicker = YES;
    if (usePicker) {
        [self takePictureUsingImagePicker];
    } else {
        [self takePictureUsingAVFramework];
    }
}

- (void)takePictureUsingImagePicker {
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.picker.delegate = self;
    self.picker.allowsEditing = NO;
    self.picker.showsCameraControls = NO;
    [self.controller presentViewController:self.picker animated:YES completion:^{
        sleep(1);
        [self.picker takePicture];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.controller dismissViewControllerAnimated:YES completion:nil];

    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat height = 640.0f;
        CGFloat width = (height / originalImage.size.height) * originalImage.size.width;
        UIImage *image = [originalImage resizedImage:CGSizeMake(width, height) interpolationQuality:kCGInterpolationDefault];

        if (image == nil) {
            ABLog(@"[%@] Error trying to take a new photo", self);
            [self sendErrorNotification];
        } else {
            [self handleCaptureCallback:image];
        }
    });
}

- (void)takePictureUsingAVFramework {
    NSError *error = nil;
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];

    if (!input) {
        ABLog(@"[%@] Error trying to open camera: %@", self, error);
    }

    self.cameraOutput = [[AVCaptureStillImageOutput alloc] init];
    [self.cameraOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];

    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetMedium;
    [self.session addInput:input];
    [self.session addOutput:self.cameraOutput];
    [self.session startRunning];

    [self.device addObserver:self
                  forKeyPath:NSStringFromSelector(@selector(adjustingExposure))
                     options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                     context:NULL];
    [self.device addObserver:self
                  forKeyPath:NSStringFromSelector(@selector(adjustingWhiteBalance))
                     options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                     context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if ([keyPath isEqualToString:NSStringFromSelector(@selector(adjustingExposure))]
            || [keyPath isEqualToString:NSStringFromSelector(@selector(adjustingWhiteBalance))]) {
        BOOL stillAdjusting = [change objectForKey:NSKeyValueChangeNewKey];
        if (!stillAdjusting) {
            AVCaptureConnection *videoConnection = nil;
            for (AVCaptureConnection *connection in self.cameraOutput.connections) {
                for (AVCaptureInputPort *port in [connection inputPorts]) {
                    if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                        videoConnection = connection;
                        break;
                    }
                }
                if (videoConnection) {
                    break;
                }
            }

            ABLog(@"[%@] About to request a capture from: %@", self, self.cameraOutput);
            [self.cameraOutput
                    captureStillImageAsynchronouslyFromConnection:videoConnection
                                                completionHandler:^(CMSampleBufferRef buffer, NSError *error) {
                                                    if (buffer == NULL || error != nil) {
                                                        ABLog(@"[%@] Error trying to take a new photo", self);
                                                        [self sendErrorNotification];
                                                    } else {
                                                        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:buffer];
                                                        UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                        [self handleCaptureCallback:image];
                                                    }
                                                }];
            [self.device removeObserver:self forKeyPath:NSStringFromSelector(@selector(adjustingExposure))];
            [self.device removeObserver:self forKeyPath:NSStringFromSelector(@selector(adjustingWhiteBalance))];
        }
    }
}


- (void)sendErrorNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kOperationFailure
                                                        object:NSLocalizedString(@"kErrorTakingPhotoMessage", @"Error taking a new photo.")];
}

- (void)handleCaptureCallback:(UIImage *)image {
    [[ABInteractionService sharedInstance] saveImage:image];
}
@end