//
//  iCloudDataManager.m
//  AllergyTracker
//
//  Created by Emily Toop on 22/08/2016.
//  Copyright © 2016 Radical Robot. All rights reserved.
//

#import "iCloudDataManager.h"
#import "Symptom+Extras.h"
#import "Interaction+Extras.h"
#import "Incidence+Extras.h"

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>

@interface iCloudDataManager()

@property (nonatomic, strong) LocalDataManager *localDB;
@property (nonatomic, strong) CKContainer *container;
@property (nonatomic, strong) CKDatabase *publicDB;
@property (nonatomic, strong) CKDatabase *privateDB;
@property (nonatomic, strong) CKRecordID *userRecordID;

@end

@implementation iCloudDataManager
@synthesize initialized;

-(instancetype)init {
    if(self = [super init]) {
        self.initialized = NO;
    }

    return self;
}

-(instancetype)initWithLocalDataManager:(LocalDataManager *)localManager {
    if(self = [self init]) {
        _localDB = localManager;
    }
    return self;
}

-(void)cleanup {
    [_localDB cleanup];
}

-(BOOL)isFirstRun {
    return [_localDB isFirstRun];
}

-(void)setup {
    _container = [CKContainer defaultContainer];
    _publicDB = [_container publicCloudDatabase];
    _privateDB = [_container privateCloudDatabase];
    if(!_localDB) {
        _localDB = [LocalDataManager new];
        [_localDB setup];
    }
    
    
    // check to see if this is a new user on iCloud
    // if so, sync up any existing local DB content to iCloud
    [self performDBSync];
    self.initialized = YES;
}

-(void)performDBSync {
    __weak typeof(self)weakself = self;
    [_container fetchUserRecordIDWithCompletionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
        typeof(weakself) strongself = weakself;
        strongself.userRecordID = recordID;
        [_publicDB fetchRecordWithID:recordID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            typeof(weakself) strongself = weakself;
            // if user has device ID attached then not a new user and don't do anything
            // otherwise sync any existing data
            NSString *appDeviceID = record[@"AppDeviceID"];
            if(!appDeviceID || appDeviceID.length == 0) {
                // perform a DB Sync
                // update user
                [strongself syncItemsForUserRecord: record];
            }
        }];
    }];
}

-(void) syncItemsForUserRecord:(CKRecord*) record {
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    operationQueue.name = @"CloudKit Sync queue";
    operationQueue.maxConcurrentOperationCount = 5;
    // update symptoms
    [self syncSymptoms:operationQueue];
    // update interactions
    [self syncInteractions:operationQueue];
    // update incidents
    [self syncIncidents:operationQueue];

    __weak typeof(self)weakself = self;
    [operationQueue addOperationWithBlock:^{
        typeof(weakself) strongself = weakself;
        record[@"AppDeviceID"] = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [strongself.publicDB saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            NSLog(@"saved user record");
        }];
    }];
}

