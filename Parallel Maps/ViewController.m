//
//  ViewController.m
//  Parallel Maps
//
//  Created by Anastasiya on 3/9/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import "ViewController.h"
#import "MapTypesViewController.h"
#import "PlaceAnnotation.h"
#import "MainModel.h"
#import "SWRevealViewController.h"
#import "MapKit+ZoomLevel.h"
#import "SearchListViewController.h"
#import "AddressBook/AddressBook.h"
#import "DirectionsManager.h"
#import "DirectionsViewController.h"

#define METERS_PER_MILE 1609.344
#define MERCATOR_RADIUS 85445659.44705395
#define MERCATOR_OFFSET 268435456
#define MAX_GOOGLE_LEVELS 20
#define ZOOM_LEVEL 14
#define ROUND_BUTTON_WIDTH_HEIGHT 40

@interface ViewController () 
@property (nonatomic, weak) PlaceAnnotation *annotationSearch;
@property (nonatomic) MainModel *mainModel;
@property (nonatomic, strong) UIToolbar *routeInfoBg;
@property (strong, nonatomic) MKRoute *selectedRoute;
@end

@implementation ViewController {
    MKCoordinateRegion mapRegion;
    GMSCameraPosition *googleMapCamera;
    CLLocationManager *locationManager;
    CLLocation *location;
    CLPlacemark *thePlacemark;
    MKRoute *routeDetails;
    GMSPanoramaView *streetView_;
    DirectionsManager *directionsManager;
}

@synthesize googleMapsView, mapKitView, geocoder, geocoder1, searchBtn, settingsBtn, sidebarButton, initialLocation, routeBtn, locateBtn, googleTransportMode, slider;


#pragma mark - notification system

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[super dealloc];
}

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"TrafficOnNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"TrafficOffNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"3dViewOn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"3dViewOff" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"SyncOn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"SyncOff" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"Directions" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"SliderBtn" object:nil];
    
    return self;
}

- (void)receiveNotification:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"TrafficOnNotification"]) {
        googleMapsView.trafficEnabled = YES;
        trafficMode = YES;
    }
    if ([[notification name] isEqualToString:@"TrafficOffNotification"]) {
        googleMapsView.trafficEnabled = NO;
        trafficMode = NO;
    }
    if ([[notification name] isEqualToString:@"3dViewOn"]) {
        NSLog(@"3d view on");
        [self.mapKitView setRegion:globalRegion animated:YES];
        self.mapKitView.showsBuildings = YES;
        MKMapCamera *mapCamera = [[MKMapCamera alloc] init];
        mapCamera.centerCoordinate = self.mapKitView.centerCoordinate;
        mapCamera.pitch = 45;
        mapCamera.altitude = 200;
        mapCamera.heading = 45;
        self.mapKitView.camera = mapCamera;
        
        [googleMapsView animateToViewingAngle:45];
        googleMapsView.buildingsEnabled = YES;
        DMode = YES;
    }
    if ([[notification name] isEqualToString:@"3dViewOff"]) {
        NSLog(@"3d view off");
        [googleMapsView animateToViewingAngle:0];
        self.googleMapsView.buildingsEnabled = NO;
        self.mapKitView.showsBuildings = NO;
        DMode = NO;
    }
    if ([[notification name] isEqualToString:@"SyncOn"]) {
        double zoomLevel = [self getZoomLevel];
        GMSCameraPosition *camera1 = [GMSCameraPosition cameraWithLatitude:self.mapKitView.region.center.latitude longitude:self.mapKitView.region.center.longitude zoom:zoomLevel];
        googleMapsView.camera = camera1;
    }
    if ([[notification name] isEqualToString:@"SyncOff"]) {
        NSLog(@"sync off");
    }
    if ([[notification name] isEqualToString:@"Directions"]) {
        [self drawingPinsInStart:&locationFrom Finish:&locationTo];
        [self directionsFrom:&locationFrom to:&locationTo animated:YES];
        [self googleDirectionsApiFrom:&locationFrom to:&locationTo animated:YES];
        
        [self.mapKitView setCenterCoordinate:locationFrom zoomLevel:14 animated:YES];
    }
    if ([[notification name] isEqualToString:@"SliderBtn"]) {
        slider.value = 50;
    }
}

