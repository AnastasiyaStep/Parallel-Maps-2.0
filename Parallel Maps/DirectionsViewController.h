//
//  DirectionsViewController.h
//  Parallel Maps
//
//  Created by Anastasiya on 4/1/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DirectionsViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UITextField *from;
@property (strong, nonatomic) IBOutlet UITextField *to;
@property (assign) BOOL success;

@end
