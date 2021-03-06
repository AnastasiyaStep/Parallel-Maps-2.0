//
//  ViewController.h
//  Parallel Maps
//
//  Created by Anastasiya on 3/9/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
//#import <SMCalloutView/SMCalloutView.h>
#import "DetailsViewController.h"
#import "SettingsViewController.h"
#import "RouteStepsViewController.h"

#import "GQTPointQuadTree.h"
#import "GQTPointQuadTreeChild.h"
#import "GQTPointQuadTreeItem.h"

@interface ViewController : UIViewController <GMSMapViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate> {
    CLGeocoder *geocoder, *geocoder1;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapKitView;
@property (strong, nonatomic) IBOutlet GMSMapView *googleMapsView;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLGeocoder *geocoder1;
@property (nonatomic, strong) UIButton *searchBtn, *routeBtn, *dViewButton1, *dViewButton2, *settingsBtn, *synchronisationBtn, *locateBtn;
@property (nonatomic, retain) MKPolyline* routeLine;
@property (nonatomic, retain) MKPolylineView* routeLineView;
@property (nonatomic, assign) CLLocationCoordinate2D from, to;
//@property (nonatomic, strong) NSArray *mapItemList;
@property (nonatomic, assign) MKCoordinateRegion boundingRegion;
@property NSMutableArray *detailSteps;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, retain) CLLocation *initialLocation;
@property (nonatomic, retain) NSString *googleTransportMode;
@property (nonatomic, assign) float lastSlidedValue;
@property (nonatomic, retain) UISlider *slider;

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(NSUInteger)zoomLevel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toolbarText;

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel: (NSUInteger)zoomLevel
                   animated:(BOOL)animated;

- (void)removeMarkersButtonDidTap:(UIButton *)tappedButton;

- (void)dViewButtonDidTap1:(UIButton *)tappedButton;

- (void)dViewButtonDidTap2:(UIButton *)tappedButton;

- (void)locationButtonDidTap:(UIButton *)tappedButton;

- (void)directionsFrom:(CLLocationCoordinate2D *)from
                    to:(CLLocationCoordinate2D *)to
              animated:(BOOL)animated;

- (void)addDirections:(NSDictionary *)json;

- (void)removeDirections;

- (void)dealloc;

@property (weak, nonatomic) IBOutlet UILabel *sen;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *detailsButton;

@end