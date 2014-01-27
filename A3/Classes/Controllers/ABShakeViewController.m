//
//  Created by Guilherme M. Trein on 1/26/14.
//  Copyright (c) 2014 Ackbox. All rights reserved.
//

#import "ABShakeViewController.h"
#import "ABInteractionService.h"
#import "SVProgressHUD.h"

@interface ABShakeViewController ()

@end

@implementation ABShakeViewController

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"[%@] Shake gesture recognized!", self);
        [SVProgressHUD showWithStatus:NSLocalizedString(@"kTakingPictureMessage", @"Taking picture...") maskType:SVProgressHUDMaskTypeBlack];
        [[ABInteractionService sharedInstance] interact];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

@end