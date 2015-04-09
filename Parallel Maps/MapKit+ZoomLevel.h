//
//  MapKit+ZoomLevel.h
//  Parallel Maps
//
//  Created by Anastasiya on 4/7/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void) setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                   zoomLevel:(NSUInteger)zoomLevel
                    animated:(BOOL)animated;

@end
