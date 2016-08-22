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

#import <MagicalRecord/MagicalRecord.h>
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
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        Incidence *incidence = [Incidence MR_createEntityInContext:localContext];
        CLLocation *location = [RRLocationManager currentLocation];
        incidence.latitude = @(location.coordinate.latitude);
        incidence.longitude = @(location.coordinate.longitude);
        incidence.time = now;
        if([shortcutItem.type isEqualToString:@"LogInteraction"]) {
            // log the interaction
            incidence.type = (NSString*)shortcutItem.userInfo[nameKey];
        } else if ([shortcutItem.type isEqualToString: @"AddMedication"]) {
            // log a medication
            incidence.type = @"Medication";
        } else {
            // log a location
            incidence.type = @"location";
        }
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        if(contextDidSave) {
            Incidence *newlyCreatedIncidence = [Incidence MR_findFirstByAttribute:@"time" withValue:now];
            
            NSArray *top2Incidents = [Incidence getTopIncidentsWithLimit:2];
            [QuickActions addTopIncidents: top2Incidents];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NewIncidenceCreated" object:nil];
            
            [[SEGAnalytics sharedAnalytics] track:@"Logged Incident"
                                       properties:@{ @"id": newlyCreatedIncidence.uuid,
                                                     @"name": newlyCreatedIncidence.type,
                                                     @"time": newlyCreatedIncidence.formattedTime,
                                                     @"latitude": newlyCreatedIncidence.latitude,
                                                     @"longitude": newlyCreatedIncidence.longitude,
                                                     @"notes": newlyCreatedIncidence.notes ? newlyCreatedIncidence.notes : [NSNull null],
                                                     @"writeSuccess": @(contextDidSave)}];
        }
    }];
    return YES;
}

@end