#pragma mark - view will appear

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.toolbar.hidden = NO;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    self.toolbarText.width = screenWidth;
    
    //location manager
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager requestAlwaysAuthorization];
    [self->locationManager startUpdatingLocation];
    
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Please enable location services");
        return;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"Please authorize location services");
        return;
    }
    
    //maps settings
    
    mapKitView.delegate = self;
    mapKitView.rotateEnabled = YES;
    //mapKitView.showsUserLocation = YES;
    
    directionSearch = NO;
    self.googleMapsView.buildingsEnabled = NO;
    googleMapsView.myLocationEnabled = YES;
    googleMapsView.settings.compassButton = YES;
    googleMapsView.delegate = self;
    googleMapsView.settings.consumesGesturesInView = YES;
    
    directionsManager = [[DirectionsManager alloc] init];
    
    //search segue, region, directions notification
    
    if (searchSegue == YES) {
        if (mapItemList.count == 1) {
            MKCoordinateRegion searchRegion;
            searchRegion.center = pinCoordinate;
            searchRegion.span = MKCoordinateSpanMake(0.0051, 0.0051);
            [mapKitView setRegion:searchRegion];
            
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = pinCoordinate;
            [self.mapKitView addAnnotation:annotation];
            //[self.mapKitView selectAnnotation:[self.mapKitView.annotations objectAtIndex:0] animated:YES];
        
            bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:pinCoordinate coordinate:pinCoordinate];
            self.detailsButton.title = [NSString stringWithFormat:@"Latitude: %.2f, Longitude: %.2f", pinCoordinate.latitude, pinCoordinate.longitude];
            
            CLLocation *pinLoc = [[CLLocation alloc] initWithLatitude:pinCoordinate.latitude longitude:pinCoordinate.longitude];
            
            if (!self.geocoder) {
                self.geocoder = [[CLGeocoder alloc] init];
            }
            
            [self.geocoder reverseGeocodeLocation:pinLoc completionHandler:^(NSArray *placemarks, NSError *error) {
                NSString *annTitle = @"Address unknown";
                if ([placemarks count] > 0) {
                    CLPlacemark *placemark = [placemarks objectAtIndex:0];
                    
                    annTitle = [NSString stringWithFormat:@"%@, %@", placemark.country, placemark.locality];
                    
                    if ([placemark.areasOfInterest count] > 0) {
                        NSString *areaOfInterest = [placemark.areasOfInterest objectAtIndex:0];
                        self.toolbarText.title = areaOfInterest;
                    }
                    
                    annotation.title = annTitle;
                    annotation.subtitle = [NSString stringWithFormat:@"%@, %@, %@", placemark.subLocality, placemark.thoroughfare, placemark.description];
                    address = placemark.subLocality;
                    
                    [self.mapKitView removeAnnotations:self.mapKitView.annotations];
                    [self.mapKitView addAnnotation:annotation];
                    
                    if (mapKitView.overlays) {
                        [self.googleMapsView clear];
                    }
                    
                    for (CLPlacemark *placemark in placemarks) {
                        CLPlacemark *placemark = [placemarks objectAtIndex:0];
                        NSDictionary *addressDictionary = placemark.addressDictionary;
                        NSString *annTitle = @"Address unknown";
                        
                        NSString *address = [addressDictionary
                                             objectForKey:(NSString *)kABPersonAddressStreetKey];
                        NSString *city = [addressDictionary
                                          objectForKey:(NSString *)kABPersonAddressCityKey];
                        NSString *state = [addressDictionary
                                           objectForKey:(NSString *)kABPersonAddressStateKey];
                        NSString *zip = [addressDictionary
                                         objectForKey:(NSString *)kABPersonAddressZIPKey];
                        
                        if (mapKitView.overlays) {
                            [self.googleMapsView clear];
                        }
                        
                        GMSMarker *marker = [GMSMarker markerWithPosition:pinCoordinate];
                        marker.title = [NSString stringWithFormat:@"%@, %@", city, state];
                        marker.snippet = [NSString stringWithFormat:@"%@, %@", address, zip];
                        marker.appearAnimation = kGMSMarkerAnimationPop;
                        marker.map = self.googleMapsView;
                    };
                }
            }];

        }
        else {
            for (MKMapItem *item in mapItemList) {
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.coordinate = item.placemark.location.coordinate;
                annotation.title = item.name;
                [self.mapKitView addAnnotation:annotation];
                
                GMSMarker *marker = [GMSMarker markerWithPosition:item.placemark.location.coordinate];
                marker.appearAnimation = kGMSMarkerAnimationPop;
                marker.title = item.name;
                marker.map = googleMapsView;
                
                //bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:annotation.coordinate coordinate:annotation.coordinate];
                //bounds = [bounds includingCoordinate:marker.position];
                
                //GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:50.0f];
                //[googleMapsView moveCamera:update];
                [self.mapKitView setCenterCoordinate:item.placemark.location.coordinate zoomLevel:12 animated:YES];
            }
        }
        searchSegue = NO;
        directionSearch = YES;
    }

    if (regionSave == YES) {
        [mapKitView setRegion:globalRegion];
    }
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screen.size.height;
    
    slider = [[UISlider alloc] initWithFrame:CGRectMake(screenWidth/8, screenHeight/2, screenHeight - 300, 20)];
    NSLog(@"%f %f %f %f", screenWidth, screenHeight, screenWidth/8, screenHeight - 300);
    slider.transform = CGAffineTransformMakeRotation(-M_PI_2);

    slider.minimumValue = 35.0;
    slider.maximumValue = 65.0;
    slider.continuous = YES;
    slider.value = 50.0;
    
    //[slider setThumbImage:[UIImage imageNamed:@"handle.png"] forState:UIControlStateNormal];
    //[slider addTarget:self action:@selector(sliderValueDidChanged:) forControlEvents:UIControlEventValueChanged];
    [self xPositionFromSliderValue:slider];
    [slider addTarget:self action:@selector(xPositionFromSliderValue:) forControlEvents:UIControlEventValueChanged];
    [slider setBackgroundColor:[UIColor clearColor]];
    UIImage *clearImage = [[UIImage alloc] init];
    [slider setMinimumTrackImage:clearImage forState:UIControlStateNormal];
    [slider setMaximumTrackImage:clearImage forState:UIControlStateNormal];
    //slider.thumbTintColor = [UIColor clearColor];
    
    NSLog(@"%f %f %f %f %f %f", slider.frame.origin.x, slider.frame.origin.y, slider.frame.size.width, slider.frame.size.height, slider
          .currentThumbImage.size.height, slider.currentThumbImage.size.width);
    
    [self.view addSubview:slider];
}

