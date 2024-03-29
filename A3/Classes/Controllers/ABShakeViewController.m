//
//  Created by Guilherme M. Trein on 1/26/14.
//  Copyright (c) 2014 Ackbox. All rights reserved.
//

#import "ABShakeViewController.h"
#import "SVProgressHUD.h"
#import "ABCameraManager.h"

@interface ABShakeViewController ()
@property(nonatomic, strong) ABCameraManager *cameraManager;
@property(nonatomic, strong) NSTimer *watchdogTimer;
@property(nonatomic) BOOL free;
@end

@implementation ABShakeViewController

- (ABCameraManager *)cameraManager {
    if (_cameraManager == nil) {
        _cameraManager = [[ABCameraManager alloc] initWithController:self];
    }
    return _cameraManager;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake && self.free && !self.watchdogTimer.isValid) {
        ABLog(@"[%@] Shake gesture recognized!", self);
        self.free = NO;
        [SVProgressHUD showWithStatus:NSLocalizedString(@"kTakingPictureMessage", @"Taking picture...") maskType:SVProgressHUDMaskTypeBlack];
        [self.cameraManager takePicture];
        self.watchdogTimer = [NSTimer scheduledTimerWithTimeInterval:8.0 target:self
                                       selector:@selector(watchdog) userInfo:nil repeats:YES];
    }
}

- (void)watchdog {
    if (!self.free) {
        ABLog(@"[%@] Watchdog awake!", self);
        self.free = YES;
        [SVProgressHUD dismiss];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self showErrorMessage:NSLocalizedString(@"kCameraNoFocus", @"Camera was unable to focus. Hold it steady!")];
    }
}

- (void)handleSuccess:(NSNotification *)notification {
    [super handleSuccess:notification];
    self.free = YES;
    [self.watchdogTimer invalidate];
}

- (void)handleFailure:(NSNotification *)notification {
    [super handleFailure:notification];
    self.free = YES;
    [self.watchdogTimer invalidate];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([self.mapView showsUserLocation]) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.location.coordinate, 500, 500);
        [self.mapView setRegion:region animated:YES];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.free = YES;
    [self.mapView.userLocation addObserver:self
                                forKeyPath:@"location"
                                   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                   context:NULL];

    self.mapView.showsUserLocation = YES;
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