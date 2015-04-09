//
//  StreetViewController.h
//  Parallel Maps
//
//  Created by Anastasiya on 4/1/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewController.h"

@class GMSPanoramaService, GMSPanorama;

@interface StreetViewController : UIViewController <GMSPanoramaViewDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

-(void)getStreetViewForCoordinate:(CLLocationCoordinate2D)coordinate;

@end