-(void)syncSymptoms: (NSOperationQueue*) queue {
    NSArray *symptoms = [_localDB allSymptoms];
    __weak typeof(self) weakself = self;
    for(Symptom *symptom in symptoms) {
        CKRecord *record = [symptom cloudKitRecord];
        NSString *symptomID = symptom.symptomId;
        NSString *symptomName = symptom.name;
        NSOperation *symptomSyncOp = [NSBlockOperation blockOperationWithBlock:^{
            typeof(weakself) strongself = weakself;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Name = %@", symptomName];
            CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Symptom" predicate:predicate];
            [strongself.publicDB performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
                if (error) {
                    if(error.code == CKErrorUnknownItem) {
                        [strongself.privateDB saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                            NSLog(@"synced symptom record %@", record[@"Name"]);
                        }];
                    } else {
                        // Error handling for failed fetch from public database
                        NSLog(@"Error fetching symptom %@! %@", record[@"Name"], error);
                    }
                } else {
                    if( [results count] == 0) {
                        [strongself.privateDB saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                            NSLog(@"synced symptom record %@", record[@"Name"]);
                        }];
                    } else {
                        CKRecord *fetchedRecord = [results firstObject];
                        if(fetchedRecord && ![fetchedRecord[@"name"] isEqualToString: symptomID]) {
                            Symptom *localSymptom = [strongself.localDB symptomWithID:symptomID];
                            localSymptom.symptomId = fetchedRecord[@"name"];
                            [strongself.localDB updateSymptom:localSymptom];
                        }
                    }
                }
            }];
        }];

        if(symptom.selected.boolValue) {
            NSOperation *selectedSymptomSyncOp = [NSBlockOperation blockOperationWithBlock:^{
                typeof(weakself) strongself = weakself;
                CKRecord* selectedSymptomRecord = [[CKRecord alloc] initWithRecordType:@"SelectedSymptoms"];
                selectedSymptomRecord[@"Symptom"] = [[CKReference alloc] initWithRecordID:[[CKRecordID alloc] initWithRecordName:symptomID] action:CKReferenceActionNone];
                selectedSymptomRecord[@"User"] = [[CKReference alloc] initWithRecordID:_userRecordID action:CKReferenceActionNone];
                [strongself.privateDB saveRecord:selectedSymptomRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                    if(error) {
                        NSLog(@"Failed to save selected Symptom %@", error);
                    } else {
                        NSLog(@"synced selected Symptom record %@", symptom.name);
                    }
                }];
            }];

            [symptomSyncOp addDependency:selectedSymptomSyncOp];
            [queue addOperations:@[symptomSyncOp, selectedSymptomSyncOp] waitUntilFinished:NO];
        } else {
            [queue addOperation:symptomSyncOp];
        }
    }
}

-(void)syncInteractions: (NSOperationQueue*) queue {
    NSArray *interactions = [_localDB allInteractions];
    __weak typeof(self) weakself = self;
    for(Interaction *interaction in interactions) {
        CKRecord *record = [interaction cloudKitRecord];
        NSString *interactionID = interaction.interactionId;
        NSString *interactionName = interaction.name;
        NSOperation *interactionSyncOp = [NSBlockOperation blockOperationWithBlock:^{
            typeof(weakself) strongself = weakself;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Name = %@", interactionName];
            CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Interaction" predicate:predicate];
            [strongself.publicDB performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
                if (error) {
                    if(error.code == CKErrorUnknownItem) {
                        [strongself.privateDB saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                            NSLog(@"synced interaction record %@", interactionName);
                        }];
                    } else {
                        // Error handling for failed fetch from public database
                        NSLog(@"Error fetching interaction %@! %@", interactionName, error);
                    }
                } else {
                    if( [results count] == 0) {
                        [strongself.privateDB saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                            NSLog(@"synced interaction record %@", interactionName);
                        }];
                    } else {
                        CKRecord *fetchedRecord = [results firstObject];
                        if(fetchedRecord && ![fetchedRecord[@"name"] isEqualToString: interactionID]) {
                            Interaction *localInteraction = [strongself.localDB interactionWithID:interactionID];
                            localInteraction.interactionId = fetchedRecord[@"name"];
                            [strongself.localDB updateInteraction:localInteraction];
                        }
                    }
                }
            }];
        }];

        if(interaction.selected.boolValue) {
            NSOperation *selectedInteractionSyncOp = [NSBlockOperation blockOperationWithBlock:^{
                typeof(weakself) strongself = weakself;
                CKRecord* selectedInteractionRecord = [[CKRecord alloc] initWithRecordType:@"SelectedInteractions"];
                selectedInteractionRecord[@"Interaction"] = [[CKReference alloc] initWithRecordID:[[CKRecordID alloc] initWithRecordName:interactionID] action:CKReferenceActionNone];
                selectedInteractionRecord[@"User"] = [[CKReference alloc] initWithRecordID:_userRecordID action:CKReferenceActionNone];
                [strongself.privateDB saveRecord:selectedInteractionRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                    if(error) {
                        NSLog(@"Failed to save selected Interaction %@", error);
                    } else {
                        NSLog(@"synced selected Interaction record %@", interaction.name);
                    }
                }];
            }];

            [interactionSyncOp addDependency:selectedInteractionSyncOp];
            [queue addOperations:@[interactionSyncOp, selectedInteractionSyncOp] waitUntilFinished:NO];
        } else {
            [queue addOperation:interactionSyncOp];
        }
    }
}

