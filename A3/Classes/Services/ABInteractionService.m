//
// Created by Guilherme M. Trein on 1/26/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

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

#pragma mark -
#pragma mark Interaction Business Logic
- (void)saveImage:(UIImage *)photo {
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
        ABLog(@"[%@] Update latitude %+.6f, longitude %+.6f\n", self, newLocation.coordinate.latitude, newLocation.coordinate.longitude);
        self.currentLocation = newLocation;
    }
}

- (NSString *)description {
    return @"Interaction Service";
}
@end