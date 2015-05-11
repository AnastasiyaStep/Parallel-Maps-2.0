//
//  MDDirectionService.m
//  Parallel Maps
//
//  Created by Anastasiya on 4/16/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import "MDDirectionService.h"

@implementation MDDirectionService{
@private
    BOOL _sensor;
    BOOL _alternatives;
    NSURL *_directionsURL;
}

static NSString *kMDDirectionsURL = @"http://maps.googleapis.com/maps/api/directions/json?";

- (void)setDirectionsQuery:(NSDictionary *)query withSelector:(SEL)selector withDelegate:(id)delegate {
    NSString *origin = [query objectForKey:@"origin"];
    NSString *destination = [query objectForKey:@"destination"];
    NSString *sensor = [query objectForKey:@"sensor"];
    NSString *language = [query objectForKey:@"language"];
    NSString *mode = [query objectForKey:@"mode"];
    
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@&origin=%@&destination=%@&sensor=%@&language=%@&mode=%@",kMDDirectionsURL,origin,destination, sensor, language, mode];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    _directionsURL = [NSURL URLWithString:url];
    [self retrieveDirections:selector withDelegate:delegate];
}

- (void)retrieveDirections:(SEL)selector withDelegate:(id)delegate {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *data = [NSData dataWithContentsOfURL:_directionsURL];
        [self fetchedData:data withSelector:selector withDelegate:delegate];
    });
}

- (void)fetchedData:(NSData *)data withSelector:(SEL)selector withDelegate:(id)delegate {
    if (data == nil) {
        //alert about internet service
    }
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [delegate performSelector:selector withObject:json];
}

@end