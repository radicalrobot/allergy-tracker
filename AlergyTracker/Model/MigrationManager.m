//
//  MigrationManager.m
//  AlergyTracker
//
//  Created by Emily Toop on 24/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "MigrationManager.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "Incidence+Extras.h"

@implementation MigrationManager

+(instancetype) sharedInstance {
    
    static dispatch_once_t once;
    static id _sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [MigrationManager new];
    });
    return _sharedInstance;
}

-(void)migrateFromVersion:(NSString *)version {
    NSArray *actions = [Incidence MR_findAll];
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        Incidence *localIncidence;
        for(Incidence *incidence in actions) {
            localIncidence = [incidence MR_inContext:localContext];
            if([localIncidence.type isEqualToString:@"attack"]) {
                localIncidence.type = @"sneeze";
            }
            if(!localIncidence.uuid) {
                localIncidence.uuid = [[NSUUID UUID] UUIDString];
            }
        }
    }];
}

@end
