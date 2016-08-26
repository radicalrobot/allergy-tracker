//
//  DataManager.m
//  AllergyTracker
//
//  Created by Emily Toop on 18/05/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "LocalDataManager.h"

#import "Symptom+Extras.h"
#import "MagicalRecord+BackgroundTask.h"
#import "Incidence+Extras.h"
#import "QuickActions.h"
#import <Analytics.h>


@implementation LocalDataManager

@synthesize initialized;

-(instancetype)init {
    if(self = [super init]) {
        self.initialized = NO;
    }

    return self;
}

-(void)setup {
    NSLog(@"Setting up local data manager");
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [self setupData];
    self.initialized = YES;
}

-(void)cleanup {
    [MagicalRecord cleanUp];
}

-(void)saveIncidence:(Incidence *)incidence withCompletion:(MRSaveCompletionHandler)completion {
    [MagicalRecord saveOnBackgroundThreadWithBlock:^(NSManagedObjectContext *localContext) {
        Incidence *localIncidence = [incidence MR_inContext:localContext];
        if(!localIncidence) {
            localIncidence = [Incidence MR_createEntityInContext:localContext];
            localIncidence.type = incidence.type;
        }
        localIncidence.notes = incidence.notes;
        localIncidence.time = incidence.time;
    } completion:completion];
}

-(NSInteger)numberOfIncidentsWithName:(NSString*)name betweenDate:(NSDate*)startDate endDate:(NSDate*)endDate {
    return [Incidence MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"time >= %@ && time <= %@ && type=%@", startDate, endDate,name] inContext:[NSManagedObjectContext MR_context]].integerValue;
    
}

-(NSArray *)allIncidents {
    NSMutableArray *results = [NSMutableArray array];
    NSArray *allInteractions = [Interaction MR_findAllSortedBy:@"name" ascending:YES];
    [allInteractions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [results addObject:((Interaction*)obj).name];
    }];
    NSArray *allSymptoms = [Symptom MR_findAllSortedBy:@"name" ascending:YES];
    [allSymptoms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [results addObject:((Symptom*)obj).name];
    }];
    return results;
}

-(NSArray *)companionItemsForIncidenceWithName:(NSString *)name {
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

-(NSInteger)numberOfSelectedSymptoms {
    return [Symptom MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"selected=YES"]].integerValue;
}

-(BOOL)isFirstRun {
    return [self numberOfSelectedSymptoms] == 0;
}


