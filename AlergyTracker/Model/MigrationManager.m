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
    NSArray *actions = [Incidence MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"type='attack'"]];
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        Incidence *localIncidence;
        for(Incidence *incidence in actions) {
            localIncidence = [incidence MR_inContext:localContext];
            localIncidence.type = @"Sneeze";
        }
    }];
}

@end