/*- (void)mapView:(MKMapView *)mapKitView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!initialLocation) {
        self.initialLocation = userLocation.location;
 
        MKCoordinateRegion region;
        region.center = self.mapKitView.userLocation.coordinate; 
        region.span = MKCoordinateSpanMake(0.005, 0.005);
        region = [self.mapKitView regionThatFits:region];
        [self.mapKitView setRegion:region animated:YES];
        
        double zoom = [self getZoomLevel];
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.mapKitView.userLocation.coordinate.latitude
                                                                longitude:self.mapKitView.userLocation.coordinate.longitude
                                                                        zoom:zoom];
        [googleMapsView animateToCameraPosition:camera];
        NSLog(@"update user location");
 
            MKCoordinateRegion region;
            region.center = self.mapKitView.userLocation.coordinate;
            region.span = MKCoordinateSpanMake(0.005, 0.005);
            region = [self.mapKitView regionThatFits:region];
            [self.mapKitView setRegion:region animated:YES];
            
            double zoom = [self getZoomLevel];
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.mapKitView.userLocation.coordinate.latitude
                                                                    longitude:self.mapKitView.userLocation.coordinate.longitude
                                                                         zoom:zoom];
            [googleMapsView animateToCameraPosition:camera];*/
        /*} else {
            googleMapsView.buildingsEnabled = NO;
        }*/
    //}
//}

- (void)viewDidLoad {
    NSString *currentBundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *previousBundleVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"PreviousBundleVersion"];
    
    if (![currentBundleVersion isEqualToString:previousBundleVersion]) {
        NSLog(@"This string will showing only once");
    }
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:currentBundleVersion forKey:@"PreviousBundleVersion"];
        [standardUserDefaults synchronize];
    }
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screen.size.height;
    CGFloat screenWidth = screen.size.width;
    
    self.routeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.routeBtn.frame = CGRectMake(screenWidth - 60, screenHeight - 71, 50, 50);
    [self.routeBtn setImage:[UIImage imageNamed:@"directions.png"] forState:UIControlStateNormal];
    [self.routeBtn addTarget:self action:@selector(showRouteSteps:) forControlEvents:UIControlEventTouchUpInside];
    self.routeBtn.clipsToBounds = YES;
    self.routeBtn.layer.cornerRadius = 40/2.0f;
    [self.view addSubview:routeBtn];
    
    self.locateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.locateBtn.frame = CGRectMake(screenWidth - 60, screenHeight - 131, 50, 50);
    [self.locateBtn setImage:[UIImage imageNamed:@"location.png"] forState:UIControlStateNormal];
    [self.locateBtn addTarget:self action:@selector(locationButton:) forControlEvents:UIControlEventTouchUpInside];
    self.locateBtn.clipsToBounds = YES;
    self.locateBtn.layer.cornerRadius = 40/2.0f;
    [self.view addSubview:locateBtn];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0;
    [self.mapKitView addGestureRecognizer:lpgr];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
    } else {
        SWRevealViewController *revealViewController = self.revealViewController;
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        //SWRevealViewController *vc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"leftSide"];
        //[self.navigationController pushViewController:vc2 animated:YES];
    }
    
    if (mapTypeSatellite == YES) {
        self.mapKitView.mapType = MKMapTypeSatellite;
        self.googleMapsView.mapType = kGMSTypeSatellite;
    }
    if (mapTypeHybrid == YES) {
        self.mapKitView.mapType = MKMapTypeHybrid;
        self.googleMapsView.mapType = kGMSTypeHybrid;
    }
    if (mapTypeRegular == YES) {
        self.mapKitView.mapType = MKMapTypeStandard;
        self.googleMapsView.mapType = kGMSTypeNormal;
    }
    if (mapTypeTerrain == YES) {
        self.mapKitView.mapType = MKMapTypeStandard;
        self.googleMapsView.mapType = kGMSTypeTerrain;
    }
    
    [super viewDidLoad];
    [self init];
    
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [self.mapKitView addGestureRecognizer:panRec];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    
}

- (IBAction)locationButton:(id)sender {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    self.mapKitView.showsUserLocation = YES;
    mapKitView.centerCoordinate = mapKitView.userLocation.location.coordinate;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(mapKitView.centerCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapKitView regionThatFits:viewRegion];
    [self.mapKitView setRegion:adjustedRegion animated:YES];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:mapKitView.centerCoordinate.latitude longitude:mapKitView.centerCoordinate.longitude zoom:15.5];
    [self.googleMapsView setCamera:camera];
    
    self.detailsButton.title = [NSString stringWithFormat:@"Latitude: %.2f, Longitude: %.2f", self.mapKitView.userLocation.coordinate.latitude, self.mapKitView.userLocation.coordinate.longitude];
    
    slider.value = 50;
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    CGRect temp3 = self.sen.frame;
    temp3.origin.y = screen.size.height/2 + 15;
    self.sen.frame = temp3;
    
    CGRect temp = self.mapKitView.frame;
    temp.size.height = screen.size.height/2 + 15;
    self.mapKitView.frame = temp;
    
    CGRect temp1 = self.googleMapsView.frame;
    temp1.origin.y = screen.size.height/2 + 15;
    temp1.size.height = screen.size.height - mapKitView.frame.size.height;
    self.googleMapsView.frame = temp1;
}

