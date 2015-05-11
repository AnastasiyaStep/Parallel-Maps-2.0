//
//  DirectionsManager.h
//  Parallel Maps
//
//  Created by Anastasiya on 4/15/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MapKit.h>

@interface DirectionsManager : NSObject

UIKIT_EXTERN NSString *const DAMDestinationMarkerLabel;

- (BOOL)searchRouteGoogleDirections:(CLLocationCoordinate2D)from
                                 to:(CLLocationCoordinate2D)to;

- (void)addDirections:(NSDictionary *)json;

- (void)removeDirections;

@end
