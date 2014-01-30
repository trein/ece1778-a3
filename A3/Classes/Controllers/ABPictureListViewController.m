//
//  Created by Guilherme M. Trein on 1/26/14.
//  Copyright (c) 2014 Ackbox. All rights reserved.
//

#import "ABPictureListViewController.h"
#import "ABGeoPicture.h"
#import "ABGeoDataStore.h"
#import "ABPictureViewController.h"

static NSString *const kCellId = @"kCellId";

@interface ABPictureListViewController ()
@property(strong, nonatomic) ABGeoDataStore *dataStore;
@end

@implementation ABPictureListViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.dataStore = [ABGeoDataStore sharedInstance];
    }
    return self;
}

#pragma mark -
#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellId];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    ABGeoPicture *picture = [[self.dataStore storedPictures] objectAtIndex:indexPath.row];
    cell.textLabel.text = [picture title];
    cell.detailTextLabel.text = [picture details];
    cell.imageView.image = [self.dataStore loadImage:picture.imageName];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataStore storedPictures].count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ABGeoPicture *picture = [[self.dataStore storedPictures] objectAtIndex:indexPath.row];
        [self.dataStore deleteGeoPicture:picture];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
    [tableView endUpdates];
    [tableView reloadData];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ABGeoPicture *picture = [[self.dataStore storedPictures] objectAtIndex:indexPath.row];
    ABLog(@"[%@] Selected geo picture %@", self, picture);
    
    ABPictureViewController *modalController = [self.storyboard instantiateViewControllerWithIdentifier:@"kPictureViewController"];
    modalController.picture = picture;
    modalController.parent = self;

    [self presentViewController:modalController animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSString *)description {
    return @"Picture List View Controller";
}

@end