- (double)getZoomLevel {
    CLLocationDegrees longitudeDelta;
    longitudeDelta = mapKitView.region.span.longitudeDelta;
    CGFloat mapWidthInPixels;
    mapWidthInPixels = mapKitView.bounds.size.width;
    double zoomScale = longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * mapWidthInPixels);
    double zoomer = (MAX_GOOGLE_LEVELS - log2(zoomScale)) + 1.0;
    //NSLog(@"apple zoom = %f", zoomer);
    //NSLog(@"google zoom = %f", self.googleMapsView.camera.zoom);
    return zoomer;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSString *locationMessage = [NSString stringWithFormat:@"Please authorize location services"];
        UIAlertView *locationAlert = [[UIAlertView alloc] initWithTitle:@"Location disabled" message:locationMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [locationAlert show];
        return;
    }
    NSLog(@"Error: %@", error.description);
    return;
}

#pragma mark - map change delegates

- (void)mapView:(MKMapView *)mapKitView regionWillChangeAnimated:(BOOL)animated {
    
}

- (void)mapView:(MKMapView *)mapKitView regionDidChangeAnimated:(BOOL)animated {
    MKMapCamera *camera = self.mapKitView.camera;
    CLLocationDistance altitude = camera.altitude;
    mapAngle = camera.heading;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (self.sen.frame.origin.y <= screenRect.size.height/2 + 10 && self.sen.frame.origin.y >= screenRect.size.height/2 - 10) {
        slider.value = 50;
    }
    
    double zoomLevel = [self getZoomLevel];
    syncFromMapKit = YES;
    
    if (mapRegion.center.latitude != self.mapKitView.region.center.latitude) {
        if (syncFromGoogleMap != YES) {
            if (syncMode == YES) {
                    GMSCameraPosition *camera1 = [GMSCameraPosition cameraWithLatitude:self.mapKitView.region.center.latitude longitude:self.mapKitView.region.center.longitude zoom:zoomLevel bearing:mapAngle viewingAngle:0];
                    googleMapsView.camera = camera1;
            } else if (syncMode == NO){
                //GMSCameraUpdate *camera2 = [GMSCameraUpdate zoomTo:zoomLevel];
                //[googleMapsView animateWithCameraUpdate:camera2];
            }
        }
    }
    
    globalCoordinate = CLLocationCoordinate2DMake(self.mapKitView.region.center.latitude, self.mapKitView.region.center.longitude);
    syncFromMapKit = NO;
    
    globalRegion = self.mapKitView.region;
}

- (void)mapView:(GMSMapView *)googleMapsView didChangeCameraPosition:(GMSCameraPosition *)position {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (self.sen.frame.origin.y <= screenRect.size.height/2 + 10 && self.sen.frame.origin.y >= screenRect.size.height/2 - 10) {
        slider.value = 50;
    }
    
    CLLocationDirection bearingAngle = self.googleMapsView.camera.bearing;
    
    syncFromGoogleMap = YES;
    if (syncFromMapKit != YES) {
        
        if (syncMode == YES) {
            if (mapAngle <= 0.05 || mapAngle >= 359) {
                CLLocationCoordinate2D centerCoord = {position.target.latitude, position.target.longitude};
                [mapKitView setCenterCoordinate:centerCoord zoomLevel:self.googleMapsView.camera.zoom-1 animated:NO];
            } else if (bearingAngle == 0){
                //[self.googleMapsView animateToBearing:mapAngle];
                MKMapCamera *newCamera = [[mapKitView camera] copy];
                [newCamera setHeading:bearingAngle]; // or newCamera.heading + 90.0 % 360.0
                [mapKitView setCamera:newCamera animated:YES];
            }
        } else {
            //[mapKitView setZoom:self.googleMapsView.camera.zoom mapView:mapKitView animated:NO];
        }
    }
    syncFromGoogleMap = NO;
}

#pragma mark - annotation

- (void)addAnnotation:(CLPlacemark *)placemark {
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
    point.title = [placemark.addressDictionary objectForKey:@"Street"];
    point.subtitle = [placemark.addressDictionary objectForKey:@"City"];
    [self.mapKitView addAnnotation:point];
}

