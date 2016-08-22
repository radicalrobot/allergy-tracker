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

@property (nonatomic, strong) CKDatabase *publicDB;

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
    _publicDB = [[CKContainer defaultContainer] publicCloudDatabase];
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

-(void)saveIncidence:(Incidence *)incidence withCompletion:(MRSaveCompletionHandler)completion {
    
}

@end
