//
//  RRLocationManager.h
//  AlergyTracker
//
//  Created by Emily Toop on 03/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface RRLocationManager : NSObject<CLLocationManagerDelegate>

+(instancetype) sharedInstance;
+(CLLocation*) currentLocation;
+(void) start;
+(void)locationStringForLocation:(CLLocation*)location completionHandler:(void (^)(NSArray *placemarks, NSError *error))completionHandler;

@end
