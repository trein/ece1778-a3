//
// Created by Guilherme M. Trein on 1/26/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ABViewController : UIViewController
- (void)handleSuccess:(NSNotification *)notification;
- (void)handleFailure:(NSNotification *)notification;
- (void)showInfoMessage:(NSString *)message;
- (void)showErrorMessage:(NSString *)message;
@end