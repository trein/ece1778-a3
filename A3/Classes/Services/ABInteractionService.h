//
// Created by Guilherme M. Trein on 1/26/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface ABInteractionService : NSObject <CLLocationManagerDelegate>

+ (ABInteractionService *)sharedInstance;

- (void)startMonitoring;

- (void)saveImage:(UIImage *)photo;
@end