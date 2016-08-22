//
//  iCloudDataManager.m
//  AllergyTracker
//
//  Created by Emily Toop on 22/08/2016.
//  Copyright © 2016 Radical Robot. All rights reserved.
//

#import "iCloudDataManager.h"

#import <CloudKit/CloudKit.h>

@interface iCloudDataManager()

@property (nonatomic, strong) CKContainer *container;
@property (nonatomic, strong) CKDatabase *publicDB;
@property (nonatomic, strong) CKDatabase *privateDB;

@end

@implementation iCloudDataManager

-(NSArray *)companionItemsForIncidenceWithName:(NSString *)name {
    return nil;
}

-(void)cleanup {
    
}

-(NSArray *)allIncidents {
    return nil;
}

-(void)setup {
    _container = [CKContainer defaultContainer];
    _publicDB = [_container publicCloudDatabase];
    _privateDB = [_container privateCloudDatabase];
}

-(NSInteger)numberOfIncidentsWithName:(NSString *)name betweenDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    return 0;
}

-(BOOL)isFirstRun {
    return NO;
}

-(NSInteger)numberOfSelectedSymptoms {
    return 0;
}

@end
