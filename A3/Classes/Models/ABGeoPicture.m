//
// Created by Guilherme M. Trein on 1/26/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import "ABGeoPicture.h"


// TODO
// Add details parameters.
// Show image when cell clicked.

@implementation ABGeoPicture

- (instancetype)initWithFilename:(NSString *)filename latitude:(double)latitude longitude:(double)longitude {
    self = [super init];
    if (self) {
        _imageName = filename;
        _latitude = [NSNumber numberWithDouble:latitude];
        _longitude = [NSNumber numberWithDouble:longitude];
    }
    return self;
}

- (NSString *)title {
    return [NSString stringWithFormat:@"Photo: %@", self.imageName];
}

- (NSString *)details {
    return [NSString stringWithFormat:@"Taken @ (%@ : %@)", [self.latitude stringValue], [self.longitude stringValue]];
}

#pragma mark -
#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.imageName forKey:@"imageName"];
    [encoder encodeObject:self.latitude forKey:@"latitude"];
    [encoder encodeObject:self.longitude forKey:@"longitude"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _imageName = [decoder decodeObjectForKey:@"imageName"];
        _latitude = [decoder decodeObjectForKey:@"latitude"];
        _longitude = [decoder decodeObjectForKey:@"longitude"];
    }
    return self;
}

- (NSString *)description {
    return [self title];
}

@end