- (CLLocationCoordinate2D)coordinateWithLocation:(NSDictionary*)location
{
    double latitude = [[location objectForKey:@"lat"] doubleValue];
    double longitude = [[location objectForKey:@"lng"] doubleValue];
    
    return CLLocationCoordinate2DMake(latitude, longitude);
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    
    self.mapKitView.showsPointsOfInterest = YES;
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapKitView];
    
    CLLocationCoordinate2D touchMapCoordinate = [self.mapKitView convertPoint:touchPoint toCoordinateFromView:self.mapKitView];
    
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];

    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = touchMapCoordinate;
    pinCoordinate = touchMapCoordinate;
    
    [self.geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSString *annTitle = @"Address unknown";
        
        if ([placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            
            annTitle = [NSString stringWithFormat:@"%@, %@", placemark.country, placemark.locality];
            
            if ([placemark.areasOfInterest count] > 0) {
                NSString *areaOfInterest = [placemark.areasOfInterest objectAtIndex:0];
                self.toolbarText.title = areaOfInterest;
            }
            
            annotation.title = annTitle;
            annotation.subtitle = [NSString stringWithFormat:@"%@, %@, %@", placemark.subLocality, placemark.thoroughfare, placemark.description];
            address = placemark.subLocality;
            
            [self.mapKitView removeAnnotations:self.mapKitView.annotations];
            [self.mapKitView addAnnotation:annotation];
            
            if (mapKitView.overlays) {
                [self.googleMapsView clear];
            }
            
            for (CLPlacemark *placemark in placemarks) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                NSDictionary *addressDictionary = placemark.addressDictionary;
                NSString *annTitle = @"Address unknown";
                
                NSString *address = [addressDictionary
                                     objectForKey:(NSString *)kABPersonAddressStreetKey];
                NSString *city = [addressDictionary
                                  objectForKey:(NSString *)kABPersonAddressCityKey];
                NSString *state = [addressDictionary
                                   objectForKey:(NSString *)kABPersonAddressStateKey];
                NSString *zip = [addressDictionary
                                 objectForKey:(NSString *)kABPersonAddressZIPKey];
                
                if (mapKitView.overlays) {
                    [self.googleMapsView clear];
                }
                
                GMSMarker *marker = [GMSMarker markerWithPosition:pinCoordinate];
                marker.title = [NSString stringWithFormat:@"%@, %@", city, state];
                marker.snippet = [NSString stringWithFormat:@"%@, %@", address, zip];
                marker.appearAnimation = kGMSMarkerAnimationPop;
                marker.map = self.googleMapsView;
            };
            
            /*GMSMarker *marker = [GMSMarker markerWithPosition:touchMapCoordinate];
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.flat = YES;
            [[GMSGeocoder geocoder] reverseGeocodeCoordinate:marker.position completionHandler:^(GMSReverseGeocodeResponse* response, NSError *error) {
                for (GMSAddress *addressGoogle in [response results]) {
                    marker.title = [NSString stringWithFormat:@"%@, %@", addressGoogle.locality, addressGoogle.locality];
                    marker.snippet = [NSString stringWithFormat:@"%@, %@, %@", addressGoogle.subLocality, addressGoogle.administrativeArea, addressGoogle.thoroughfare];
                }
            }];
            marker.map = googleMapsView;*/
        } else {
            NSLog(@"No placemarks");
        }
    }];
    
    CLLocation *initLoc = [[CLLocation alloc] initWithLatitude:mapKitView.userLocation.coordinate.latitude longitude:mapKitView.userLocation.coordinate.longitude];
    CLLocation *finLoc = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
    
    CLLocationCoordinate2D coordLoc[2] = {initLoc.coordinate, finLoc.coordinate};
    
    //distance in meters
    CLLocationDistance distance = [finLoc distanceFromLocation: initLoc];
    
    typedef struct GMSMapPoint GMSMapPoint;
    
    //Apple Maps and Google maps directions API
    
    if (drawRoute == YES) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(touchMapCoordinate.latitude, touchMapCoordinate.longitude);
        CLLocationCoordinate2D coordInit = CLLocationCoordinate2DMake(self.mapKitView.userLocation.coordinate.latitude, self.mapKitView.userLocation.coordinate.longitude);
    
        [self googleDirectionsApiFrom:&coordInit to:&coord animated:YES];
        [self directionsFrom:&coordInit to:&coord animated:YES];
    } else {
        self.detailsButton.title = [NSString stringWithFormat:@"Latitude: %.2f, Longitude: %.2f", touchMapCoordinate.latitude, touchMapCoordinate.longitude];
    }
}

- (void)mapView:(GMSMapView *)googleMapsView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
    [self.geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Geocode failed with error");
            return;
        }
        
    for (CLPlacemark *placemark in placemarks) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSDictionary *addressDictionary = placemark.addressDictionary;
        
            NSString *annTitle = @"Address unknown";
            
            NSString *address = [addressDictionary
                                 objectForKey:(NSString *)kABPersonAddressStreetKey];
            NSString *city = [addressDictionary
                              objectForKey:(NSString *)kABPersonAddressCityKey];
            NSString *state = [addressDictionary
                               objectForKey:(NSString *)kABPersonAddressStateKey];
            NSString *zip = [addressDictionary
                             objectForKey:(NSString *)kABPersonAddressZIPKey];
        if (mapKitView.overlays) {
            [self.googleMapsView clear];
        }
            GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
            marker.title = [NSString stringWithFormat:@"%@, %@", city, state];
            marker.snippet = [NSString stringWithFormat:@"%@, %@", address, zip];
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.map = self.googleMapsView;
            
            if (syncMode == YES) {
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.coordinate = coordinate;
                annTitle = [NSString stringWithFormat:@"%@, %@", placemark.country, placemark.locality];
                annotation.title = annTitle;
                annotation.subtitle = [NSString stringWithFormat:@"%@, %@, %@", placemark.subLocality, placemark.thoroughfare, placemark.description];
                [self.mapKitView removeAnnotations:self.mapKitView.annotations];
                [self.mapKitView addAnnotation:annotation];
            }
        }
    }];
    
    if (drawRoute == YES) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        CLLocationCoordinate2D coordInit = CLLocationCoordinate2DMake(self.mapKitView.userLocation.coordinate.latitude, self.mapKitView.userLocation.coordinate.longitude);
        [self googleDirectionsApiFrom:&coordInit to:&coord animated:YES];
        [self directionsFrom:&coordInit to:&coord animated:YES];
    } else {
        if (mapKitView.overlays) {
            [self.googleMapsView clear];
        }
        self.detailsButton.title = [NSString stringWithFormat:@"Latitude: %.2f, Longitude: %.2f", coordinate.latitude, coordinate.longitude];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapKitView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapKitView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapKitView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
        renderer.lineWidth = 3.0f;
        renderer.strokeColor = [UIColor redColor];
        renderer.alpha = 0.5;
        
        return renderer;
    }
    return nil;
}

