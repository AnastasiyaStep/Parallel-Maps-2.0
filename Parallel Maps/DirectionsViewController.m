//
//  DirectionsViewController.m
//  Parallel Maps
//
//  Created by Anastasiya on 4/1/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import "DirectionsViewController.h"
#import "SWRevealViewController.h"
#import "ViewController.h"

@implementation DirectionsViewController

@synthesize from, to, success;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [from setDelegate:self];
    [to setDelegate:self];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}

#pragma mark - search work, get coordinates

- (IBAction)searchButtonClicked:(id)sender {
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:from.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count]) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *location = placemark.location;
            CLLocationCoordinate2D coordinate = location.coordinate;
            NSLog(@"coordinate1 = (%f, %f)", coordinate.latitude, coordinate.longitude);
            locationFrom = coordinate;
            
            success = YES;
            directions = YES;
        } else {
            NSLog(@"error to get direction label 1");
            
            NSString *alertMessage = [NSString stringWithFormat:@"Error of find start location. Please, try again."];
            UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [servicesDisabledAlert show];
            
            directions = NO;
            success = NO;
        }
    }];
    
    CLGeocoder *geocoder2 = [[CLGeocoder alloc] init];
    [geocoder2 geocodeAddressString:to.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count]) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *location = placemark.location;
            CLLocationCoordinate2D coordinate = location.coordinate;
            NSLog(@"coordinate = (%f, %f)", coordinate.latitude, coordinate.longitude);
            locationTo = coordinate;
            
            directions = YES;
            if (success == YES) [[NSNotificationCenter defaultCenter] postNotificationName:@"Directions" object:nil];
        } else {
            NSLog(@"error to get direction label 2");
            
            NSString *alertMessage = [NSString stringWithFormat:@"Error of find final location. Please, try again."];
            UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [servicesDisabledAlert show];
            
            directions = NO;
        }
    }];
    
    ViewController *mainController = [self.storyboard instantiateViewControllerWithIdentifier:@"main"];
    [self.navigationController pushViewController:mainController animated:YES];
}

#pragma mark - text field

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)segmentSwitch:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSUInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        NSLog(@"Driving");
        drivingMode = YES;
        walkingMode = NO;
    }
    else {
        NSLog(@"Walking");
        walkingMode = YES;
        drivingMode = NO;
    }
}

@end