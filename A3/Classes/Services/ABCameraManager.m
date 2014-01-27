//
// Created by Guilherme M. Trein on 1/27/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ABCameraManager.h"
#import "ABInteractionService.h"
#import "ABConstants.h"


@interface ABCameraManager ()
@property(nonatomic, strong) UIImagePickerController *picker;
@property(nonatomic, strong) AVCaptureStillImageOutput *cameraOutput;
@property(nonatomic, strong) AVCaptureSession *session;
@end

@implementation ABCameraManager

- (void)takePictureUsingController:(UIViewController *)controller {
    BOOL usePicker = YES;

    if (usePicker) {
        [self takePictureUsingImagePicker:controller];
    } else {
        [self takePictureUsingAVFramework];
    }
}

- (void)takePictureUsingImagePicker:(UIViewController *)controller {
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.picker.delegate = self;
    self.picker.allowsEditing = NO;
    self.picker.showsCameraControls = NO;
    [controller presentViewController:self.picker animated:YES completion:^{
        sleep(1);
        [self.picker takePicture];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (image == nil) {
        ABLog(@"[%@] Error trying to take a new photo", self);
        [self sendErrorNotification];
    } else {
        [self handleCaptureCallback:image];
    }
}

- (void)takePictureUsingAVFramework {
    NSError *error = nil;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

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
}

- (void)sendErrorNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kOperationFailure
                                                        object:NSLocalizedString(@"kErrorTakingPhotoMessage", @"Error taking a new photo.")];
}

- (void)handleCaptureCallback:(UIImage *)image {
    [[ABInteractionService sharedInstance] saveImage:image];
}
@end