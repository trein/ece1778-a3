//
// Created by Guilherme M. Trein on 1/26/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import "ABInteractionService.h"
#import "ABConstants.h"


@interface ABInteractionService ()
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) CMMotionManager *motionManager;
@property(strong) CLLocation *currentLocationCoordinates;
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
    [self startMotionManager];
    [self startLocationManager];
}

- (void)startMotionManager {
    self.motionManager = [CMMotionManager new];
    self.motionManager.accelerometerUpdateInterval = kAccelerometerUpdateInterval;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                 [self accelerometerDidAccelerate:accelerometerData withError:error];
                                             }];
}

- (void)startLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

- (void)accelerometerDidAccelerate:(CMAccelerometerData *)acceleration withError:(NSError *)error {
    NSLog(@"[%@] Received accelerometer update %@.", self, acceleration);

    if (error) {
        NSLog(@"%@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:kOperationFailure
                                                            object:NSLocalizedString(@"kErrorAccelerometerMessage", @"Error reading accelerometer data.")];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kOperationSuccess
                                                            object:NSLocalizedString(@"kPhotoTakenMessage", @"Photo taken!.")];
    }
}

- (void)interact {
    NSError *error = nil;
    if (error) {
        NSLog(@"%@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:kOperationFailure
                                                            object:NSLocalizedString(@"kErrorAccelerometerMessage", @"Error reading accelerometer data.")];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kOperationSuccess
                                                            object:NSLocalizedString(@"kPhotoTakenMessage", @"Photo taken!.")];
    }
}

//- (void)retrieveCurrentLocationAddress:(NSString *)tag {
//    CLLocation *gpsLocation = [self.locationManager location];
//    CLLocation *currentLocation = (gpsLocation) ? gpsLocation : [[CLLocation alloc] init];
//    NSLog(@"[%@] Current location coordinates: %@", self, currentLocation);
//
//    [[NMRequestDispatcher sharedInstance] requestAddress:currentLocation tag:tag];
//}

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
        self.currentLocationCoordinates = newLocation;
    }
}

- (NSString *)description {
    return @"Interaction Service";
}
@end