//
//  SearchListViewController.h
//  Parallel Maps
//
//  Created by Anastasiya on 3/24/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ViewController.h"

@interface SearchListViewController : UITableViewController <UITextFieldDelegate, UISearchBarDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray *places;

@end
