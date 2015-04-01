//
//  StreetViewController.m
//  Parallel Maps
//
//  Created by Anastasiya on 4/1/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import "StreetViewController.h"
#import "SWRevealViewController.h"

@implementation StreetViewController {
    GMSPanoramaView *panoView;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void) loadView {
    panoView = [[GMSPanoramaView alloc] initWithFrame:CGRectZero];
    self.view = panoView;
    [panoView moveNearCoordinate:CLLocationCoordinate2DMake(-33.732, 150.312)];
}

@end
