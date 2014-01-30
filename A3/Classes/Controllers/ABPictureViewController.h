//
//  Created by Guilherme M. Trein on 1/29/14.
//  Copyright (c) 2014 Ackbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ABGeoPicture.h"

@interface ABPictureViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) ABGeoPicture* picture;
@property (weak, nonatomic) UIViewController* parent;
@end
