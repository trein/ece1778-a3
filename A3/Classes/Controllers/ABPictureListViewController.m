//
//  Created by Guilherme M. Trein on 1/26/14.
//  Copyright (c) 2014 Ackbox. All rights reserved.
//

#import "ABPictureListViewController.h"
#import "ABGeoPicture.h"
#import "ABGeoService.h"

static NSString *const kCellId = @"kCellId";

@interface ABPictureListViewController ()
@property (strong, nonatomic) NSArray *pictures;
@property (strong, nonatomic) ABGeoService *service;
@end

@implementation ABPictureListViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.service = [ABGeoService sharedInstance];
    }
    return self;
}

#pragma mark -
#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellId];
    }
    ABGeoPicture *picture = [self.pictures objectAtIndex:indexPath.row];

    cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.text = [picture title];

    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.text = [picture details];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pictures.count;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // display picture
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pictures = [self.service loadPictures];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end