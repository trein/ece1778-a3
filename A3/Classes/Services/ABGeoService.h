//
// Created by Guilherme M. Trein on 1/26/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ABGeoService : NSObject
+ (ABGeoService *)sharedInstance;

- (NSArray *)loadPictures;
@end