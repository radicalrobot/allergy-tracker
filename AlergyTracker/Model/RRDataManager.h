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
#import "Symptom.h"

@protocol DataManager <NSObject>

@required
@property(nonatomic, assign) BOOL initialized;

-(void)setup;
-(void)cleanup;

-(BOOL)isFirstRun;

-(NSInteger)numberOfIncidentsWithName:(NSString*)name betweenDate:(NSDate*)startDate endDate:(NSDate*)endDate;
-(NSInteger)numberOfSelectedSymptoms;

-(NSArray *)allIncidents;
-(NSArray*)companionItemsForIncidenceWithName:(NSString*)name;

-(void)saveIncidence:(Incidence*)incidence withCompletion:(void (^)(BOOL contextDidSave, NSError* error))completion;
-(void)createIncident: (NSDate*) now latitude:(NSNumber*) latitude longitude:(NSNumber*) longitude type:(NSString*) incidenceType onSuccess:(void (^)(Incidence*))successBlock;
-(Incidence*)createNewEmptyIncident;
-(NSNumber*)numberOfIncidentsOfType:(NSString*)type;
-(NSArray*)eventsForTheDay:(NSDate*) date;
-(NSNumber*)numberOfEventsOfType:(NSString*)type between:(NSDate*)from and:(NSDate*)to;
-(void)createLocation: (NSDate*) now latitude:(NSNumber*) latitude longitude:(NSNumber*) longitude onSuccess:(void (^)(Incidence*))successBlock;
-(void) deleteIncidence: (Incidence*) incidence onSuccess:(void (^)())successBlock;
-(NSArray*)allTypes;
-(NSArray*)allInteractions;
-(NSArray*)allSymptoms;
-(void)migrateFromVersion:(NSString *)version;
-(void)createSymptom:(NSString *)symptom onSuccess:(void (^)(Symptom* newSymptom))successBlock;
-(void)updateSymptomSelection:(Symptom*)symptom isSelected:(BOOL)selected onSuccess:(void (^)())successBlock;
-(NSArray*)selectedSymptoms;
-(void)createInteraction:(NSString*)interaction onSuccess:(void (^)(Interaction* newInteraction))successBlock;
-(void)updateInteractionSelection:(Interaction*)interaction isSelected:(BOOL)selected onSuccess:(void (^)())successBlock;
-(NSArray*)selectedInteractions;

@end

@interface RRDataManager : NSObject 

+(id<DataManager>)currentDataManager;
+(void)setCurrentDataManager:(id<DataManager>)manager;
+(BOOL)ready;

@end