-(void)syncIncidents: (NSOperationQueue*) queue {
    NSArray *incidents = [self allIncidents];
    __weak typeof(self)weakself = self;
    for(Incidence *incident in incidents) {
        NSLog(@"incident: %@", incident);
        typeof(weakself) strongself = weakself;
        [queue addOperationWithBlock:^{
            CKRecordID *incidentRecordID = [[CKRecordID alloc] initWithRecordName:incident.uuid];
            [_publicDB fetchRecordWithID:incidentRecordID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                CKRecord *incidentRecord = [incident cloudKitRecord];
                incidentRecord[@"User"] = [[CKReference alloc] initWithRecordID:strongself.userRecordID action:CKReferenceActionNone];
                if (error) {
                    if(error.code == CKErrorUnknownItem) {
                        [strongself.publicDB saveRecord:incidentRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                            NSLog(@"synced incident record %@", incidentRecord);
                        }];
                    } else {
                        // Error handling for failed fetch from public database
                        NSLog(@"Error fetching incident record %@! %@", incidentRecord, error);
                    }
                }
            }];
        }];
    }
}

-(NSArray *)companionItemsForIncidenceWithName:(NSString *)name {
    return [_localDB companionItemsForIncidenceWithName:name];
}

-(NSArray *)allIncidentNames {
    return [_localDB allIncidentNames];
}

-(NSArray *)allIncidents {
    return [_localDB allIncidents];
}

-(NSInteger)numberOfIncidentsWithName:(NSString *)name betweenDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    return [_localDB numberOfIncidentsWithName:name betweenDate:startDate endDate:endDate];
}

-(NSInteger)numberOfSelectedSymptoms {
    return [_localDB numberOfSelectedSymptoms];
}

-(void)saveIncidence:(Incidence *)incidence withCompletion:(void (^)(BOOL, NSError *))completion {
    __weak typeof(self)weakself = self;
    [_localDB saveIncidence:incidence withCompletion:^(BOOL contextDidSave, NSError *error) {
        typeof(weakself) strongself = weakself;
        if(contextDidSave) {
            CKRecordID *incidentRecordID = [[CKRecordID alloc] initWithRecordName:incidence.uuid];
            [strongself.publicDB fetchRecordWithID:incidentRecordID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                if (error) {
                    if(error.code == CKErrorUnknownItem) {
                        CKRecord *incidentRecord = [incidence cloudKitRecord];
                        incidentRecord[@"User"] = [[CKReference alloc] initWithRecordID:strongself.userRecordID action:CKReferenceActionNone];
                        [strongself.publicDB saveRecord:incidentRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                            NSLog(@"synced incident record %@", incidentRecord);
                        }];
                    } else {
                        // Error handling for failed fetch from public database
                        NSLog(@"Error fetching incident record %@! %@", incidence, error);
                    }
                } else {
                    record[@"FormattedTime"] = incidence.formattedTime;
                    record[@"Location"] = [[CLLocation alloc] initWithLatitude:incidence.latitude.doubleValue longitude:incidence.longitude.doubleValue];
                    record[@"Notes"] = incidence.notes;
                    record[@"Time"] = incidence.time;
                    record[@"Type"] = incidence.type;
                    [strongself.publicDB saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                        NSLog(@"synced incident record update %@", record);
                    }];
                }
            }];
        }
        if(completion) {
            completion(contextDidSave, error);
        }
    }];
}

