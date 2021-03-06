//
//  MainModel.m
//  Parallel Maps
//
//  Created by Anastasiya on 3/30/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import "MainModel.h"

@implementation MainModel

    BOOL syncMode = YES, showLatLot = YES, trafficMode = NO, DMode = NO, shakeMode = YES, indoorMode = YES, syncFromMapKit = NO, syncFromGoogleMap = NO, searchSegue = NO, regionSave = NO, directions = NO, walkingMode = NO, drivingMode = YES, showKm = YES, drawRoute = YES, directionSearch = YES;
    CLLocationDegrees addressLat = 35.66, addressLong = 139.79;
    NSString *address = @"Unknown";
    BOOL mapTypeSatellite = NO, mapTypeHybrid = NO, mapTypeTerrain = NO, mapTypeRegular = NO;
    CLLocationCoordinate2D globalCoordinate, pinCoordinate;
    MKCoordinateRegion globalRegion;
    CLLocationCoordinate2D locationFrom, locationTo;
    GMSCoordinateBounds *bounds;
    CLLocationDirection mapAngle;
    NSArray *mapItemList;

@end