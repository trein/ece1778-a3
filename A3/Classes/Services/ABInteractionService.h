//
// Created by Guilherme M. Trein on 1/26/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>


@interface ABInteractionService : NSObject <CLLocationManagerDelegate>

+ (ABInteractionService *)sharedInstance;
- (void)startMonitoring;

@end