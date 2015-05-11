//
//  MDDirectionService.h
//  Parallel Maps
//
//  Created by Anastasiya on 4/16/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDDirectionService : NSObject

- (void)setDirectionsQuery:(NSDictionary *)query
              withSelector:(SEL)selector
              withDelegate:(id)delegate;

- (void)retrieveDirections:(SEL)selector
              withDelegate:(id)delegate;

- (void)fetchedData:(NSData *)data
       withSelector:(SEL)selector
       withDelegate:(id)delegate;

@end