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
        _cameraManager = [[ABCameraManager alloc] initWithController:self];
    }
    return _cameraManager;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        ABLog(@"[%@] Shake gesture recognized!", self);
        [SVProgressHUD showWithStatus:NSLocalizedString(@"kTakingPictureMessage", @"Taking picture...") maskType:SVProgressHUDMaskTypeBlack];
        [self.cameraManager takePicture];
    }
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