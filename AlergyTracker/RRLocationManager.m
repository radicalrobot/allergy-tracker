//
//  RRLocationManager.m
//  AlergyTracker
//
//  Created by Emily Toop on 03/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "RRLocationManager.h"
#import <MagicalRecord/MagicalRecord.h>

#import "Incidence+Extras.h"
#import "MagicalRecord+BackgroundTask.h"

#import <Analytics.h>

@interface RRLocationManager ()

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation RRLocationManager

+(instancetype) sharedInstance {
    
    static dispatch_once_t once;
    static id _sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [RRLocationManager new];
    });
    return _sharedInstance;
}


-(instancetype)init{
    if(self = [super init]){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.pausesLocationUpdatesAutomatically = YES;
        _locationManager.activityType = CLActivityTypeFitness;
    }
    
    return self;
}

+(void)start {
    
    RRLocationManager *manager = [RRLocationManager sharedInstance];
    if ([manager.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [manager.locationManager requestAlwaysAuthorization];
    }
    [manager.locationManager startMonitoringSignificantLocationChanges];
}

+(CLLocation*)currentLocation {
    return [[[RRLocationManager sharedInstance] locationManager] location];
}


+(void)locationStringForLocation:(CLLocation *)location completionHandler:(void (^)(NSArray *, NSError *))completionHandler {
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:completionHandler];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    NSDate *time = currentLocation.timestamp;
    NSNumber *latitude = @(currentLocation.coordinate.latitude);
    NSNumber *longitude = @(currentLocation.coordinate.latitude);
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Incidence *location = [Incidence MR_createEntityInContext:localContext];
        location.latitude = latitude;
        location.longitude = longitude;
        location.time = time;
        location.type = @"location";
    } completion:^(BOOL success, NSError *error) {
        if(success) {
            Incidence *newlyCreatedIncidence = [Incidence MR_findFirstByAttribute:@"time" withValue:time];
            
            [[SEGAnalytics sharedAnalytics] track:@"Logged Location Change"
                                       properties:@{ @"id": newlyCreatedIncidence.uuid,
                                                     @"name": newlyCreatedIncidence.type,
                                                     @"time": newlyCreatedIncidence.formattedTime,
                                                     @"latitude": newlyCreatedIncidence.latitude,
                                                     @"longitude": newlyCreatedIncidence.longitude,
                                                     @"notes": newlyCreatedIncidence.notes ? newlyCreatedIncidence.notes : [NSNull null],
                                                     @"writeSuccess": @(success)}];
        } else {
            [[SEGAnalytics sharedAnalytics] track:@"Logged Location Change"
                                       properties:@{ @"id": [NSNull null],
                                                     @"name": @"location",
                                                     @"time": time,
                                                     @"latitude": latitude,
                                                     @"longitude": longitude,
                                                     @"notes": [NSNull null],
                                                     @"writeSuccess": @(success)}];
        }
    }];
}

@end
