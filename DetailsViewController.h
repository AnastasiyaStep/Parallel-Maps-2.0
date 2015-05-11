//
//  DetailsViewController.h
//  Parallel Maps
//
//  Created by Anastasiya on 3/20/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#ifndef Parallel_Maps_DetailsViewController_h
#define Parallel_Maps_DetailsViewController_h

#import "ViewController.h"

@class DetailsViewController;
@protocol DetailsViewControllerDelegate <NSObject>
- (void)didDetailsViewControllerClosed:(DetailsViewController*)controller;
@end

@interface DetailsViewController : UIViewController <GMSMapViewDelegate, MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *zipCode;
@property (nonatomic, strong) id<DetailsViewControllerDelegate> delegate;

@end

#endif
