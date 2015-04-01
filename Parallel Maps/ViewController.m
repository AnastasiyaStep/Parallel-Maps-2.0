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

#define METERS_PER_MILE 1609.344
#define MERCATOR_RADIUS 85445659.44705395
#define MERCATOR_OFFSET 268435456
#define MAX_GOOGLE_LEVELS 20
#define ZOOM_LEVEL 14
#define ROUND_BUTTON_WIDTH_HEIGHT 40

@interface ViewController () 
@property (nonatomic, weak) PlaceAnnotation *annotationSearch;
@property (nonatomic) MainModel *mainModel;
@end

@implementation ViewController {
    MKCoordinateRegion mapRegion;
    GMSCameraPosition *googleMapCamera;
    CLLocationManager *locationManager;
    CLLocation *location;
    CLPlacemark *thePlacemark;
    MKRoute *routeDetails;
    GMSPanoramaView *streetView_;
}

@synthesize googleMapsView, mapKitView, geocoder, addressLabel, searchBtn, removeMarkersBtn, routeBtn, dViewButton1, dViewButton2, mapTypeSatellite, mapTypeHybrid, mapTypeRegular, mapTypeTerrain, locationBtn1, locationBtn2, synchronisationBtn, settingsBtn, sidebarButton; //showLatLot, syncMode;

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    //UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavbar:)];
    //[self.view addGestureRecognizer:tapGesture];
    self.navigationController.navigationBar.hidden = NO;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager requestAlwaysAuthorization];
    [self->locationManager startUpdatingLocation];
    
    mapKitView.showsUserLocation = YES;
    
    MKCoordinateRegion startRegion;
    startRegion.center.latitude = 35.6833;
    startRegion.center.longitude = 139.6833;
    startRegion.span.latitudeDelta = 0.0003f;
    startRegion.span.longitudeDelta = 0.0003f;
    
    /*self.removeMarkersBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.removeMarkersBtn.frame = CGRectMake(170, 20, 40, 40);
    [self.removeMarkersBtn setBackgroundColor:[UIColor whiteColor]];
    [self.removeMarkersBtn addTarget:self action:@selector(removeMarkersButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [removeMarkersBtn setImage:[UIImage imageNamed:@"remove.png"] forState:UIControlStateNormal];
    self.removeMarkersBtn.clipsToBounds = YES;
    self.removeMarkersBtn.layer.cornerRadius = ROUND_BUTTON_WIDTH_HEIGHT/2.0f;
    self.removeMarkersBtn.layer.borderColor = [UIColor greenColor].CGColor;
    self.removeMarkersBtn.layer.borderWidth = 0.5f;
    [self.view addSubview:removeMarkersBtn];
     */
    
    /*self.routeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.routeBtn.frame = CGRectMake(260, 510, 50, 50);
    [self.routeBtn setBackgroundColor:[UIColor whiteColor]];
    [self.routeBtn addTarget:self action:@selector(removeMarkersButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [routeBtn setImage:[UIImage imageNamed:@"route.png"] forState:UIControlStateNormal];
    self.routeBtn.clipsToBounds = YES;
    self.routeBtn.layer.cornerRadius = 50/2.0f;
    self.routeBtn.layer.borderColor = [UIColor greenColor].CGColor;
    self.routeBtn.layer.borderWidth = 0.5f;
    [self.view addSubview:routeBtn];
    */
    /*self.locationBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.locationBtn1.frame = CGRectMake(30, 20, 40, 40);
    [self.locationBtn1 setBackgroundColor:[UIColor whiteColor]];
    [self.locationBtn1 addTarget:self action:@selector(locationButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [locationBtn1 setImage:[UIImage imageNamed:@"location.png"] forState:UIControlStateNormal];
    self.locationBtn1.clipsToBounds = YES;
    self.locationBtn1.layer.cornerRadius = ROUND_BUTTON_WIDTH_HEIGHT/2.0f;
    self.locationBtn1.layer.borderColor = [UIColor greenColor].CGColor;
    self.locationBtn1.layer.borderWidth = 0.5f;
    [self.view addSubview:locationBtn1];
    
    self.locationBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.locationBtn2.frame = CGRectMake(30, 520, 40, 40);
    [self.locationBtn2 setBackgroundColor:[UIColor whiteColor]];
    [self.locationBtn2 addTarget:self action:@selector(locationButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [locationBtn2 setImage:[UIImage imageNamed:@"location.png"] forState:UIControlStateNormal];
    self.locationBtn2.clipsToBounds = YES;
    self.locationBtn2.layer.cornerRadius = ROUND_BUTTON_WIDTH_HEIGHT/2.0f;
    self.locationBtn2.layer.borderColor = [UIColor greenColor].CGColor;
    self.locationBtn2.layer.borderWidth = 0.5f;
    [self.view addSubview:locationBtn2];*/
    
    /*self.dViewButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dViewButton1.frame = CGRectMake(55, 520, 40, 40);
    [self.dViewButton1 setBackgroundColor:[UIColor whiteColor]];
    [self.dViewButton1 addTarget:self action:@selector(dViewButtonDidTap2:) forControlEvents:UIControlEventTouchUpInside];
    [dViewButton1 setImage:[UIImage imageNamed:@"3dview.png"] forState:UIControlStateNormal];
    self.dViewButton1.clipsToBounds = YES;
    self.dViewButton1.layer.cornerRadius = ROUND_BUTTON_WIDTH_HEIGHT/2.0f;
    self.dViewButton1.layer.borderColor = [UIColor greenColor].CGColor;
    self.dViewButton1.layer.borderWidth = 0.5f;
    [self.view addSubview:dViewButton1];
    
    self.dViewButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dViewButton2.frame = CGRectMake(55, 20, 40, 40);
    [self.dViewButton2 setBackgroundColor:[UIColor whiteColor]];
    [self.dViewButton2 addTarget:self action:@selector(dViewButtonDidTap1:) forControlEvents:UIControlEventTouchUpInside];
    [dViewButton2 setImage:[UIImage imageNamed:@"3dview.png"] forState:UIControlStateNormal];
    self.dViewButton2.clipsToBounds = YES;
    self.dViewButton2.layer.cornerRadius = ROUND_BUTTON_WIDTH_HEIGHT/2.0f;
    self.dViewButton2.layer.borderColor = [UIColor greenColor].CGColor;
    self.dViewButton2.layer.borderWidth = 0.5f;
    [self.view addSubview:dViewButton2];*/
    
    /*self.searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchBtn.frame = CGRectMake(210, 520, 40, 40);
    [self.searchBtn setBackgroundColor:[UIColor whiteColor]];
    [self.searchBtn addTarget:self action:@selector(removeMarkersButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    self.searchBtn.clipsToBounds = YES;
    self.searchBtn.layer.cornerRadius = 40/2.0f;
    self.searchBtn.layer.borderColor = [UIColor greenColor].CGColor;
    self.searchBtn.layer.borderWidth = 0.5f;
    [self.view addSubview:searchBtn];*/
    
    /*self.synchronisationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.synchronisationBtn.frame = CGRectMake(220, 20, 40, 40);
    [self.synchronisationBtn setBackgroundColor:[UIColor whiteColor]];
    //[self.synchronisationBtn addTarget:self action:@selector(removeMarkersButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [synchronisationBtn setImage:[UIImage imageNamed:@"sync.png"] forState:UIControlStateNormal];
    self.synchronisationBtn.clipsToBounds = YES;
    self.synchronisationBtn.layer.cornerRadius = 40/2.0f;
    self.synchronisationBtn.layer.borderColor = [UIColor greenColor].CGColor;
    self.synchronisationBtn.layer.borderWidth = 0.5f;
    [self.view addSubview:synchronisationBtn];*/
    
    self.settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingsBtn.frame = CGRectMake(270, 20, 40, 40);
    [self.settingsBtn setBackgroundColor:[UIColor whiteColor]];
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        //[self.sidebarButton setTarget:self.revealViewController];
        [self.settingsBtn addTarget:revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    [settingsBtn setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
    self.settingsBtn.clipsToBounds = YES;
    self.settingsBtn.layer.cornerRadius = 40/2.0f;
    self.settingsBtn.layer.borderColor = [UIColor greenColor].CGColor;
    self.settingsBtn.layer.borderWidth = 0.5f;
    [self.view addSubview:settingsBtn];
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 5.4;
    [removeMarkersBtn.layer addAnimation:animation forKey:nil];
    [routeBtn.layer addAnimation:animation forKey:nil];
    [dViewButton1.layer addAnimation:animation forKey:nil];
    
    [mapKitView setRegion:startRegion animated:YES];
    double zoom = [self getZoomLevel];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:35.6833
                                                            longitude:139.6833
                                                                 zoom:zoom];
    self.googleMapsView.buildingsEnabled = NO;
    self.googleMapsView.camera = camera;
    googleMapsView.myLocationEnabled = YES;
    googleMapsView.settings.compassButton = YES;
    
    mapKitView.delegate = self;
    googleMapsView.delegate = self;
    
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Please enable location services");
        return;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"Please authorize location services");
        return;
    }
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //streetView = [[GMSPanoramaView alloc] initWithFrame:self.streetView.bounds];
    //[streetView moveNearCoordinate:CLLocationCoordinate2DMake(-33.732, 150.312)];
    //self.view.frame = streetView.frame;
    //[self.view addSubview:streetView];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0;
    [self.mapKitView addGestureRecognizer:lpgr];
    
    /*if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:@"comgooglemaps://?center=40.765819,-73.975866&zoom=14&views=traffic"]];
    } else {
        NSLog(@"Can't use comgooglemaps://");
    }*/
    
    
    if (self.mapTypeSatellite == YES) {
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
    
    //SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        //[self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    if (trafficMode == YES) {
        googleMapsView.trafficEnabled = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (double)getZoomLevel {
    CLLocationDegrees longitudeDelta;
    longitudeDelta = mapKitView.region.span.longitudeDelta;
    CGFloat mapWidthInPixels;
    mapWidthInPixels = mapKitView.bounds.size.width;
    double zoomScale = longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * mapWidthInPixels);
    double zoomer = (MAX_GOOGLE_LEVELS - log2(zoomScale)) + 1.0;
    return zoomer;
}

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapKitView centerCoordinate:(CLLocationCoordinate2D)centerCoordinate andZoomLevel:(NSUInteger)zoomLevel {
    // convert center coordinate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = self.mapKitView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated {
    zoomLevel = MIN(zoomLevel, 28);
    
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self.mapKitView centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    [mapKitView setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"Please authorize location services");
        return;
    }
    NSLog(@"CLLocationManager error: %@", error.localizedFailureReason);
    UIAlertView *errorAlert = [[UIAlertView alloc] init];
    [errorAlert show];
    NSLog(@"Error: %@", error.description);
    return;
}

