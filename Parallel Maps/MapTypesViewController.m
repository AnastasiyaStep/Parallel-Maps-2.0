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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"%d", indexPath.row);
    ViewController *mainController = [self.storyboard instantiateViewControllerWithIdentifier:@"main"];
    
    if (indexPath.row == 3) {
        mainController.mapTypeTerrain = YES;
    }
    if (indexPath.row == 0) {
        mainController.mapTypeRegular = YES;
    }
    if (indexPath.row == 1) {
        mainController.mapTypeSatellite = YES;
    }
    if (indexPath.row == 2) {
        mainController.mapTypeHybrid = YES;
    }
    [self.navigationController pushViewController:mainController animated:YES];
}

- (IBAction)doneButtonClicked:(id)sender {
    ViewController *mainController = [self.storyboard instantiateViewControllerWithIdentifier:@"main"];
    
    //mainController.mapTypeSatellite = YES;
    
    [self.navigationController pushViewController:mainController animated:YES];
}

@end
