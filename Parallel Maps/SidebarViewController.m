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

@synthesize trafficModeSwitch, dViewSwitch, syncSwitch;

- (void)viewWillAppear:(BOOL)animated {
    if (trafficMode == YES) {
        [self.trafficModeSwitch setOn:YES];
    } else {
        [self.trafficModeSwitch setOn:NO];
    }
    
    if (DMode == YES) {
        [self.dViewSwitch setOn:YES];
    } else {
        [self.dViewSwitch setOn:NO];
    }
    
    if (syncMode == YES) {
        [self.syncSwitch setOn:YES];
    } else {
        [self.syncSwitch setOn:NO];
    }
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
    

    if ([segue.identifier isEqualToString:@"regularView"]) {
        mapTypeRegular = YES;
        mapTypeHybrid = NO;
        mapTypeSatellite = NO;
        mapTypeTerrain = NO;
    }
    
    if ([segue.identifier isEqualToString:@"hybridView"]) {
        mapTypeHybrid = YES;
        mapTypeSatellite = NO;
        mapTypeRegular = NO;
        mapTypeTerrain = NO;
    }
    
    if ([segue.identifier isEqualToString:@"satelliteView"]) {
        mapTypeSatellite = YES;
        mapTypeRegular = NO;
        mapTypeHybrid = NO;
        mapTypeTerrain = NO;
    }
    
    if ([segue.identifier isEqualToString:@"terrainView"]) {
        mapTypeTerrain = YES;
        mapTypeRegular = NO;
        mapTypeSatellite = NO;
        mapTypeHybrid = NO;
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
}

- (IBAction)trafficModeSwitch:(id)sender {
    if ([sender isOn]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TrafficOnNotification" object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TrafficOffNotification" object:nil];
    }
}

- (IBAction)dViewModeSwitch:(id)sender {
    if ([sender isOn]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"3dViewOn" object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"3dViewOff" object:nil];
    }
}

- (IBAction)synchronisationModeSwitch:(id)sender {
    if ([sender isOn]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"syncOn" object:nil];
        syncMode = YES;
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"syncOff" object:nil];
        syncMode = NO;
    }
}

@end