- (void)mapView:(MKMapView *)mapKitView regionWillChangeAnimated:(BOOL)animated {
    mapRegion = self.mapKitView.region;
}

- (void)mapView:(MKMapView *)mapKitView regionDidChangeAnimated:(BOOL)animated {
    if (syncMode == YES) {
        MKCoordinateRegion newRegion;
        newRegion = self.mapKitView.region;
        double zoomLevel = [self getZoomLevel];
        GMSCameraPosition *camera1 = [GMSCameraPosition cameraWithLatitude:self.mapKitView.region.center.latitude longitude:self.mapKitView.region.center.longitude zoom:zoomLevel];
        googleMapsView.camera = camera1;
    }
}

- (void)mapView:(GMSMapView *)googleMapsView willMove:(BOOL)gesture {
    googleMapCamera = self.googleMapsView.camera;
}

- (void)mapView:(GMSMapView *)googleMapsView didChangeCameraPosition:(GMSCameraPosition *)position {
    if (trafficMode == YES) {
        self.googleMapsView.trafficEnabled = YES;
    }
    //NSLog(@"here");
    //MKCoordinateRegion previousRegion = mapKitView.region;
    /*MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(position.target.latitude, position.target.longitude), 10000, 10000);
    [mapKitView setRegion:newRegion animated:YES];
     */
    //CLLocationCoordinate2D centerCoord = {self.googleMapsView.myLocation.coordinate.latitude, self.googleMapsView.myLocation.coordinate.longitude};
    //[self setCenterCoordinate:centerCoord zoomLevel:ZOOM_LEVEL animated:YES];
}

