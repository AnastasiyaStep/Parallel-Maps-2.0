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
        //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void) loadView {
    panoView = [[GMSPanoramaView alloc] initWithFrame:CGRectZero];
    panoView.delegate = self;
    self.view = panoView;
    
    //NSString *streetLocation = [NSString stringWithFormat:@"%f, %f", pinCoordinate.latitude, pinCoordinate.longitude];
    //self.navigationItem.title = streetLocation;
    [self requestPanoramaNearCoordinate:pinCoordinate radius:100 callback:^(GMSPanorama *panorama, NSError *error) {
    }];
    [panoView moveNearCoordinate:CLLocationCoordinate2DMake(pinCoordinate.latitude, pinCoordinate.longitude) radius:1000];
}

- (void)requestPanoramaNearCoordinate:(CLLocationCoordinate2D) coordinate radius:(NSUInteger)radius callback:(GMSPanoramaCallback)callback {
    GMSPanoramaService *s = [[GMSPanoramaService alloc] init];
    [s requestPanoramaNearCoordinate:globalCoordinate callback:^(GMSPanorama *panorama, NSError *error) {
        if (error) {
            NSString *alertMessage = [NSString stringWithFormat:@"Unable to find street view in this place. Please, try another"];
            UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [servicesDisabledAlert show];
            SWRevealViewController *slide = [self.storyboard instantiateViewControllerWithIdentifier:@"appController"];
            [self presentViewController:slide animated:YES completion:nil];
        } else {
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.panoramaView = panoView;
            [panoView moveNearCoordinate:globalCoordinate];
        }
    }];
}

@end
