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

#import "GQTPointQuadTree.h"
#import "GQTPointQuadTreeChild.h"
#import "GQTPointQuadTreeItem.h"

@interface ViewController : UIViewController <GMSMapViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate> {
    CLGeocoder *geocoder;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapKitView;
@property (strong, nonatomic) IBOutlet GMSMapView *googleMapsView;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) UIButton *removeMarkersBtn, *locationBtn1, *locationBtn2, *searchBtn, *routeBtn, *dViewButton1, *dViewButton2, *settingsBtn, *synchronisationBtn;
@property (nonatomic, retain) MKPolyline* routeLine;
@property (nonatomic, retain) MKPolylineView* routeLineView;
@property (nonatomic, assign) CLLocationCoordinate2D from, to;
@property (nonatomic, strong) NSArray *mapItemList;
@property (nonatomic, assign) MKCoordinateRegion boundingRegion;
@property NSMutableArray *detailSteps;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, retain) CLLocation *initialLocation;

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

@end