//
//  SidebarViewController.m
//  Parallel Maps
//
//  Created by Anastasiya on 3/31/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "SettingsViewController.h"
#import "ViewController.h"

@interface SidebarViewController()

@end

@implementation SidebarViewController {
    NSArray *menuItems;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    menuItems = @[@"home", @"traffic", @"syncronisation", @"3DView", @"directions", @"settings", @"streetView", @"regular"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

/*- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return menuItems.count;
}*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController *)segue.destinationViewController;
    destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
    
    regionSave = YES;
    
    if ([segue.identifier isEqualToString:@"syncSegue"]) {
        //UINavigationController *navController = segue.destinationViewController;
        if (syncMode == YES) {
            NSString *msg1 = @"Turn off the synchronisation of maps?";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Synchronisation" message:msg1 delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            alert.tag = 1;
            [alert show];
        }
        else {
            NSString *msg2 = @"Turn on the synchronisation of maps?";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Synchronisation" message:msg2 delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            alert.tag = 3;
            [alert show];
        }
    }
    
    if ([segue.identifier isEqualToString:@"showTraffic"]) {
        UIAlertView *alertTraffic = [[UIAlertView alloc] initWithTitle:@"Traffic mode" message:@"Enable?\n Only on Google Maps" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertTraffic.tag = 2;
        [alertTraffic show];
    }
    
    if ([segue.identifier isEqualToString:@"3dViewSegue"]) {
        UIAlertView *alertDView = [[UIAlertView alloc] initWithTitle:@"3D view mode" message:@"Enable 3D view mode?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertDView.tag = 4;
        [alertDView show];
    }
    
    if ([segue.identifier isEqualToString:@"regularView"]) {
        mapTypeRegular = YES;
        mapTypeHybrid = NO;
        mapTypeSatellite = NO;
        mapTypeTerrain = NO;
        regionSave = YES;
    }
    
    if ([segue.identifier isEqualToString:@"hybridView"]) {
        mapTypeHybrid = YES;
        mapTypeSatellite = NO;
        mapTypeRegular = NO;
        mapTypeTerrain = NO;
        regionSave = YES;
    }
    
    if ([segue.identifier isEqualToString:@"satelliteView"]) {
        mapTypeSatellite = YES;
        mapTypeRegular = NO;
        mapTypeHybrid = NO;
        mapTypeTerrain = NO;
        regionSave = YES;
    }
    
    if ([segue.identifier isEqualToString:@"terrainView"]) {
        mapTypeTerrain = YES;
        mapTypeRegular = NO;
        mapTypeSatellite = NO;
        mapTypeHybrid = NO;
        regionSave = YES;
    }
}

- (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alert.tag == 1) {
        if (buttonIndex == 0) {
            syncMode = YES;
        }
        else if (buttonIndex == 1) {
            syncMode = NO;
        }
    }
    if (alert.tag == 2) {
        if (buttonIndex == 0) {
            trafficMode = NO;
        } else if (buttonIndex == 1) {
            trafficMode = YES;
        }
    }
    if (alert.tag == 3) {
        if (buttonIndex == 0) {
            syncMode = NO;
        }
        else if (buttonIndex == 1) {
            syncMode = YES;
        }
    }
    if (alert.tag == 4) {
        if (buttonIndex == 0) {
            DMode = NO;
        } else if (buttonIndex == 1) {
            DMode = YES;
        }
    }
}

@end

