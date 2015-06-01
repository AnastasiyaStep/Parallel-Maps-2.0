//
//  MapTypesViewController.m
//  Parallel Maps
//
//  Created by Anastasiya on 3/24/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import "MapTypesViewController.h"

@interface MapTypesViewController() <UITableViewDelegate>

@end

@implementation MapTypesViewController

- (void)viewDidLoad {
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ViewController *mainController = [self.storyboard instantiateViewControllerWithIdentifier:@"main"];
    
    if (indexPath.row == 3) {
        mapTypeTerrain = YES;
    }
    if (indexPath.row == 0) {
        mapTypeRegular = YES;
    }
    if (indexPath.row == 1) {
        mapTypeSatellite = YES;
    }
    if (indexPath.row == 2) {
        mapTypeHybrid = YES;
    }
    [self.navigationController pushViewController:mainController animated:YES];
}

- (IBAction)doneButtonClicked:(id)sender {
    ViewController *mainController = [self.storyboard instantiateViewControllerWithIdentifier:@"main"];
    [self.navigationController pushViewController:mainController animated:YES];
}

@end
