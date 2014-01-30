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

- (void)deleteGeoPicture:(ABGeoPicture *)picture {
    ABLog(@"[%@] Deleting geo picture %@ from file system", self, picture);
    [self.pictures removeObject:picture];
    [self deleteImageWithName:picture.imageName];
    if (![NSKeyedArchiver archiveRootObject:self.pictures toFile:[self createPathForFile:kDataFile]]) {
        ABLog(@"[%@] Error deleting geo picture %@ from file system", self, picture);
    }
}

- (void)addGeoPicture:(ABGeoPicture *)picture withAssociatedImage:(UIImage *)image {
    [self saveImage:image withName:picture.imageName];
    [self saveGeoPicture:picture];
}

- (void)saveGeoPicture:(ABGeoPicture *)picture {
    ABLog(@"[%@] Saving geo picture %@ into file system", self, picture);
    [self.pictures addObject:picture];
    NSArray *immutableCopy = [NSArray arrayWithArray:self.pictures];
    if (![NSKeyedArchiver archiveRootObject:immutableCopy toFile:[self createPathForFile:kDataFile]]) {
        ABLog(@"[%@] Error saving geo picture %@ into file system", self, picture);
    }
}

- (void)saveImage:(UIImage *)image withName:(NSString *)name {
    ABLog(@"[%@] Saving image %@ into file system", self, name);
    if (![UIImagePNGRepresentation(image) writeToFile:[self createPathForFile:name] atomically:YES]) {
        ABLog(@"[%@] Error saving image %@ into file system", self, name);
    }
}

- (void)deleteImageWithName:(NSString *)name {
    ABLog(@"[%@] Deleting image %@ from file system", self, name);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if (![fileManager removeItemAtPath:[self createPathForFile:name] error:&error]) {
        ABLog(@"[%@] Error deleting image %@ from file system", self, name);
    }
}

- (UIImage *)loadImage:(NSString *)name {
    ABLog(@"[%@] Loading image %@ form file system", self, name);
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