//
//  RRLocationManager.m
//  AlergyTracker
//
//  Created by Emily Toop on 03/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "RRLocationManager.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>

#import "Incidence+Extras.h"

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
    __block Incidence *location;
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        location = [Incidence MR_createEntity];
        location.latitude = @(currentLocation.coordinate.latitude);
        location.longitude = @(currentLocation.coordinate.longitude);
        location.time = currentLocation.timestamp;
        location.type = @"location";
    } completion:nil];
}

@end
