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
    ViewController *mainController = [self.storyboard instantiateViewControllerWithIdentifier:@"main"];
    
    if (indexPath.row == 3) {
        mapTypeTerrain = YES;
        NSLog(@"terrain");
    }
    if (indexPath.row == 0) {
        mapTypeRegular = YES;
        NSLog(@"regular");
    }
    if (indexPath.row == 1) {
        mapTypeSatellite = YES;
        NSLog(@"satellite");
    }
    if (indexPath.row == 2) {
        mapTypeHybrid = YES;
        NSLog(@"hybrid");
    }
    [self.navigationController pushViewController:mainController animated:YES];
}

- (IBAction)doneButtonClicked:(id)sender {
    ViewController *mainController = [self.storyboard instantiateViewControllerWithIdentifier:@"main"];
    [self.navigationController pushViewController:mainController animated:YES];
}

@end