#pragma mark - others

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)orientationChanged:(NSNotification *)notification {
    NSLog(@"orientation changed");
}

#pragma mark - routing

- (void)directionsFrom:(CLLocationCoordinate2D *)from
                    to:(CLLocationCoordinate2D *)to
              animated:(BOOL)animated {
    
    CLLocation *rendLoc = [[CLLocation alloc] initWithLatitude:locationFrom.latitude longitude:locationFrom.longitude];
    
    /*MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = locationFrom;
    [self.mapKitView addAnnotation:annotation];
    
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = locationTo;
    [self.mapKitView addAnnotation:annotation1];
    */
    [self.geocoder reverseGeocodeLocation:rendLoc completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Geocode failed with error");
            return;
        }
        
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSDictionary *addressDictionary = placemark.addressDictionary;
            NSLog(@"address dictionary %@", addressDictionary);
            NSString *annTitle = @"Address unknown";

            
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = locationFrom;
            
            annTitle = [NSString stringWithFormat:@"%@, %@", placemark.country, placemark.locality];
            annotation.title = annTitle;
            annotation.subtitle = [NSString stringWithFormat:@"%@, %@, %@", placemark.subLocality, placemark.thoroughfare, placemark.description];
            [self.mapKitView addAnnotation:annotation];
            
            GMSMarker *marker = [GMSMarker markerWithPosition:locationFrom];
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.flat = YES;
        
            [[GMSGeocoder geocoder] reverseGeocodeCoordinate:marker.position completionHandler:^(GMSReverseGeocodeResponse* response, NSError *error) {
                for (GMSAddress *addressGoogle in [response results]) {
                    marker.title = [NSString stringWithFormat:@"%@, %@", addressGoogle.locality, addressGoogle.locality];
                    marker.snippet = [NSString stringWithFormat:@"%@, %@, %@", addressGoogle.subLocality, addressGoogle.administrativeArea, addressGoogle.thoroughfare];
                }
            }];
            marker.map = googleMapsView;
    }];
    
    MKPlacemark *source = [[MKPlacemark alloc] initWithCoordinate:*from addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil]];
    MKMapItem *srcMapItem = [[MKMapItem alloc] initWithPlacemark:source];
    [srcMapItem setName:@""];
    
    MKPlacemark *destination = [[MKPlacemark alloc] initWithCoordinate:*to addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil]];
    MKMapItem *distMapItem = [[MKMapItem alloc] initWithPlacemark:destination];
    [distMapItem setName:@""];
    
    CLLocation *initLoc = [[CLLocation alloc] initWithLatitude:from->latitude longitude:from->longitude];
    CLLocation *finLoc = [[CLLocation alloc] initWithLatitude:to->latitude longitude:to->longitude];
    
    CLLocationDistance distance = [finLoc distanceFromLocation:initLoc];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    [request setSource:srcMapItem];
    [request setDestination:distMapItem];
    
    if (walkingMode == YES) {
        [request setTransportType:MKDirectionsTransportTypeWalking];
        self.navigationItem.title = @"Walking mode";
    } else if (drivingMode == YES){
        [request setTransportType:MKDirectionsTransportTypeAutomobile];
        self.navigationItem.title = @"Driving mode";
    } else {
        [request setTransportType:MKDirectionsTransportTypeAny];
    }
    
    MKDirections *direction1 = [[MKDirections alloc] initWithRequest:request];
    [direction1 calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        //NSLog(@"response direction1 = %@", response);
        NSArray *arrRoutes = [response routes];
        [arrRoutes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            MKRoute *rout = obj;
            MKPolyline *line = [rout polyline];
            _selectedRoute = rout;
            
            [self.mapKitView removeOverlays:self.mapKitView.overlays];
            
            [self.mapKitView addOverlay:line];
            //NSLog(@"Route Name : %@",rout.name);
            //NSLog(@"Total Distance (in Meters) :%f",rout.distance);
            //NSLog(@"Total Steps : %lu",(unsigned long)[steps count]);
            NSArray *steps = [rout steps];
            
            [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                //NSLog(@"Rout Instruction : %@",[obj instructions]);
                //NSLog(@"Rout Distance : %f",[obj distance]);
            }];
            NSString *time = [NSString stringWithFormat:@"%.2lf", rout.expectedTravelTime/60];
            if (distance < 1000) {
                self.detailsButton.title = [NSString stringWithFormat:@"Distance: %.2f meters, Time: %@ min", distance, time];
            } else {
                if (showKm == YES) {
                    self.detailsButton.title = [NSString stringWithFormat:@"Distance: %.2f km, Time %@ min", distance/1000, time];
                } else {
                    self.detailsButton.title = [NSString stringWithFormat:@"Distance: %.2f miles, Time %@ min", distance/1200, time];
                }
            }
        }];
        if (!error) {
            for (MKRoute *route in [response routes]) {
                [mapKitView addOverlay:[route polyline] level:MKOverlayLevelAboveRoads];
            }
        } else {
            self.navigationItem.title = @"";
            NSString *alertMessage = [NSString stringWithFormat:@"There is no available route between this places. Please, try another."];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

- (void)drawingPinsInStart:(CLLocationCoordinate2D *)start
                    Finish:(CLLocationCoordinate2D *)finish {
    CLLocation *initLoc = [[CLLocation alloc] initWithLatitude:start->latitude longitude:start->longitude];
    CLLocation *finLoc = [[CLLocation alloc] initWithLatitude:finish->latitude longitude:finish->longitude];
    
    //apple annotations
    if (!self.geocoder1) {
        self.geocoder1 = [[CLGeocoder alloc] init];
    }
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
    [self.geocoder1 reverseGeocodeLocation:initLoc completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Geocode failed with error");
            return;
        }
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = initLoc.coordinate;
        [self.mapKitView addAnnotation:annotation];

        for (CLPlacemark *placemark in placemarks) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSDictionary *addressDictionary = placemark.addressDictionary;
            
            NSString *annTitle = @"Address unknown";
            NSString *address = [addressDictionary objectForKey:(NSString *)kABPersonAddressStreetKey];
            NSString *city = [addressDictionary objectForKey:(NSString *)kABPersonAddressCityKey];
            NSString *state = [addressDictionary objectForKey:(NSString *)kABPersonAddressStateKey];
            NSString *zip = [addressDictionary objectForKey:(NSString *)kABPersonAddressZIPKey];
            annTitle = [NSString stringWithFormat:@"%@, %@", placemark.country, placemark.locality];
            
            if (mapKitView.overlays) {
                [self.googleMapsView clear];
            }
            annotation.title = annTitle;
            annotation.subtitle = [NSString stringWithFormat:@"%@, %@, %@", placemark.subLocality, placemark.thoroughfare, placemark.description];
            
            GMSMarker *marker1 = [GMSMarker markerWithPosition:initLoc.coordinate];
            marker1.title = [NSString stringWithFormat:@"%@, %@", city, state];
            marker1.snippet = [NSString stringWithFormat:@"%@, %@", address, zip];
            marker1.appearAnimation = kGMSMarkerAnimationPop;
            marker1.map = self.googleMapsView;
        }
    }];

    [self.geocoder reverseGeocodeLocation:finLoc completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Geocode failed with error");
            return;
        }
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = finLoc.coordinate;
        [self.mapKitView addAnnotation:annotation];
        
        for (CLPlacemark *placemark in placemarks) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSDictionary *addressDictionary = placemark.addressDictionary;
            NSString *annTitle = @"Address unknown";
            NSString *address = [addressDictionary objectForKey:(NSString *)kABPersonAddressStreetKey];
            NSString *city = [addressDictionary objectForKey:(NSString *)kABPersonAddressCityKey];
            NSString *state = [addressDictionary objectForKey:(NSString *)kABPersonAddressStateKey];
            NSString *zip = [addressDictionary objectForKey:(NSString *)kABPersonAddressZIPKey];
            annTitle = [NSString stringWithFormat:@"%@, %@", placemark.country, placemark.locality];
            
            if (mapKitView.overlays) {
                [self.googleMapsView clear];
            }
            
            annotation.title = annTitle;
            annotation.subtitle = [NSString stringWithFormat:@"%@, %@, %@", placemark.subLocality, placemark.thoroughfare, placemark.description];
            
            GMSMarker *marker = [GMSMarker markerWithPosition:finLoc.coordinate];
            marker.title = [NSString stringWithFormat:@"%@, %@", city, state];
            marker.snippet = [NSString stringWithFormat:@"%@, %@", address, zip];
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.map = self.googleMapsView;
        }
    }];
}

