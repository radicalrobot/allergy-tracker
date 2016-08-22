//
//  DataManager.h
//  AllergyTracker
//
//  Created by Emily Toop on 22/08/2016.
//  Copyright © 2016 Radical Robot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Incidence.h"
#import "Interaction.h"
#import <MagicalRecord/MagicalRecord.h>

@protocol DataManager <NSObject>

+(void)setup;
+(void)cleanup;

+(BOOL)isFirstRun;

+(NSInteger)numberOfIncidentsWithName:(NSString*)name betweenDate:(NSDate*)startDate endDate:(NSDate*)endDate;
+(NSInteger)numberOfSelectedSymptoms;

+(NSArray *)allIncidents;
+(NSArray*)companionItemsForIncidenceWithName:(NSString*)name;

+(void)saveIncidence:(Incidence*)incidence withCompletion:(MRSaveCompletionHandler)completion;

@end
