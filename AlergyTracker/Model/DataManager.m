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
#import "Interaction+Extras.h"


@implementation DataManager

+(void)setup {
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [[self class] setupData];
}

+(void)cleanup {
    [MagicalRecord cleanUp];
}

+(void)saveIncidence:(Incidence *)incidence withCompletion:(MRSaveCompletionHandler)completion {
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        Incidence *localIncidence = [incidence MR_inContext:localContext];
        localIncidence.notes = incidence.notes;
        localIncidence.time = incidence.time;
    } completion:completion];
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
    
    __block Symptom *symptom;
    __block Interaction *interaction;
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        for(NSString *symptomName in symptoms) {
            symptom = [Symptom MR_findFirstByAttribute:@"name" withValue:symptomName inContext:localContext];
            if(!symptom){
                symptom = [Symptom MR_createInContext:localContext];
                symptom.name = symptomName;
            }
        }
        
        for(NSString *interactionName in interactions) {
            interaction = [Interaction MR_findFirstByAttribute:@"name" withValue:interactionName inContext:localContext];
            if(!interaction){
                interaction = [Interaction MR_createInContext:localContext];
                interaction.name = interactionName;
            }
        }
    }];
    
    [[MigrationManager sharedInstance] migrateFromVersion:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
}

@end
