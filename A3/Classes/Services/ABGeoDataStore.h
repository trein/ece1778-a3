//
// Created by Guilherme M. Trein on 1/26/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABGeoPicture;

@interface ABGeoDataStore : NSObject

+ (ABGeoDataStore *)sharedInstance;

- (NSArray *)storedPictures;

- (void)addGeoPicture:(ABGeoPicture *)picture withAssociatedImage:(UIImage *)image;

- (UIImage *)loadImage:(NSString *)name;
@end