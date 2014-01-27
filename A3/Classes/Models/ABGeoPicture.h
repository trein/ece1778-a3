//
// Created by Guilherme M. Trein on 1/26/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ABGeoPicture : NSObject
@property(readonly, nonatomic, strong) NSString *imageName;
@property(readonly, nonatomic, strong) NSNumber *latitude;
@property(readonly, nonatomic, strong) NSNumber *longitude;

- (instancetype)initWithFilename:(NSString *)filename latitude:(double)latitude longitude:(double)longitude;

- (NSString *)title;

- (NSString *)details;


@end