//
//  SearchListViewController.m
//  Parallel Maps
//
//  Created by Anastasiya on 3/24/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import "SearchListViewController.h"
#import "ViewController.h"
#import "SWRevealViewController.h"

#import <MapKit/MapKit.h>

@interface DetailSegue : UIStoryboardSegue
@end

@implementation DetailSegue

- (void)perform {
    SearchListViewController *sourceViewController = self.sourceViewController;
    ViewController *destinationViewController = self.destinationViewController;
    [sourceViewController.navigationController pushViewController:destinationViewController animated:YES];
    
    /*SearchListViewController *sourceViewController = self.sourceViewController;
    SWRevealViewController *destinationViewController = self.destinationViewController;
    [sourceViewController.navigationController pushViewController:destinationViewController animated:YES];*/

    /*SWRevealViewController *slide = [self.storyboard instantiateViewControllerWithIdentifier:@"appController"];
    [self presentViewController:slide animated:YES completion:nil];
     */
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
    
    self.mapViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"appController"];
    
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
            if (error != nil) {
                NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find places" message:errorStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            } else {
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
                
                self.viewAllButton.enabled = self.mapItems != nil ? YES : NO;
                
                [_tableView reloadData];
            }
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
    //self.mapViewController.boundingRegion = self.boundingRegion;
    
    NSIndexPath *selectedItem = [self.tableView indexPathForSelectedRow];

    self.mapViewController.mapItemList = [NSArray arrayWithObjects:[self.mapItems objectAtIndex:selectedItem.row], nil];
    
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

- (IBAction)showAll:(id)sender {
    //self.mapViewController.boundingRegion = self.boundingRegion;
    self.mapViewController.mapItemList = self.mapItems;
    
    searchSegue = YES;
    [self.showAllSegue perform];
}

- (IBAction)close:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:nil];
    SWRevealViewController *slide = [self.storyboard instantiateViewControllerWithIdentifier:@"appController"];
    [self presentViewController:slide animated:YES completion:nil];
}

@end