//
//  SearchListViewController.m
//  Parallel Maps
//
//  Created by Anastasiya on 3/24/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import "SearchListViewController.h"
#import "ViewController.h"

#import <MapKit/MapKit.h>

@interface DetailSegue : UIStoryboardSegue
@end

@implementation DetailSegue

- (void)perform {
    SearchListViewController *sourceViewController = self.sourceViewController;
    ViewController *destinationViewController = self.destinationViewController;
    [sourceViewController.navigationController pushViewController:destinationViewController animated:YES];
}

@end


#pragma mark -

static NSString *kCellIdentifier = @"cellIdentifier";

@interface SearchListViewController ()

@property (strong, nonatomic) NSMutableArray *mapItems;
@property (strong, nonatomic) MKDirectionsResponse *response;
@property (strong, nonatomic) MKMapItem *mapItemFrom;
@property (strong, nonatomic) MKMapItem *mapItemTo;
@property (assign, nonatomic) int routeIndex;

@property (strong, nonatomic) MKRoute *selectedRoute;

@property (nonatomic, strong) ViewController *mapViewController;
@property (nonatomic, strong) DetailSegue *detailSegue;
@property (nonatomic, strong) DetailSegue *showAllSegue;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D userLocation;

//@property (nonatomic, assign) MKCoordinateRegion boundingRegion;

- (IBAction)showAll:(id)sender;

@end

@implementation SearchListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _mapItems = [NSMutableArray array];
    _routeIndex = 0;
    _searchBar.delegate = self;
    _tableView.delegate = self;
    
    /*self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];*/
    
    self.mapViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"main"];
    
    self.detailSegue = [[DetailSegue alloc] initWithIdentifier:@"showDetail" source:self destination:self.mapViewController];
    
    self.showAllSegue = [[DetailSegue alloc] initWithIdentifier:@"showAll" source:self destination:self.mapViewController];
    
    [self setGestureOnTableView];
    
    CGRect frame = self.tableView.frame;
    frame.size.height = self.tableView.contentSize.height;
    self.tableView.frame = frame;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - Search Job

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    NSString *causeStr = nil;
    
    if ([CLLocationManager locationServicesEnabled] == NO) {
        causeStr = @"device";
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        causeStr = @"app";
    }
    else {
        MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
        request.naturalLanguageQuery = searchBar.text;
        
        MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
        
        [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
            [_mapItems removeAllObjects];
            //[_mapView removeAnnotations:[_mapView annotations]];
            
            for(MKMapItem *item in response.mapItems) {
                MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                point.coordinate = item.placemark.coordinate;
                point.title = item.placemark.name;
                point.subtitle = item.phoneNumber;
                
                self.boundingRegion = response.boundingRegion;
                
                //[_mapView addAnnotation:point];
                [_mapItems addObject:item];
            }
            //[_mapView showAnnotations:[_mapView annotations] animated:YES];
            _mapItemFrom = _mapItemTo = nil;
            NSLog(@"search");
            
            [_tableView reloadData];
        }];
    }
    if (causeStr != nil) {
        NSString *alertMessage = [NSString stringWithFormat:@"You currently have disabled location services for this %@. Please turn on location services.", causeStr];
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services disabled" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [servicesDisabledAlert show];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

#pragma mark - TableView Job

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%lu", (unsigned long)[_mapItems count]);
    return [_mapItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    MKMapItem *item = [_mapItems objectAtIndex:indexPath.row];
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.placemark.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.mapViewController.boundingRegion = self.boundingRegion;
    
    NSIndexPath *selectedItem = [self.tableView indexPathForSelectedRow];

    //self.mapViewController.mapItemList = [NSArray arrayWithObjects:[self.mapItems objectAtIndex:selectedItem.row
                                                                    //]];
    MKMapItem *item = [self.mapItems objectAtIndex:indexPath.row];
    NSLog(@"table item selected");
    //for (MKPointAnnotation *annotation in self.mapViewController.mapKitView.annotations)
    
    pinCoordinate.latitude = item.placemark.coordinate.latitude;
    pinCoordinate.longitude = item.placemark.coordinate.longitude;
    
    searchSegue = YES;
    [self.detailSegue perform];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)setGestureOnTableView {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(execNavi:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [_tableView addGestureRecognizer:tapGestureRecognizer];
}

- (void)execNavi:(UILongPressGestureRecognizer *)gestureRecognizer {
    [self performSegueWithIdentifier:@"showNaviPage" sender:self];
}

#pragma mark - Map Job

#pragma mark - Route Job

- (void)findDirectionsFrom:(MKMapItem*)source
                        to:(MKMapItem*)destination
                routeIndex:(int)routeIndex {
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = source;
    request.destination = destination;
    request.requestsAlternateRoutes = YES;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if(!error) {
            _response = response;
            NSLog(@"route count %d", [response.routes count]);
            
            int routeNo = routeIndex % [response.routes count];
            MKRoute *route = response.routes[routeNo];
            _selectedRoute = route;
            
            for(MKRouteStep *step in route.steps) {
                NSLog(@"%@", step.instructions);
                NSLog(@"%@", step.notice);
            }
            
            MKDistanceFormatter *distanceFormat = [[MKDistanceFormatter alloc] init];
            NSString *distance = [distanceFormat stringFromDistance:route.distance];
            NSString *time = [NSString stringWithFormat:@"%.0lf", route.expectedTravelTime/60];
            NSLog(@"%@経由", route.name);
            NSLog(@"%@ - 約%@分で到着", distance, time);
            
            //[_mapView removeOverlays:[_mapView overlays]];
            //[_mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
            
            //_routeInfoLabel.text = [NSString stringWithFormat:@"%@経由で%@：約%@分で到着", route.name, distance, time];
        }
    }];
}

- (IBAction)showAll:(id)sender {
    self.mapViewController.boundingRegion = self.boundingRegion;
    self.mapViewController.mapItemList = self.mapItems;
    
    [self.showAllSegue perform];
}

@end