//
//  MainModel.h
//  Parallel Maps
//
//  Created by Anastasiya on 3/30/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h> 
#import <GoogleMaps/GoogleMaps.h>

@interface MainModel : NSObject

extern BOOL trafficMode, showLatLot, syncMode;
extern CLLocationDegrees addressLat, addressLong;
extern NSString *address;

@end