//
//  Created by Guilherme M. Trein on 1/29/14.
//  Copyright (c) 2014 Ackbox. All rights reserved.
//

#import "ABPictureViewController.h"
#import "ABGeoDataStore.h"
#import "UIImage+Resize.h"

@interface ABPictureViewController ()

@end

@implementation ABPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CLLocationCoordinate2D coo = CLLocationCoordinate2DMake([self.picture.latitude doubleValue], [self.picture.longitude doubleValue]);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coo, 500, 500);
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = coo;
    point.title = [self.picture title];
    point.subtitle = [self.picture details];
    
    [self.mapView addAnnotation:point];
    [self.mapView setRegion:region animated:YES];

    UIImage *image = [[ABGeoDataStore sharedInstance] loadImage:self.picture.imageName];
    UITapGestureRecognizer *modalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissModalView)];
    [self.imageView addGestureRecognizer:modalTap];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.image = [image croppedImage:self.imageView.frame];
}

- (void)dismissModalView {
    [self.parent dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
