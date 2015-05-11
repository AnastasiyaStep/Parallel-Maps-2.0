//
//  RouteStepsViewController.h
//  Parallel Maps
//
//  Created by Anastasiya on 4/17/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewController.h"
#import <MapKit/MapKit.h>

@class RouteStepsViewController;
@protocol RouteStepsViewControllerDelegate <NSObject>
- (void)didRouteInfoViewControllerClosed:(RouteStepsViewController*)controller;
@end

@interface RouteStepsViewController : UIViewController

@property (nonatomic, strong) NSArray *steps;
@property (nonatomic, strong) id<RouteStepsViewControllerDelegate> delegate;
@property (strong, nonatomic) MKRoute *selectedRoute;

@end