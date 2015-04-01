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

- (void) perform {
    SearchListViewController *sourceViewController = self.sourceViewController;
    ViewController *destinationViewController = self.destinationViewController;
    [sourceViewController.navigationController pushViewController:destinationViewController animated:YES];
}

@end

static NSString *kCellIdentifier = @"cellIdentifier";

@interface SearchListViewController()

@property (nonatomic, assign) MKCoordinateRegion boundingRegion;

@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *viewAllButton;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D userLocation;

@property (nonatomic, strong) DetailSegue *detailSegue;
@property (nonatomic, strong) DetailSegue *showAllSegue;
@property (nonatomic, strong) ViewController *mapViewController;

- (IBAction)showAll:(id)sender;

@end

#pragma mark -

@implementation SearchListViewController

/*- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // start by locating user's current position
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    // create and reuse for later the mapViewController
    self.mapViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"main"];
    
    // use our custom segues to the destination view controller is reused
    self.detailSegue = [[DetailSegue alloc] initWithIdentifier:@"showDetail"
                                                        source:self
                                                   destination:self.mapViewController];
    
    self.showAllSegue = [[DetailSegue alloc] initWithIdentifier:@"showAll"
                                                         source:self
                                                    destination:self.mapViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotate
{
    return YES;
}*/

/*- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskAllButUpsideDown;
}
 */

#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    MKMapItem *mapItem = [self.places objectAtIndex:indexPath.row];
    cell.textLabel.text = mapItem.name;
    
    return cell;
}

- (IBAction)showAll:(id)sender
{
    self.mapViewController.boundingRegion = self.boundingRegion;
    
    self.mapViewController.mapItemList = self.places;
    
    [self.showAllSegue perform];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.mapViewController.boundingRegion = self.boundingRegion;
    
    NSIndexPath *selectedItem = [self.tableView indexPathForSelectedRow];
    self.mapViewController.mapItemList = [NSArray arrayWithObject:[self.places objectAtIndex:selectedItem.row]];
    
    [self.detailSegue perform];
}


#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)startSearch:(NSString *)searchString
{
    if (self.localSearch.searching)
    {
        [self.localSearch cancel];
    }
    
    // confine the map search area to the user's current location
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = self.userLocation.latitude;
    newRegion.center.longitude = self.userLocation.longitude;
    
    // setup the area spanned by the map region:
    // we use the delta values to indicate the desired zoom level of the map,
    //      (smaller delta values corresponding to a higher zoom level)
    //
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    
    request.naturalLanguageQuery = searchString;
    request.region = newRegion;
    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error)
    {
        if (error != nil)
        {
            NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find places"
                                                            message:errorStr
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            self.places = [response mapItems];
            
            // used for later when setting the map's region in "prepareForSegue"
            self.boundingRegion = response.boundingRegion;
            
            self.viewAllButton.enabled = self.places != nil ? YES : NO;
            
            [self.tableView reloadData];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    if (self.localSearch != nil)
    {
        self.localSearch = nil;
    }
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [self.localSearch startWithCompletionHandler:completionHandler];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    // check to see if Location Services is enabled, there are two state possibilities:
    // 1) disabled for entire device, 2) disabled just for this app
    //
    NSString *causeStr = nil;
    /*
    // check whether location services are enabled on the device
    if ([CLLocationManager locationServicesEnabled] == NO)
    {
        causeStr = @"device";
    }
    // check the application’s explicit authorization status:
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        causeStr = @"app";
    }
    else
    {*/
        // we are good to go, start the search
        [self startSearch:searchBar.text];
    //}
    
    if (causeStr != nil)
    {
        NSString *alertMessage = [NSString stringWithFormat:@"You currently have location services disabled for this %@. Please refer to \"Settings\" app to turn on Location Services.", causeStr];
        
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                                        message:alertMessage
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // remember for later the user's current location
    self.userLocation = newLocation.coordinate;
    
    [manager stopUpdatingLocation]; // we only want one update
    
    manager.delegate = nil;         // we might be called again here, even though we
    // called "stopUpdatingLocation", remove us as the delegate to be sure
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // report any errors returned back from Location Services
}

@end