//
//  DirectionsViewController.m
//  Parallel Maps
//
//  Created by Anastasiya on 4/1/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import "DirectionsViewController.h"
#import "SWRevealViewController.h"

@implementation DirectionsViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}

@end
