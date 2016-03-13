//
//  DataManager.m
//  AllergyTracker
//
//  Created by Emily Toop on 18/05/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "DataManager.h"

#import "MigrationManager.h"
#import "Symptom+Extras.h"
#import "MagicalRecord+BackgroundTask.h"


@implementation DataManager

+(void)setup {
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [[self class] setupData];
}

+(void)cleanup {
    [MagicalRecord cleanUp];
}

+(void)saveIncidence:(Incidence *)incidence withCompletion:(MRSaveCompletionHandler)completion {
    [MagicalRecord saveOnBackgroundThreadWithBlock:^(NSManagedObjectContext *localContext) {
        Incidence *localIncidence = [incidence MR_inContext:localContext];
        localIncidence.notes = incidence.notes;
        localIncidence.time = incidence.time;
    } completion:completion];
}

+(NSInteger)numberOfIncidentsWithName:(NSString*)name betweenDate:(NSDate*)startDate endDate:(NSDate*)endDate {
    return [Incidence MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"time >= %@ && time <= %@ && type=%@", startDate, endDate,name]].integerValue;
    
}

+(NSArray *)companionItemsForIncidenceWithName:(NSString *)name {
    NSInteger numberOfOccurrances = [Interaction MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"name=%@", name]].integerValue;
    NSMutableArray *results = [NSMutableArray array];
    if(numberOfOccurrances > 0) {
        // this is an interaction - get the interaction names and return as array
        NSArray *allInteractions = [Interaction MR_findAllSortedBy:@"name" ascending:YES];
        [allInteractions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [results addObject:((Interaction*)obj).name];
        }];
    }
    else {
        // this is a symptom - get the symptom names and return as array
        NSArray *allSymptoms = [Symptom MR_findAllSortedBy:@"name" ascending:YES];
        [allSymptoms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [results addObject:((Symptom*)obj).name];
        }];
    }
    
    return results;
}

+(NSInteger)numberOfSelectedSymptoms {
    return [Symptom MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"selected=YES"]].integerValue;
}

+(BOOL)isFirstRun {
    return [[self class] numberOfSelectedSymptoms] == 0;
}


+(void)setupData {
    NSArray *symptoms = @[@"wheezing",
                          @"vomiting",
                          @"hives",
                          @"diarrhea",
                          @"itchy skin",
                          @"rash",
                          @"swollen throat",
                          @"low blood pressure",
                          @"abdominal pain",
                          @"headaches",
                          @"anxiety",
                          @"itchy eye",
                          @"watery eye",
                          @"swelling",
                          @"nausea",
                          @"dizziness",
                          @"nosebleed",
                          @"itchy nose",
                          @"runny nose",
                          @"stuffy nose",
                          @"sneeze",
                          @"cough",
                          @"conjunctivitis"];
    
    NSArray *interactions = @[@"Dairy",
                              @"Eggs",
                              @"Wheat",
                              @"Nuts",
                              @"Fish",
                              @"Shellfish",
                              @"Soy",
                              @"Pollen",
                              @"Mould",
                              @"Dog",
                              @"Cat",
                              @"Dust",
                              @"Alcohol"];
    
    [MagicalRecord saveOnBackgroundThreadWithBlock:^(NSManagedObjectContext *localContext) {
        for(NSString *symptomName in symptoms) {
            Symptom *symptom = [Symptom MR_findFirstByAttribute:@"name" withValue:symptomName inContext:localContext];
            if(!symptom){
                symptom = [Symptom MR_createEntityInContext:localContext];
                symptom.name = symptomName;
            }
        }
        
        for(NSString *interactionName in interactions) {
            Interaction *interaction = [Interaction MR_findFirstByAttribute:@"name" withValue:interactionName inContext:localContext];
            if(!interaction){
                interaction = [Interaction MR_createEntityInContext:localContext];
                interaction.name = interactionName;
            }
        }
    }];
    
    [[MigrationManager sharedInstance] migrateFromVersion:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
}

@end
