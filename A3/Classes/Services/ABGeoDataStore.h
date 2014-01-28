//
// Created by Guilherme M. Trein on 1/26/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABGeoPicture;

@interface ABGeoDataStore : NSObject

+ (ABGeoDataStore *)sharedInstance;

- (UIImage *)loadImage:(NSString *)name;

- (NSArray *)storedPictures;

- (void)addGeoPicture:(ABGeoPicture *)picture withAssociatedImage:(UIImage *)image;

- (void)deleteGeoPicture:(ABGeoPicture *)picture;

@end