-(void)setupData {
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
    
    [[RRDataManager currentDataManager] migrateFromVersion:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
}

-(Incidence*)createNewEmptyIncident {
    return [Incidence MR_createEntity];
}

-(void) createIncident: (NSDate*) now latitude:(NSNumber*) latitude longitude:(NSNumber*) longitude type:(NSString*) incidenceType onSuccess:(void (^)(Incidence*))successBlock {
    [MagicalRecord saveOnBackgroundThreadWithBlock:^(NSManagedObjectContext *localContext) {
        Incidence *incidence = [Incidence MR_createEntityInContext:localContext];
        incidence.latitude = latitude;
        incidence.longitude = longitude;
        incidence.time = now;
        incidence.type = incidenceType;
    } completion:^(BOOL success, NSError *error) {
        if(success) {
            Incidence *newlyCreatedIncidence = [Incidence MR_findFirstByAttribute:@"time" withValue:now];
            if(successBlock) {
                successBlock(newlyCreatedIncidence);
            }
            
            NSArray *top2Incidents = [Incidence getTopIncidentsWithLimit:2];
            [QuickActions addTopIncidents: top2Incidents];
            
            [[SEGAnalytics sharedAnalytics] track:@"Logged Incident"
                                       properties:@{ @"id": newlyCreatedIncidence.uuid,
                                                     @"name": newlyCreatedIncidence.type,
                                                     @"time": newlyCreatedIncidence.formattedTime,
                                                     @"latitude": newlyCreatedIncidence.latitude,
                                                     @"longitude": newlyCreatedIncidence.longitude,
                                                     @"notes": newlyCreatedIncidence.notes ? newlyCreatedIncidence.notes : [NSNull null],
                                                     @"writeSuccess": @(success)}];
        } else {
            [[SEGAnalytics sharedAnalytics] track:@"Logged Incident"
                                       properties:@{ @"id": [NSNull null],
                                                     @"name": incidenceType,
                                                     @"time": now,
                                                     @"latitude": latitude,
                                                     @"longitude": longitude,
                                                     @"notes": [NSNull null],
                                                     @"writeSuccess": @(success)}];
        }
    }];
}

-(void) deleteIncidence: (Incidence*) incidence onSuccess:(void (^)())successBlock {
    __block NSString *uuid, *name, *time, *notes;
    __block NSNumber *lat, *lon;
    uuid = incidence.uuid;
    name = incidence.type;
    time = incidence.formattedTime;
    notes = incidence.notes;
    lat = incidence.latitude;
    lon = incidence.longitude;
    [MagicalRecord saveOnBackgroundThreadWithBlock:^(NSManagedObjectContext *localContext) {
        Incidence *localIncidence = [incidence MR_inContext:localContext];
        [localIncidence MR_deleteEntityInContext:localContext];
    } completion:^(BOOL success, NSError *error) {
        if(success){
            if(successBlock) {
                successBlock();
            }
        }
        [[SEGAnalytics sharedAnalytics] track:@"Delete Incidence"
                                   properties:@{ @"id": uuid,
                                                 @"name": name,
                                                 @"time": time,
                                                 @"latitude": lat,
                                                 @"longitude": lon,
                                                 @"notes": notes ? notes : [NSNull null],
                                                 @"writeSuccess": @(success)}];
    }];
}

-(void)createLocation:(NSDate *)now latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude onSuccess:(void (^)(Incidence *))successBlock {
    [MagicalRecord saveOnBackgroundThreadWithBlock:^(NSManagedObjectContext *localContext) {
        Incidence *location = [Incidence MR_createEntityInContext:localContext];
        location.latitude = latitude;
        location.longitude = longitude;
        location.time = now;
        location.type = @"location";
    } completion:^(BOOL success, NSError *error) {
        if(success) {
            Incidence *newlyCreatedIncidence = [Incidence MR_findFirstByAttribute:@"time" withValue:now];
            if(successBlock) {
                successBlock(newlyCreatedIncidence);
            }
            
            [[SEGAnalytics sharedAnalytics] track:@"Logged Location Change"
                                       properties:@{ @"id": newlyCreatedIncidence.uuid,
                                                     @"name": newlyCreatedIncidence.type,
                                                     @"time": newlyCreatedIncidence.formattedTime,
                                                     @"latitude": newlyCreatedIncidence.latitude,
                                                     @"longitude": newlyCreatedIncidence.longitude,
                                                     @"notes": newlyCreatedIncidence.notes ? newlyCreatedIncidence.notes : [NSNull null],
                                                     @"writeSuccess": @(success)}];
        } else {
            [[SEGAnalytics sharedAnalytics] track:@"Logged Location Change"
                                       properties:@{ @"id": [NSNull null],
                                                     @"name": @"location",
                                                     @"time": now,
                                                     @"latitude": latitude,
                                                     @"longitude": longitude,
                                                     @"notes": [NSNull null],
                                                     @"writeSuccess": @(success)}];
        }
    }];
}

-(NSArray *)allTypes {
    return [[self allSymptoms] arrayByAddingObjectsFromArray:[self allInteractions]];
}

-(NSArray *)allSymptoms {
    return [Symptom  MR_findAllSortedBy:@"name" ascending:YES];
}

-(NSArray *)allInteractions {
    return [Interaction MR_findAllSortedBy:@"name" ascending:YES];
}

-(NSArray*)eventsForTheDay:(NSDate*) date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *from = [calendar dateBySettingHour:0  minute:0  second:0  ofDate:date options:0];
    NSDate *to   = [calendar dateBySettingHour:23 minute:59 second:59 ofDate:date options:0];
    return [Incidence MR_findAllSortedBy:@"time" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"time >= %@ && time <= %@", from, to]];
}

