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

@synthesize googleMapsView, mapKitView, geocoder, searchBtn, removeMarkersBtn, settingsBtn, sidebarButton, initialLocation;

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
    
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
    
    mapKitView.delegate = self;
    //mapKitView.showsUserLocation = YES;
    
    self.googleMapsView.buildingsEnabled = NO;
    googleMapsView.myLocationEnabled = YES;
    googleMapsView.settings.compassButton = YES;
    googleMapsView.delegate = self;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    //CGFloat screenHeight = screenRect.size.height;
    
    self.toolbarText.width = screenWidth;
    
    self.navigationController.toolbar.hidden = NO;
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
        
        /*if (DMode == YES) {
            googleMapsView.buildingsEnabled = YES;
            [googleMapsView animateToViewingAngle:45];
            //GMSCameraUpdate *camera = [GMSCameraUpdate zoomTo:17];
            //[googleMapsView animateWithCameraUpdate:camera];
            */
            /*self.mapKitView.showsBuildings = YES;
            MKMapCamera *mapCamera = [[MKMapCamera alloc] init];
            mapCamera.centerCoordinate = self.mapKitView.centerCoordinate;
            mapCamera.pitch = 45;
            mapCamera.altitude = 200;
            //mapCamera.heading = 45;
            self.mapKitView.camera = mapCamera;
            
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
    self.settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingsBtn.frame = CGRectMake(270, 20, 40, 40);
    [self.settingsBtn setBackgroundColor:[UIColor whiteColor]];
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.settingsBtn addTarget:revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
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
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0;
    [self.mapKitView addGestureRecognizer:lpgr];
    
    if (revealViewController) {
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    if (trafficMode == YES) {
        googleMapsView.trafficEnabled = YES;
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
    
    if (globalRegion.latitude) {
        //MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(globalRegion.latitude, globalRegion.longitude, 15);
        
    }
    
    [super viewDidLoad];
    
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
    //NSLog(@"location manager");
    self.mapKitView.showsUserLocation = YES;
    mapKitView.centerCoordinate = mapKitView.userLocation.location.coordinate;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(mapKitView.centerCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapKitView regionThatFits:viewRegion];
    [self.mapKitView setRegion:adjustedRegion animated:YES];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:mapKitView.centerCoordinate.latitude longitude:mapKitView.centerCoordinate.longitude zoom:15.5];
    [self.googleMapsView setCamera:camera];
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


#pragma mark - map change delegates

- (void)mapView:(MKMapView *)mapKitView regionWillChangeAnimated:(BOOL)animated {
    mapRegion = self.mapKitView.region;
}

- (void)mapView:(MKMapView *)mapKitView regionDidChangeAnimated:(BOOL)animated {
    double zoomLevel = [self getZoomLevel];
    syncFromMapKit = YES;
    
    if (mapRegion.center.latitude != self.mapKitView.region.center.latitude) {
        if (syncFromGoogleMap != YES) {
            if (syncMode == YES) {
                MKCoordinateRegion newRegion;
                newRegion = self.mapKitView.region;
        
                GMSCameraPosition *camera1 = [GMSCameraPosition cameraWithLatitude:self.mapKitView.region.center.latitude longitude:self.mapKitView.region.center.longitude zoom:zoomLevel];
                googleMapsView.camera = camera1;
            } else if (syncMode == NO){
                GMSCameraUpdate *camera2 = [GMSCameraUpdate zoomTo:zoomLevel];
                [googleMapsView animateWithCameraUpdate:camera2];
            }
        }
    }
    
    globalCoordinate = CLLocationCoordinate2DMake(self.mapKitView.region.center.latitude, self.mapKitView.region.center.longitude);
    syncFromMapKit = NO;
    
    MKCoordinateRegion globalRegion = self.mapKitView.region;
}

- (void)mapView:(GMSMapView *)googleMapsView didChangeCameraPosition:(GMSCameraPosition *)position {
    syncFromGoogleMap = YES;
    if (syncFromMapKit != YES) {
        if (syncMode == YES) {
            CLLocationCoordinate2D centerCoord = {position.target.latitude, position.target.longitude};
            [mapKitView setCenterCoordinate:centerCoord zoomLevel:self.googleMapsView.camera.zoom animated:NO];
        } else {
            [mapKitView setZoom:self.googleMapsView.camera.zoom mapView:mapKitView animated:NO];
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
    /*[mapKitView removeAnnotations:mapKitView.annotations];
    [mapKitView clearsContextBeforeDrawing];
    [googleMapsView clear];*/
    
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
            } else {
                //NSLog(@"No area of interest was found");
            }
            
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
        } else {
            NSLog(@"No placemarks");
        }
    }];
    
    self.toolbarText.title = [NSString stringWithFormat:@"Latitude: %.4f, Longitude: %.4f", touchMapCoordinate.latitude, touchMapCoordinate.longitude];
    
    CLLocation *initLoc = [[CLLocation alloc] initWithLatitude:mapKitView.userLocation.coordinate.latitude longitude:mapKitView.userLocation.coordinate.longitude];
    CLLocation *finLoc = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
    
    CLLocationCoordinate2D coordLoc[2] = {initLoc.coordinate, finLoc.coordinate};
    
    MKGeodesicPolyline *geoPol = [MKGeodesicPolyline polylineWithCoordinates:coordLoc count:2];
    [mapKitView addOverlay:geoPol];
    
    CLLocationDistance distance = [finLoc distanceFromLocation: initLoc];
    
    typedef struct GMSMapPoint GMSMapPoint;
    
    /*[mapKitView setCenterCoordinate:mapKitView.userLocation.coordinate animated:YES];
    
    NSString *baseUrl = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%@&sensor=true", initLoc.coordinate.latitude, initLoc.coordinate.longitude];
    
    NSURL *url = [NSURL URLWithString:[baseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLRequest *requestGoogle = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:requestGoogle queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error = nil;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        NSArray *routes = [result objectForKey:@"routes"];
        
        NSDictionary *firstRoute = [routes objectAtIndex:0];
        
        NSDictionary *leg =  [[firstRoute objectForKey:@"legs"] objectAtIndex:0];
        
        NSDictionary *end_location = [leg objectForKey:@"end_location"];
        double latitude = [[end_location objectForKey:@"lat"] doubleValue];
        double longitude = [[end_location objectForKey:@"lng"] doubleValue];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = coordinate;
        point.title =  [leg objectForKey:@"end_address"];
        point.subtitle = @"I'm here!!!";
        
        [self.mapKitView addAnnotation:point];
        
        NSArray *steps = [leg objectForKey:@"steps"];
        
        int stepIndex = 0;
        
        CLLocationCoordinate2D stepCoordinates[1  + [steps count] + 1];
        
        stepCoordinates[stepIndex] = mapKitView.userLocation.coordinate;
        
        for (NSDictionary *step in steps) {
            NSDictionary *start_location = [step objectForKey:@"start_location"];
            stepCoordinates[++stepIndex] = [self coordinateWithLocation:start_location];
            
            if ([steps count] == stepIndex){
                NSDictionary *end_location = [step objectForKey:@"end_location"];
                stepCoordinates[++stepIndex] = [self coordinateWithLocation:end_location];
            }
        }
        
        MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:stepCoordinates count:1 + stepIndex];
        [mapKitView addOverlay:polyLine];
        
        CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake((mapKitView.userLocation.location.coordinate.latitude + coordinate.latitude)/2, (mapKitView.userLocation.location.coordinate.longitude + coordinate.longitude)/2);
    }];*/
    
    
    GMSMutablePath *path = [GMSMutablePath path];
    [path addCoordinate:coordLoc[0]];
    [path addCoordinate:coordLoc[1]];
    
    GMSPolyline *rectangle = [GMSPolyline polylineWithPath:path];
    rectangle.strokeWidth = 2.f;
    rectangle.map = googleMapsView;
    
    MKPlacemark *source = [[MKPlacemark alloc] initWithCoordinate:mapKitView.userLocation.coordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil]];
    MKMapItem *srcMapItem = [[MKMapItem alloc] initWithPlacemark:source];
    [srcMapItem setName:@""];
    
    MKPlacemark *destination = [[MKPlacemark alloc] initWithCoordinate:touchMapCoordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil]];
    MKMapItem *distMapItem = [[MKMapItem alloc] initWithPlacemark:destination];
    [distMapItem setName:@""];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
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
            NSLog(@"Route Name : %@",rout.name);
            NSLog(@"Total Distance (in Meters) :%f",rout.distance);
            
            NSArray *steps = [rout steps];
            
            NSLog(@"Total Steps : %lu",(unsigned long)[steps count]);
            
            [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                //NSLog(@"Rout Instruction : %@",[obj instructions]);
                //NSLog(@"Rout Distance : %f",[obj distance]);
            }];
            NSString *time = [NSString stringWithFormat:@"%.2lf", rout.expectedTravelTime/60];
            self.toolbarText.title = [NSString stringWithFormat:@"%.2f miles -> %@ minutes", distance/1000, time];
        }];
        if (!error) {
            for (MKRoute *route in [response routes]) {
                [mapKitView addOverlay:[route polyline] level:MKOverlayLevelAboveRoads];
            }
        }
    }];
    
    //double width = GMSGeometryDistance(coordLoc[0], coordLoc[1]);
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

- (MKAnnotationView *)mapView:(MKMapView *)mapKitView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapKitView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    //[self performSegueWithIdentifier:@"DetailsIphone" sender:view];
    //UINavigationController *detailsNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"detailsNavController"];
    DetailsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailsPopover"];
    //DetailsViewController *controller = [[DetailsViewController alloc] initWithNibName:@"DetailsPopover" bundle:nil];
    //[detailsNavController pushViewController:controller animated:YES];
    //[detailsNavController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    NSLog(@"details");
    //[self presentViewController:detailsNavController animated:YES completion:NULL];
    [self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    //[self presentModalViewController:controller animated:YES];
    [self presentViewController:controller animated:YES completion:nil];
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

- (void)removeMarkersButtonDidTap:(UIButton *)tappedButton {
    id userLocation = [mapKitView userLocation];
    [mapKitView removeAnnotations:mapKitView.annotations];
    //[mapKitView removeOverlay:self.line];
    
    if (userLocation != nil) {
        [mapKitView addAnnotation:userLocation];
    }
    [googleMapsView clear];
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


- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:self];
    }
}

- (void)orientationChanged:(NSNotification *)notification {
    NSLog(@"fork");
}

@end