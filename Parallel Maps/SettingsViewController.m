//
//  SettingsViewController.m
//  Parallel Maps
//
//  Created by Anastasiya on 3/23/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import "SettingsViewController.h"
#import "SWRevealViewController.h"

@interface SettingsViewController()

@end

@implementation SettingsViewController

@synthesize sidebarButton, tableView, switchKmMiles, switchRouteOnTap, switchWalkDrive;

- (void)viewDidAppear:(BOOL)animated {
    self.view.frame = self.view.superview.bounds;
    for (SettingsViewController *table in self.view.subviews) {
        if ([table isKindOfClass:[UILabel class]]) {
            [(UILabel *)table setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        }
    }
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)viewWillAppear:(BOOL)animated {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)]; 
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    if (drivingMode == YES) {
        [self.switchWalkDrive setOn:YES];
    } else {
        [self.switchWalkDrive setOn:NO];
    }
    
    if (showKm == YES) {
        [self.switchKmMiles setOn:NO];
    } else {
        [self.switchKmMiles setOn:YES];
    }
    
    if (drawRoute == YES) {
        [self.switchRouteOnTap setOn:YES];
    } else {
        [self.switchRouteOnTap setOn:NO];
    }
}

- (IBAction)switchKmMiles:(id)sender {
    if ([sender isOn]) {
        showKm = NO;
    } else {
        showKm = YES;
    }
}

- (IBAction)switchRouteOnTap:(id)sender {
    if ([sender isOn]) {
        drawRoute = YES;
    } else {
        drawRoute = NO;
    }
}

- (IBAction)switchDrivingWalking:(id)sender {
    if ([sender isOn]) {
        drivingMode = YES;
        walkingMode = NO;
    } else {
        drivingMode = NO;
        walkingMode = YES;
    }
}

@end