- (void)googleDirectionsApiFrom:(CLLocationCoordinate2D *)from
                             to:(CLLocationCoordinate2D *)to
                       animated:(BOOL)animated {
    CLLocation *initLoc = [[CLLocation alloc] initWithLatitude:from->latitude longitude:from->longitude];
    CLLocation *finLoc = [[CLLocation alloc] initWithLatitude:to->latitude longitude:to->longitude];
    
    /*GMSMarker *marker = [GMSMarker markerWithPosition:initLoc.coordinate];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    //marker.title = item.name;
    marker.map = googleMapsView;
    
    GMSMarker *marker1 = [GMSMarker markerWithPosition:finLoc.coordinate];
    marker1.appearAnimation = kGMSMarkerAnimationPop;
    marker1.map = googleMapsView;*/
    
    if (drivingMode == YES) {
        googleTransportMode = @"driving";
    } else if (walkingMode == YES){
        googleTransportMode = @"walking";
    }
    
    NSString *baseUrl = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true&mode=%@", initLoc.coordinate.latitude, initLoc.coordinate.longitude, finLoc.coordinate.latitude, finLoc.coordinate.longitude, googleTransportMode];
    
    NSURL *url = [NSURL URLWithString:[baseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLRequest *requestGoogle = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:requestGoogle queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"request google error");
        } else {
            NSError *error = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSString *routeAvailable = [result objectForKey:@"status"];
            if ([routeAvailable  isEqual: @"ZERO_RESULTS"]) {
                NSLog(@"No availbale routes");
            } else {
            
            NSArray *routes = [result objectForKey:@"routes"];
            
            NSDictionary *firstRoute = [routes objectAtIndex:0];
            
            NSDictionary *leg = [[firstRoute objectForKey:@"legs"] objectAtIndex:0];
            
            NSDictionary *end_location = [leg objectForKey:@"end_location"];
            double latitude = [[end_location objectForKey:@"lat"] doubleValue];
            double longitude = [[end_location objectForKey:@"lng"] doubleValue];
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = coordinate;
            point.title =  [leg objectForKey:@"end_address"];
            point.subtitle = @"I'm here!!!";
            
            NSArray *steps = [leg objectForKey:@"steps"];
            
                int stepIndex = 0;
            
                CLLocationCoordinate2D stepCoordinates[1  + [steps count] + 1];
            
                stepCoordinates[stepIndex] = initLoc.coordinate;
            
                for (NSDictionary *step in steps) {
                    NSDictionary *start_location = [step objectForKey:@"start_location"];
                    stepCoordinates[++stepIndex] = [self coordinateWithLocation:start_location];
                
                    if ([steps count] == stepIndex){
                        NSDictionary *end_location = [step objectForKey:@"end_location"];
                        stepCoordinates[++stepIndex] = [self coordinateWithLocation:end_location];
                    }
                }
            
                GMSMutablePath *path2 = [GMSMutablePath path];
            
                for (stepIndex = 0; stepIndex <= [steps count] + 1; stepIndex++) {
                    [path2 addCoordinate:stepCoordinates[stepIndex]];
                }
                GMSPolyline *rectangle = [GMSPolyline polylineWithPath:path2];
                rectangle.strokeWidth = 2.f;
                rectangle.map = googleMapsView;
            }
        }
    }];
}

