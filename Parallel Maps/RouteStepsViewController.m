//
//  RouteStepsViewController.m
//  Parallel Maps
//
//  Created by Anastasiya on 4/17/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import "RouteStepsViewController.h"
#import "SWRevealViewController.h"

@interface RouteStepsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation RouteStepsViewController {
    CLLocationCoordinate2D _stepPoint;
}

@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.showsBuildings = YES;
    self.mapView.showsPointsOfInterest = YES;
    
    NSLog(@"%d", _selectedRoute.steps.count);
    MKRoute *rout = _selectedRoute;
    MKPolyline *line = [rout polyline];
    [self.mapView addOverlay:line];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    MKRouteStep *step = [_selectedRoute.steps objectAtIndex:0];
    
    [self moveMapCameraTo:step];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.selectedRoute.steps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NaviCell" forIndexPath:indexPath];
    MKRouteStep *step = [self.selectedRoute.steps objectAtIndex:indexPath.row];
    cell.textLabel.text = step.instructions;
    cell.detailTextLabel.text = step.notice;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MKRouteStep *step = [self.selectedRoute.steps objectAtIndex:indexPath.row];
    [self moveMapCameraTo:step];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - map

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
        renderer.lineWidth = 3.0f;
        renderer.strokeColor = [UIColor redColor];
        renderer.alpha = 0.5;
        return renderer;
    }
    return nil;
}

-(void)moveMapCameraTo:(MKRouteStep *)step {
    
    CLLocationCoordinate2D ground;
    CLLocationCoordinate2D eye;
    
    if([self.tableView indexPathsForSelectedRows]==nil) {
        ground = step.polyline.coordinate;
        eye = ground;
    }
    else {
        ground = step.polyline.coordinate;
        eye = _stepPoint;
    }
    
    MKMapCamera *myCamera = [MKMapCamera cameraLookingAtCenterCoordinate:ground fromEyeCoordinate:eye eyeAltitude:100];
    [self.mapView setCamera:myCamera animated:YES];
    
    _stepPoint = ground;
    
    MKDistanceFormatter *distanceFormat = [[MKDistanceFormatter alloc] init];
    NSString *distance = [distanceFormat stringFromDistance:step.distance];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = ground;
    annotation.title = distance;
    
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:YES];
}

- (IBAction)close:(id)sender {
    [self.delegate didRouteInfoViewControllerClosed:self];
    SWRevealViewController *slide = [self.storyboard instantiateViewControllerWithIdentifier:@"appController"];
    [self presentViewController:slide animated:YES completion:nil];
}

@end
