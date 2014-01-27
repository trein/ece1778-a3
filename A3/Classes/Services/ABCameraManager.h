//
// Created by Guilherme M. Trein on 1/27/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ABCameraManager : NSObject <UIImagePickerControllerDelegate>

- (void)takePictureUsingController:(UIViewController *)controller;

@end