- (void)addAnnotation:(CLPlacemark *)placemark {
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
    point.title = [placemark.addressDictionary objectForKey:@"Street"];
    point.subtitle = [placemark.addressDictionary objectForKey:@"City"];
    [self.mapKitView addAnnotation:point];
}

/*- (IBAction)routeButtonPressed:(UIButton *)sender {
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    MKPlacemark *placemark =  [[MKPlacemark alloc] initWithPlacemark:thePlacemark];
    [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark: placemark]];
    directionsRequest.transportType = MKDirectionsTransportTypeWalking;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error 2");
        }
        else {
            routeDetails = response.routes.lastObject;
            [self.mapKitView addOverlay:routeDetails.polyline];
            
        }
    }];
}*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)synchronizationManager:(UIButton *)sender {
    //sync = false;
}

- (void)orientationChanged:(NSNotification *)notification {
    NSLog(@"fork");
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (IBAction)locationButton:(id)sender {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    //NSLog(@"location manager");
    self.mapKitView.showsUserLocation = YES;
    mapKitView.centerCoordinate = mapKitView.userLocation.location.coordinate;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(mapKitView.centerCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapKitView regionThatFits:viewRegion];
    [self.mapKitView setRegion:adjustedRegion animated:YES];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:mapKitView.centerCoordinate.latitude longitude:mapKitView.centerCoordinate.longitude zoom:15.5];
    [self.googleMapsView setCamera:camera];
}

- (void)locationButtonDidTap:(UIButton *)tappedButton {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    //NSLog(@"location manager");
    self.mapKitView.showsUserLocation = YES;
    mapKitView.centerCoordinate = mapKitView.userLocation.location.coordinate;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(mapKitView.centerCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapKitView regionThatFits:viewRegion];
    [self.mapKitView setRegion:adjustedRegion animated:YES];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:mapKitView.centerCoordinate.latitude longitude:mapKitView.centerCoordinate.longitude zoom:15.5];
    [self.googleMapsView setCamera:camera];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:self];
    }
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    self.mapKitView.showsPointsOfInterest = YES;
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    self.addressLabel.hidden = NO;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapKitView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapKitView convertPoint:touchPoint toCoordinateFromView:self.mapKitView];
    
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];

    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
    [self.geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSString *annTitle = @"Address unknown";
        
        if ([placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            
            annTitle = [NSString stringWithFormat:@"%@, %@", placemark.country, placemark.locality];
            //self.addressLabel.text = placemark.description;
            
            if ([placemark.areasOfInterest count] > 0) {
                NSString *areaOfInterest = [placemark.areasOfInterest objectAtIndex:0];
                self.addressLabel.text = areaOfInterest;
            } else {
                //NSLog(@"No area of interest was found");
            }
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = touchMapCoordinate;
            annotation.title = annTitle;
            annotation.subtitle = [NSString stringWithFormat:@"%@, %@, %@", placemark.subLocality, placemark.thoroughfare, placemark.description];
            address = placemark.subLocality;
            
            [self.mapKitView addAnnotation:annotation];
            
            GMSMarker *marker = [GMSMarker markerWithPosition:touchMapCoordinate];
            marker.flat = YES;
            [[GMSGeocoder geocoder] reverseGeocodeCoordinate:marker.position completionHandler:^(GMSReverseGeocodeResponse* response, NSError *error) {
                for (GMSAddress *addressGoogle in [response results]) {
                    marker.title = [NSString stringWithFormat:@"%@, %@", addressGoogle.locality, addressGoogle.locality];
                    marker.snippet = [NSString stringWithFormat:@"%@, %@, %@", addressGoogle.subLocality, addressGoogle.administrativeArea, addressGoogle.thoroughfare];
                }
            }];
            marker.map = googleMapsView;
            
            [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]];
        } else {
            NSLog(@"No placemarks");
        }
    }];
    
    self.addressLabel.text = [NSString stringWithFormat:@"Latitude: %.2f, Longitude: %.2f", touchMapCoordinate.latitude, touchMapCoordinate.longitude];
    
    CLLocationCoordinate2D coordinateArray[2];
    coordinateArray[0] = CLLocationCoordinate2DMake(touchMapCoordinate.latitude, touchMapCoordinate.longitude);
    coordinateArray[1] = CLLocationCoordinate2DMake(touchMapCoordinate.latitude, touchMapCoordinate.longitude);
    
    /*MKGeodesicPolyline *geodesic;
    geodesic = [MKGeodesicPolyline polylineWithCoordinates:&coordinateArray[0] count:2];
    [self.mapKitView addOverlay:geodesic];
     */
    
    MKPlacemark *source = [[MKPlacemark alloc] initWithCoordinate:coordinateArray[0] addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil]];
    MKMapItem *srcMapItem = [[MKMapItem alloc] initWithPlacemark:source];
    
    //[srcMapItem setName:@""];
    
    MKPlacemark *destination = [[MKPlacemark alloc] initWithCoordinate:coordinateArray[1] addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil]];
    
    MKMapItem *distMapItem = [[MKMapItem alloc] initWithPlacemark:destination];
    [distMapItem setName:@""];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:srcMapItem];
    [request setDestination:distMapItem];
    [request setTransportType:MKDirectionsTransportTypeWalking];
    
    MKDirections *direction = [[MKDirections alloc] initWithRequest:request];
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        //NSLog(@"response = %@", response);
        NSArray *arrRoutes = [response routes];
        [arrRoutes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MKRoute *rout = obj;
            MKPolyline *line = [rout polyline];
            [self.mapKitView addOverlay:line];
            //NSLog(@"Rout Name : %@",rout.name);
            //NSLog(@"Total Distance (in Meters) :%f",rout.distance);
            
            NSArray *steps = [rout steps];
            
            //NSLog(@"Total Steps : %d",[steps count]);
            
            [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                //NSLog(@"Rout Instruction : %@",[obj instructions]);
                //NSLog(@"Rout Distance : %f",[obj distance]);
            }];
        }];
        /*if (!error) {
            for (MKRoute *route in [response routes]) {
                [mapKitView addOverlay:[route polyline] level:MKOverlayLevelAboveRoads];
            }
        }*/
    }];
    
    /*GMSMutablePath *path = [GMSMutablePath path];
    [path addCoordinate:CLLocationCoordinate2DMake(@(coordinateArray[0].latitude).doubleValue,@(coordinateArray[0].longitude).doubleValue)];
    [path addCoordinate:CLLocationCoordinate2DMake(@(coordinateArray[1].latitude).doubleValue,@(coordinateArray[1].longitude).doubleValue)];
    
    GMSPolyline *rectangle = [GMSPolyline polylineWithPath:path];
    rectangle.strokeWidth = 2.f;
    rectangle.map = googleMapsView;*/
    
    //NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?//origin=ahmedabad&destination=%@", self.city]];
    
    
}

