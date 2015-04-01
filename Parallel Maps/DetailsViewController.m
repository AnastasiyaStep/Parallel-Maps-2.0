//
//  DetailsViewController.m
//  Parallel Maps
//
//  Created by Anastasiya on 3/20/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailsViewController.h"
#import "ViewController.h"
#import "SWRevealViewController.h"

@interface DetailsViewController()

@end

@implementation DetailsViewController

@synthesize mapView, addressLabel, zipCode;

- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
}

- (void) viewDidLoad {
    self.mapView.mapType = MKMapTypeSatellite;
    //ViewController *mapKitViewData = [[ViewController alloc] initWithNibName:@"DetailsViewController" bundle:nil];
    
    CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake(addressLat, addressLong);
    
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 2000, 2000)];
    [mapView setRegion:adjustedRegion animated:YES];
    
    addressLabel.text = address;
    //zipCode.text =
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (IBAction)backButton:(id)sender {
    ViewController *mainController = [self.storyboard instantiateViewControllerWithIdentifier:@"main"];
    [self.navigationController pushViewController:mainController animated:YES];
}

@end