-(NSNumber *)numberOfEventsOfType:(NSString *)type between:(NSDate *)from and:(NSDate *)to {
    return [Incidence MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"time >= %@ && time <= %@ && type=[c]%@", from, to, type]];
}

-(void)migrateFromVersion:(NSString *)version {
    NSArray *actions = [Incidence MR_findAll];
    
    [MagicalRecord saveOnBackgroundThreadWithBlockAndWait:^(NSManagedObjectContext *localContext) {
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

-(void)createSymptom:(NSString *)symptom onSuccess:(void (^)(Symptom* newSymptom))successBlock  {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        Symptom *newSymptom = [Symptom MR_createEntityInContext: localContext];
        newSymptom.name = symptom;
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        if(!contextDidSave){
            NSLog(@"Unable to save new Setting: %@", error);
        }else {
            Symptom *newlyCreatedSymptom = [Symptom MR_findFirstByAttribute:@"name" withValue:symptom];
            if(successBlock) {
                successBlock(newlyCreatedSymptom);
            }
        }
    }];
}

-(void)updateSymptom:(Symptom *)symptom {
    [MagicalRecord saveOnBackgroundThreadWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        [symptom MR_inContext:localContext];
    }];
}

-(void)updateSymptomSelection:(Symptom *)symptom isSelected:(BOOL)selected onSuccess:(void (^)())successBlock {
    [MagicalRecord saveOnBackgroundThreadWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        Symptom *localSymptom = [symptom MR_inContext:localContext];
        localSymptom.selected = @(selected);
        [[SEGAnalytics sharedAnalytics] track:@"Updated Symptoms"
                                           properties:@{ @"name": localSymptom.name,
                                                         @"on": localSymptom.selected }];
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        if(contextDidSave) {
            if(successBlock) {
                successBlock();
            }
        }
    }];
}

-(NSArray *)selectedSymptoms {
    return [Symptom MR_findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"selected=1"]];
}

-(void)createInteraction:(NSString *)interaction onSuccess:(void (^)(Interaction *newInteraction))successBlock  {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        Interaction *newAllergen = [Interaction MR_createEntityInContext:localContext];
        newAllergen.name = interaction;
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        if(!contextDidSave){
            NSLog(@"Unable to save new Interaction: %@", error);
        }
        if(!contextDidSave){
            NSLog(@"Unable to save new Setting: %@", error);
        }else {
            Interaction *newlyCreatedInteraction = [Interaction MR_findFirstByAttribute:@"name" withValue:interaction];
            if(successBlock) {
                successBlock(newlyCreatedInteraction);
            }
        }
    }];
}

-(void)updateInteraction:(Interaction *)interaction {
    [MagicalRecord saveOnBackgroundThreadWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        [interaction MR_inContext:localContext];
    }];
}

-(void)updateInteractionSelection:(Interaction *)interaction isSelected:(BOOL)selected onSuccess:(void (^)())successBlock {
    [MagicalRecord saveOnBackgroundThreadWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        Interaction *localInteraction = [interaction MR_inContext:localContext];
        localInteraction.selected = @(selected);
        [[SEGAnalytics sharedAnalytics] track:@"Updated Interactions"
                                   properties:@{ @"name": localInteraction.name,
                                                 @"on": localInteraction.selected }];
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        if(contextDidSave) {
            if(successBlock) {
                successBlock();
            }
        }
    }];
}

-(NSNumber *)numberOfIncidentsOfType:(NSString *)type {
    return @([Incidence MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"type=%@", type]]);
}

-(NSArray *)selectedInteractions {
    return [Interaction MR_findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"selected=1"]];
}

@end