-(void)createIncident:(NSDate *)now latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude type:(NSString *)incidenceType onSuccess:(void (^)(Incidence *))successBlock {
    __weak typeof(self)weakself = self;
    [_localDB createIncident:now latitude:latitude longitude:longitude type:incidenceType onSuccess:^(Incidence *incidence) {
        typeof(weakself) strongself = weakself;
        CKRecord *incidenceRecord = [incidence cloudKitRecord];
        incidenceRecord[@"User"] = [[CKReference alloc] initWithRecordID:strongself.userRecordID action:CKReferenceActionNone];
        [strongself.publicDB saveRecord:incidenceRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            NSLog(@"synced new incident record %@", incidenceRecord);
        }];

        if(successBlock) {
            successBlock(incidence);
        }
    }];
}

-(Incidence *)createNewEmptyIncident {
    return [_localDB createNewEmptyIncident];
}

-(NSNumber *)numberOfIncidentsOfType:(NSString *)type {
    return [_localDB numberOfIncidentsOfType:type];
}

-(NSArray *)eventsForTheDay:(NSDate *)date {
    return [_localDB eventsForTheDay:date];
}

-(NSNumber *)numberOfEventsOfType:(NSString *)type between:(NSDate *)from and:(NSDate *)to {
    return [_localDB numberOfEventsOfType:type between:from and:to];
}

-(void)createLocation:(NSDate *)now latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude onSuccess:(void (^)(Incidence *))successBlock {
    __weak typeof(self)weakself = self;
    [_localDB createLocation:now latitude:latitude longitude:longitude onSuccess:^(Incidence *incidence) {
        typeof(weakself) strongself = weakself;
        CKRecord *incidenceRecord = [incidence cloudKitRecord];
        incidenceRecord[@"User"] = [[CKReference alloc] initWithRecordID:strongself.userRecordID action:CKReferenceActionNone];
        [strongself.publicDB saveRecord:incidenceRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            NSLog(@"synced new incident record %@", incidenceRecord);
        }];
        if(successBlock) {
            successBlock(incidence);
        }
    }];
}

-(void)deleteIncidence:(Incidence *)incidence onSuccess:(void (^)())successBlock {
    __weak typeof(self)weakself = self;
    [_localDB deleteIncidence:incidence onSuccess:^{
        typeof(weakself) strongself = weakself;
        CKRecordID *incidentRecordID = [[CKRecordID alloc] initWithRecordName:incidence.uuid];
        [strongself.publicDB deleteRecordWithID:incidentRecordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
            NSLog(@"synced deleted incident record %@", incidentRecordID);
        }];
    }];
}

-(NSArray *)allTypes {
    return [_localDB allTypes];
}

-(NSArray *)allInteractions {
    return [_localDB allInteractions];
}

-(NSArray *)allSymptoms {
    return [_localDB allSymptoms];
}

-(void)migrateFromVersion:(NSString *)version {
    [_localDB migrateFromVersion:version];
}

-(void)createSymptom:(NSString *)symptom onSuccess:(void (^)(Symptom* ))successBlock {
    __weak typeof(self)weakself = self;
    [_localDB createSymptom:symptom onSuccess:^(Symptom *newSymptom) {
        typeof(weakself) strongself = weakself;
        [strongself.privateDB saveRecord:[newSymptom cloudKitRecord] completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            NSLog(@"synced symptom record %@", newSymptom.name);
        }];
        if(successBlock) {
            successBlock(newSymptom);
        }
    }];
}

