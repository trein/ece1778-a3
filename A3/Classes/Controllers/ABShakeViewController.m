//
//  Created by Guilherme M. Trein on 1/26/14.
//  Copyright (c) 2014 Ackbox. All rights reserved.
//

#import "ABShakeViewController.h"
#import "SVProgressHUD.h"
#import "ABCameraManager.h"

@interface ABShakeViewController ()
@property (nonatomic, strong) ABCameraManager *cameraManager;
@end

@implementation ABShakeViewController

- (ABCameraManager *)cameraManager {
    if (_cameraManager == nil) {
        _cameraManager = [ABCameraManager new];
    }
    return _cameraManager;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        ABLog(@"[%@] Shake gesture recognized!", self);
        [SVProgressHUD showWithStatus:NSLocalizedString(@"kTakingPictureMessage", @"Taking picture...") maskType:SVProgressHUDMaskTypeBlack];
        [self performSelectorInBackground:@selector(interact) withObject:self];
    }
}

- (void)interact {
    [self.cameraManager takePictureUsingController:self];
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

- (NSString *)description {
    return @"Shake View Controller";
}

@end