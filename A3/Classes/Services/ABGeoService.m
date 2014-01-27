//
// Created by Guilherme M. Trein on 1/26/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import "ABGeoService.h"


@implementation ABGeoService

+ (ABGeoService *)sharedInstance {
    static ABGeoService *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (NSArray *)loadPictures {
    return nil;
}
@end