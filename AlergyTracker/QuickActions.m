//
//  QuickActions.m
//  AllergyTracker
//
//  Created by Emily Toop on 28/03/2016.
//  Copyright © 2016 Radical Robot. All rights reserved.
//

#import "QuickActions.h"
#import "Incidence+Extras.h"
#import "LocalDataManager.h"
#import "RRLocationManager.h"
#import "RRDataManager.h"

#import <Analytics.h>

@implementation QuickActions

static NSString* nameKey = @"name";

+(void)addTopIncidents: (NSArray*) incidents {
    UIApplication *application = [UIApplication sharedApplication];
    NSMutableArray *shortcutItems = [NSMutableArray array];
    for (NSString* incidentName in incidents) {
        UIMutableApplicationShortcutItem *shortcutItem = [[UIMutableApplicationShortcutItem alloc] initWithType:@"LogInteraction"
                                                                                                 localizedTitle:[NSString stringWithFormat:@"Log %@", [incidentName capitalizedString] ]];
        shortcutItem.userInfo = @{nameKey: incidentName};
        [shortcutItems insertObject:shortcutItem atIndex:0];
    }
    application.shortcutItems = shortcutItems;
}

+(BOOL) handleShortcut: (UIApplicationShortcutItem*) shortcutItem {
    NSString *shortcutType = shortcutType = shortcutItem.type;
    NSDate *now = [NSDate date];
    CLLocation *location = [RRLocationManager currentLocation];
    NSString* type;
    if([shortcutItem.type isEqualToString:@"LogInteraction"]) {
        // log the interaction
        type = (NSString*)shortcutItem.userInfo[nameKey];
    } else if ([shortcutItem.type isEqualToString: @"AddMedication"]) {
        // log a medication
        type = @"Medication";
    } else {
        // log a location
        type = @"location";
    };
    
    [[RRDataManager currentDataManager] createIncident:now latitude:@(location.coordinate.latitude) longitude:@(location.coordinate.longitude) type:type onSuccess:^(Incidence *incidence) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewIncidenceCreated" object:nil];
    }];
    return YES;
}

@end