/*- (void)findDirectionsFrom:(MKMapItem *)source
                        to:(MKMapItem *)destination
{
    //provide loading animation here
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = source;
    request.transportType = MKDirectionsTransportTypeAutomobile;
    request.destination = destination;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    __block typeof(self) weakSelf = self;
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             NSLog(@"Error is %@",error);
         } else {
             //do something about the response, like draw it on map
             MKRoute *route = [response.routes firstObject];
             [self.mapKitView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
         }
     }];
}*/

/*- (void)showHideNavbar:(id)sender {
    if (self.navigationController.navigationBar.hidden != YES) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.removeMarkersBtn.hidden = YES;
        self.routeBtn.hidden = YES;
        self.dViewButton1.hidden = YES;
    }
    else if (self.navigationController.navigationBar.hidden == YES) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.removeMarkersBtn.hidden = NO;
        self.routeBtn.hidden = NO;
        self.dViewButton1.hidden = NO;
    }
    
    if (self.addressLabel.hidden == NO) {
        self.addressLabel.hidden = YES;
    } else {
        self.addressLabel.hidden = NO;
    }
}*/

- (void)removeMarkersButtonDidTap:(UIButton *)tappedButton {
    id userLocation = [mapKitView userLocation];
    [mapKitView removeAnnotations:mapKitView.annotations];
    //[mapKitView removeOverlay:self.line];
    
    if (userLocation != nil) {
        [mapKitView addAnnotation:userLocation];
    }
    
    [googleMapsView clear];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapKitView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        //self.addressLabel.text = @"here!";
        MKPolylineRenderer* aView = [[MKPolylineRenderer alloc]initWithOverlay:overlay] ;
        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        aView.lineWidth = 10;
        NSLog(@"HER EHERE");
        return aView;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapKitView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapKitView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    //[self performSegueWithIdentifier:@"DetailsIphone" sender:view];
    DetailsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailsPopover"];
    //DetailsViewController *controller = [[DetailsViewController alloc] initWithNibName:@"DetailsPopover" bundle:nil];
    //DetailsViewController.latid = self.mapKitView.region.center.latitude;
    
    [self.navigationController pushViewController:controller animated:YES];
    //NSLog(@"buttonbutton");
}

- (void)mapView:(MKMapView *)mapKitView didSelectAnnotationView:(MKAnnotationView *)view {
    //[mapKitView deselectAnnotation:view.annotation animated:YES];
    //DetailsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailsPopover"];
    //[self.navigationController pushViewController:controller animated:YES];
    //controller.annotation = view.annotation;
}

- (void)dViewButtonDidTap2:(UIButton *)tappedButton {
    self.googleMapsView.buildingsEnabled = YES;
    [googleMapsView animateToViewingAngle:45];
}

- (void)dViewButtonDidTap1:(UIButton *)tappedButton {
    self.mapKitView.showsBuildings = YES;
    MKMapCamera *mapCamera = [[MKMapCamera alloc] init];
    mapCamera.centerCoordinate = mapKitView.centerCoordinate;
    mapCamera.pitch = 45;
    mapCamera.altitude = 200;
    //mapCamera.heading = 45;
    
    self.mapKitView.camera = mapCamera;
}

@end