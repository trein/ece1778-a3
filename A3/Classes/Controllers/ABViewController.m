//
// Created by Guilherme M. Trein on 1/26/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import "ABViewController.h"
#import "ABConstants.h"


@implementation ABViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailure:) name:kOperationFailure object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccess:) name:kOperationSuccess object:nil];
}

- (void)showErrorMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kErrorMessageTitle", @"Error message")
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)showInfoMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kInfoMessageTitle", @"Information message")
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)handleSuccess:(NSNotification *)notification {
    [self showInfoMessage:notification.object];
}

- (void)handleFailure:(NSNotification *)notification {
    [self showErrorMessage:notification.object];
}

@end