//
//  DirectionsManager.m
//  Parallel Maps
//
//  Created by Anastasiya on 4/15/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import "DirectionsManager.h"
#import "MDDirectionService.h"
#import "ViewController.h"

NSString *const DAMDestinationMarkerLabel = @"DESTINATION_MARKER";

const float polylineDefaultWidth = 5.0f;
const float mapBoundsPadding = 50;

GMSMapView *mapView;
GMSPolyline *routeLine;
GMSMarker *startMarker;
GMSMarker *finishMarker;
ViewController *mapController;

@implementation DirectionsManager

- (BOOL)searchRouteGoogleDirections:(CLLocationCoordinate2D)from
                                 to:(CLLocationCoordinate2D)to {
    [self removeDirections];
    
    NSDictionary *query = @{@"origin": [NSString stringWithFormat:@"%f,%f", from.latitude, from.longitude],
                            @"destination": [NSString stringWithFormat:@"%f,%f", to.latitude, to.longitude],
                            @"sensor": @"false",
                            @"language": @"ja",
                            @"mode": @"walking"};
    
    MDDirectionService *mds = [[MDDirectionService alloc] init];
    SEL selector = @selector(addDirections:);
    [mds setDirectionsQuery:query withSelector:selector withDelegate:self];
    
    NSLog(@"success!");
    return YES;
}

- (void) addDirections:(NSDictionary *)json {
    if (json == nil || json.count <= 0) {
        return;
    }
    
    NSArray *array = [json objectForKey:@"routes"];
    if (array == nil || array.count <= 0) {
        return;
    }
    
    NSDictionary *routes = array[0];
    if (routes == nil) {
        return;
    }
    
    NSDictionary *route = [routes objectForKey:@"overview_polyline"];
    if (route == nil) {
        return;
    }
    
    NSString *overview_route = [route objectForKey:@"points"];
    GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
    routeLine = [GMSPolyline polylineWithPath:path];
    routeLine.strokeColor = [UIColor redColor];
    routeLine.strokeWidth = polylineDefaultWidth;
    
    ViewController *mainController = [[ViewController alloc] init];
    
    if (routeLine != nil) {
        routeLine.map = mainController.googleMapsView;
    }
    
    if ([path count] != 1) {
        CLLocationCoordinate2D start = [path coordinateAtIndex:0];
        startMarker = [GMSMarker markerWithPosition:start];
        startMarker.map = mainController.googleMapsView;
        NSLog(@"at least");
    }
    
    CLLocationCoordinate2D goal = [path coordinateAtIndex:([path count]-1)];
    finishMarker = [GMSMarker markerWithPosition:goal];
    finishMarker.map = mainController.googleMapsView;
    //another marker
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
    GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitBounds:bounds withPadding:mapBoundsPadding];
    [mainController.googleMapsView moveCamera:cameraUpdate];
}

- (void)removeDirections {
    routeLine.map = nil;
    startMarker.map = nil;
    finishMarker.map = nil;
}

@end
