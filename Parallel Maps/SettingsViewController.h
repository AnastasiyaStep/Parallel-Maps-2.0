//
//  SettingsViewController.h
//  Parallel Maps
//
//  Created by Anastasiya on 3/23/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "MainModel.h"

@interface SettingsViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UISwitch *indoorSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *shakeSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *showLatLotSwitch;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
