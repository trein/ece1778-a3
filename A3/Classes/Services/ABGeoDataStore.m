//
// Created by Guilherme M. Trein on 1/26/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import "ABGeoDataStore.h"
#import "ABGeoPicture.h"
#import "ABConstants.h"


@interface ABGeoDataStore ()
@property(nonatomic, strong) NSMutableArray *pictures;
@end

@implementation ABGeoDataStore

+ (ABGeoDataStore *)sharedInstance {
    static ABGeoDataStore *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.pictures = nil;
    }
    return self;
}

- (NSMutableArray *)pictures {
    if (_pictures == nil) {
        NSMutableArray *storedArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self createPathForFile:kDataFile]];
        if (storedArray == nil) {
            _pictures = [NSMutableArray new];
        } else {
            _pictures = storedArray;
        }
    }
    return _pictures;
}

- (NSArray *)storedPictures {
    return [NSArray arrayWithArray:self.pictures];
}

- (void)addGeoPicture:(ABGeoPicture *)picture withAssociatedImage:(UIImage *)image {
    [self saveImage:image withName:picture.imageName];
    [self saveGeoPicture:picture];
}

- (void)saveGeoPicture:(ABGeoPicture *)picture {
    NSLog(@"[%@] Saving geo picture %@ into file system", self, picture);
    [self.pictures addObject:picture];

    if (![NSKeyedArchiver archiveRootObject:self.pictures toFile:[self createPathForFile:kDataFile]]) {
        NSLog(@"[%@] Error saving geo picture %@ into file system", self, picture);
    }
}

- (void)saveImage:(UIImage *)image withName:(NSString *)name {
    NSLog(@"[%@] Saving image %@ into file system", self, name);
    if (![UIImagePNGRepresentation(image) writeToFile:[self createPathForFile:name] atomically:YES]) {
        NSLog(@"[%@] Error saving image %@ into file system", self, name);
    }
}

- (UIImage *)loadImage:(NSString *)name {
    NSLog(@"[%@] Loading image %@ form file system", self, name);
    return [UIImage imageWithContentsOfFile:[self createPathForFile:name]];
}

- (NSString *)createPathForFile:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
}

- (NSString *)description {
    return @"Geo Service";
}

@end