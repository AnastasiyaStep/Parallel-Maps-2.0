//
//  SidebarViewController.h
//  Parallel Maps
//
//  Created by Anastasiya on 3/31/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SidebarViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UISwitch *trafficModeSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *dViewSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *syncSwitch;

@end