-(void)updateSymptomSelection:(Symptom *)symptom isSelected:(BOOL)selected onSuccess:(void (^)())successBlock {
    __weak typeof(self)weakself = self;
    [_localDB updateSymptomSelection:symptom isSelected:selected onSuccess:^{
        typeof(weakself) strongself = weakself;
        CKRecordID *symptomRecordID = [[CKRecordID alloc] initWithRecordName:symptom.symptomId];
        CKReference *symptomReference = [[CKReference alloc] initWithRecordID:symptomRecordID action:CKReferenceActionNone];
        CKReference *userReference = [[CKReference alloc] initWithRecordID:strongself.userRecordID action:CKReferenceActionNone];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Symptom = %@ && User = %@", symptomReference, userReference];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"SelectedSymptoms" predicate:predicate];
        [strongself.privateDB performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
            CKRecord *selectedSymptomRecord = [results firstObject];
            if(selectedSymptomRecord) {
                if(!selected) {
                    [strongself.privateDB deleteRecordWithID:selectedSymptomRecord.recordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
                        NSLog(@"symptom deselected %@", error);
                    }];
                }
            } else {
                if(selected) {
                    selectedSymptomRecord = [[CKRecord alloc] initWithRecordType:@"SelectedSymptoms"];
                    selectedSymptomRecord[@"Symptom"] = symptomReference;
                    selectedSymptomRecord[@"User"] = userReference;
                    [strongself.privateDB saveRecord:selectedSymptomRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                        NSLog(@"symptom selected %@", error);
                    }];
                }
            }
        }];
    }];
}

-(NSArray *)selectedSymptoms {
    return [_localDB selectedSymptoms];
}

-(void)updateSymptom:(Symptom *)symptom {
    [_localDB updateSymptom:symptom];
    CKRecord *symptomRecord = [symptom cloudKitRecord];
    [self.publicDB saveRecord:symptomRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        NSLog(@"updated symptom %@", symptomRecord);
    }];
}

-(void)createInteraction:(NSString *)interaction onSuccess:(void (^)(Interaction *))successBlock {
    __weak typeof(self)weakself = self;
    [_localDB createInteraction:interaction onSuccess:^(Interaction *newInteraction) {
        typeof(weakself) strongself = weakself;
        [strongself.privateDB saveRecord:[newInteraction cloudKitRecord] completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            NSLog(@"synced interaction record %@", newInteraction.name);
        }];
        if(successBlock) {
            successBlock(newInteraction);
        }
    }];
}

-(void)updateInteractionSelection:(Interaction *)interaction isSelected:(BOOL)selected onSuccess:(void (^)())successBlock {
    __weak typeof(self)weakself = self;
    [_localDB updateInteractionSelection:interaction isSelected:selected onSuccess:^{
        typeof(weakself) strongself = weakself;
        CKRecordID *interactionRecordID = [[CKRecordID alloc] initWithRecordName:interaction.interactionId];
        CKReference *interactionReference = [[CKReference alloc] initWithRecordID:interactionRecordID action:CKReferenceActionNone];
        CKReference *userReference = [[CKReference alloc] initWithRecordID:strongself.userRecordID action:CKReferenceActionNone];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Interaction = %@ && User = %@", interactionReference, userReference];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"SelectedInteractions" predicate:predicate];
        [strongself.privateDB performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
            CKRecord *selectedInteractionRecord = [results firstObject];
            if(selectedInteractionRecord) {
                if(!selected) {
                    [strongself.privateDB deleteRecordWithID:selectedInteractionRecord.recordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
                        NSLog(@"interaction deselected %@", error);
                    }];
                }
            } else {
                if(selected) {
                    selectedInteractionRecord = [[CKRecord alloc] initWithRecordType:@"SelectedInteractions"];
                    selectedInteractionRecord[@"Interaction"] = interactionReference;
                    selectedInteractionRecord[@"User"] = userReference;
                    [strongself.privateDB saveRecord:selectedInteractionRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                        NSLog(@"interaction selected %@", error);
                    }];
                }
            }
        }];
    }];
}

-(void)updateInteraction:(Interaction *)interaction {
    [_localDB updateInteraction:interaction];
    CKRecord *interactionRecord = [interaction cloudKitRecord];
    [self.publicDB saveRecord:interactionRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        NSLog(@"updated interaction %@", interactionRecord);
    }];
}

-(NSArray *)selectedInteractions {
    return [_localDB selectedInteractions];
}

@end
