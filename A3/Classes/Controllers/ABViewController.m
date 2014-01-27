//
// Created by Guilherme M. Trein on 1/26/14.
// Copyright (c) 2014 Ackbox. All rights reserved.
//

#import "ABViewController.h"
#import "ABConstants.h"
#import "SVProgressHUD.h"

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
                                          cancelButtonTitle:NSLocalizedString(@"kOK", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)showInfoMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kInfoMessageTitle", @"Information message")
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"kOK", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)handleSuccess:(NSNotification *)notification {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"kCompleteMessage", @"Complete")];
}

- (void)handleFailure:(NSNotification *)notification {
    [SVProgressHUD dismiss];
    [self showErrorMessage:notification.object];
}

@end