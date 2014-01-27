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
                                                            object:NSLocalizedString(@"kPhotoTakenMessage", @"Photo taken!.")];
    }
}

- (void)takePicture {
    AVCaptureDevice *frontalCamera;
    NSArray *allCameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];

// Find the frontal camera.
    for (int i = 0; i < allCameras.count; i++) {
        AVCaptureDevice *camera = [allCameras objectAtIndex:i];

        if (camera.position == AVCaptureDevicePositionFront) {
            frontalCamera = camera;
        }
    }

// If we did not find the camera then do not take picture.
    if (frontalCamera != nil ) {
        // Start the process of getting a picture.
        AVCaptureSession *session = [[AVCaptureSession alloc] init];

        // Setup instance of input with frontal camera and add to session.
        NSError *error;
        AVCaptureDeviceInput *input =
                [AVCaptureDeviceInput deviceInputWithDevice:frontalCamera error:&error];

        if (!error && [session canAddInput:input]) {
            // Add frontal camera to this session.
            [session addInput:input];

            // We need to capture still image.
            AVCaptureStillImageOutput *output = [[AVCaptureStillImageOutput alloc] init];

            // Captured image. settings.
            [output setOutputSettings:
                    [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil]];

            if ([session canAddOutput:output]) {
                [session addOutput:output];

                AVCaptureConnection *videoConnection = nil;
                for (AVCaptureConnection *connection in output.connections) {
                    for (AVCaptureInputPort *port in [connection inputPorts]) {
                        if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                            videoConnection = connection;
                            break;
                        }
                    }
                    if (videoConnection) {break;}
                }

                // Finally take the picture
                if (videoConnection) {
                    [session startRunning];
                    [output captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {

                        if (imageDataSampleBuffer != NULL) {
                            NSData *imageData = [AVCaptureStillImageOutput
                                    jpegStillImageNSDataRepresentation:imageDataSampleBuffer];

                            UIImage *photo = [[UIImage alloc] initWithData:imageData];

                            time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
                            NSString *photoFilename = [NSString stringWithFormat:@"picture_%ld", unixTime];
                            ABGeoDataStore *geoService = [ABGeoDataStore sharedInstance];
                            ABGeoPicture *geoPicture = [[ABGeoPicture alloc] initWithFilename:photoFilename
                                                                                     latitude:self.currentLocation.coordinate.latitude
                                                                                    longitude:self.currentLocation.coordinate.longitude];

                            [geoService addGeoPicture:geoPicture withAssociatedImage:photo];
                        }
                    }];
                }
            }
        }
    }
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