#pragma mark - route steps toolbar

- (IBAction)showRouteSteps:(id)sender {
    if (self.mapKitView.overlays) {
        RouteStepsViewController *vc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"routeSteps"];
        vc2.selectedRoute = _selectedRoute;
        [self.navigationController pushViewController:vc2 animated:YES];
    }
    else if (directionSearch == YES) {
        CLLocationCoordinate2D coordInit = CLLocationCoordinate2DMake(self.mapKitView.userLocation.coordinate.latitude, self.mapKitView.userLocation.coordinate.longitude);
        [self directionsFrom:&coordInit to:&pinCoordinate animated:YES];
        [self googleDirectionsApiFrom:&coordInit to:&pinCoordinate animated:YES];
    } else {
        DirectionsViewController *vc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"directionsViewController"];
        [self.navigationController pushViewController:vc2 animated:YES];
    }
}

- (void)didRouteInfoViewControllerClosed:(RouteStepsViewController*)controller {
    [UIView animateWithDuration:0.2f animations:^{
        CGRect _f = self.routeInfoBg.frame;
        _f.origin.y = 568.0f;
        self.routeInfoBg.frame = _f;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [self.routeInfoBg removeFromSuperview];
            self.routeInfoBg = nil;
            
            [controller removeFromParentViewController];
        }
    }];
}

- (IBAction)showDetails:(id)sender {
    //comment
}

- (void)didDetailsViewControllerClosed:(DetailsViewController*)controller {
    [UIView animateWithDuration:0.2f animations:^{
        CGRect _f = self.routeInfoBg.frame;
        _f.origin.y = 568.0f;
        self.routeInfoBg.frame = _f;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.routeInfoBg removeFromSuperview];
            self.routeInfoBg = nil;
            
            [controller removeFromParentViewController];
        }
    }];
}

#pragma mark - slider

- (float)xPositionFromSliderValue:(UISlider *)aSlider
{
    //NSLog(@"%f",value);
    float sliderRange = aSlider.frame.size.height - aSlider.currentThumbImage.size.height;
    float sliderOrigin = aSlider.frame.origin.y + (aSlider.currentThumbImage.size.height / 2.0);
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    float sliderValueToPixels = (((aSlider.value-aSlider.minimumValue)/(aSlider.maximumValue-aSlider.minimumValue)) * sliderRange) + sliderOrigin;
    
    if (self.mapKitView.frame.size.height > 150 || self.googleMapsView.frame.origin.y < 350) {
        
        if (aSlider.value > 55) {
            CGRect temp3 = self.sen.frame;
            temp3.origin.y = screenRect.size.height - sliderValueToPixels + 35;
            self.sen.frame = temp3;
        
            CGRect temp = self.mapKitView.frame;
            temp.size.height = screenRect.size.height - sliderValueToPixels + 35;
            self.mapKitView.frame = temp;
        
            CGRect temp1 = self.googleMapsView.frame;
            temp1.origin.y = screenRect.size.height - sliderValueToPixels + 35;
            temp1.size.height = screenRect.size.height - mapKitView.frame.size.height;
            self.googleMapsView.frame = temp1;
            
        } else if (aSlider.value < 45){
            CGRect temp3 = self.sen.frame;
            temp3.origin.y = screenRect.size.height - sliderValueToPixels + 5;
            self.sen.frame = temp3;
            
            CGRect temp = self.mapKitView.frame;
            temp.size.height = screenRect.size.height - sliderValueToPixels + 5;
            self.mapKitView.frame = temp;
            
            CGRect temp1 = self.googleMapsView.frame;
            temp1.origin.y = screenRect.size.height - sliderValueToPixels + 5;
            temp1.size.height = screenRect.size.height - mapKitView.frame.size.height;
            self.googleMapsView.frame = temp1;
            
        } else {
            CGRect temp3 = self.sen.frame;
            temp3.origin.y = screenRect.size.height - sliderValueToPixels + 15;
            self.sen.frame = temp3;
            
            CGRect temp = self.mapKitView.frame;
            temp.size.height = screenRect.size.height - sliderValueToPixels + 15;
            self.mapKitView.frame = temp;
            
            CGRect temp1 = self.googleMapsView.frame;
            temp1.origin.y = screenRect.size.height - sliderValueToPixels + 15;
            temp1.size.height = screenRect.size.height - mapKitView.frame.size.height;
            self.googleMapsView.frame = temp1;
        }
        //NSLog(@"%f", aSlider.value);
    }
    return sliderValueToPixels;
}

@end