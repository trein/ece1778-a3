//
// Created by Guilherme M. Trein on 1/26/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ABInteractionService.h"
#import "ABGeoDataStore.h"
#import "ABGeoPicture.h"
#import "ABConstants.h"


@interface ABInteractionService ()
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) AVCaptureStillImageOutput *cameraOutput;
@property(nonatomic, strong) AVCaptureSession *session;
@property(strong) CLLocation *currentLocation;
@end

@implementation ABInteractionService


+ (ABInteractionService *)sharedInstance {
    static ABInteractionService *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (void)startMonitoring {
    [self startLocationManager];
}

- (void)startLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

- (void)interact {
    NSError *error = nil;
    [self takePicture];
    if (error) {
        NSLog(@"[%@] Error detected %@", self, error);
        [[NSNotificationCenter defaultCenter] postNotificationName:kOperationFailure
                                                            object:NSLocalizedString(@"kErrorAccelerometerMessage", @"Error reading accelerometer data.")];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kOperationSuccess
                                                            object:NSLocalizedString(@"kPhotoTakenMessage", @"Photo taken!")];
    }
}

- (void)takePicture {
    NSError *error = nil;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

    if (!input) {
        NSLog(@"[%@] Error trying to open camera: %@", self, error);
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

    NSLog(@"[%@] About to request a capture from: %@", self, self.cameraOutput);
    [self.cameraOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                   completionHandler:^(CMSampleBufferRef buffer, NSError *error) {
                                                       if (buffer != NULL) {
                                                           [self saveImage:buffer];
                                                       }
                                                   }];
}

- (void)saveImage:(CMSampleBufferRef)buffer {
    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:buffer];
    UIImage *photo = [[UIImage alloc] initWithData:imageData];

    time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
    NSString *photoFilename = [NSString stringWithFormat:@"picture_%ld", unixTime];

    ABGeoDataStore *geoService = [ABGeoDataStore sharedInstance];
    ABGeoPicture *geoPicture = [[ABGeoPicture alloc] initWithFilename:photoFilename
                                                             latitude:self.currentLocation.coordinate.latitude
                                                            longitude:self.currentLocation.coordinate.longitude];

    [geoService addGeoPicture:geoPicture withAssociatedImage:photo];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {

    // If it's a relatively recent event, turn off updates to save power
    NSDate *eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];

    if (abs(howRecent) < 5.0) {
        NSLog(@"[%@] Update latitude %+.6f, longitude %+.6f\n", self, newLocation.coordinate.latitude, newLocation.coordinate.longitude);
        self.currentLocation = newLocation;
    }
}

- (NSString *)description {
    return @"Interaction Service";
}
@end