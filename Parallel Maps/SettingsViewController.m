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

@synthesize trafficModeSwitch, indoorSwitch, shakeSwitch, showLatLotSwitch, synchronizationSwitch, dViewSwitch, sidebarButton;

- (void)viewDidAppear:(BOOL)animated {
    self.view.frame = self.view.superview.bounds;
    for (SettingsViewController *table in self.view.subviews) {
        if ([table isKindOfClass:[UILabel class]]) {
            [(UILabel *)table setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        }
    }
    //for (NSString *strFamilyName in [UIFont familyNames]) {
        //for (NSString *strFontName in [UIFont fontNamesForFamilyName:strFamilyName]) {
            //NSLog(@"%@", strFontName);
        //}
    //}
}

- (void)viewWillAppear:(BOOL)animated {
    //self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)]; 
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (IBAction)switchLatitude:(id)sender {
    //ViewController *mainController = [self.storyboard instantiateViewControllerWithIdentifier:@"main"];
    if (!showLatLotSwitch.on) showLatLot = NO;
    NSLog(@"show lat off");
}

- (IBAction)swicthSync:(id)sender {
    //ViewController *mainController = [self.storyboard instantiateViewControllerWithIdentifier:@"main"];
    if (!synchronizationSwitch.on) {
        syncMode = NO;
        NSLog(@"sync off");
    }
    else {
        syncMode = YES;
        NSLog(@"sync on");
    }
}

@end