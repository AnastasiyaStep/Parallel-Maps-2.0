//
//  PageContentViewController.m
//  Parallel Maps
//
//  Created by Anastasiya on 4/24/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import "PageContentViewController.h"

@implementation PageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image = [UIImage imageNamed:self.imageFile];
    self.titleLabel.text = self.titleText;
}

@end
