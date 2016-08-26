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
#import "CloudKitSyncSymptomOperation.h"
#import "CloudKitSyncInteractionOperation.h"

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
                record[@"AppDeviceID"] = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                [strongself.publicDB saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                    NSLog(@"saved user record");
                }];
                [strongself syncItems];
            }
        }];
    }];
}

-(void) syncItems {
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    operationQueue.name = @"CloudKit Sync queue";
    operationQueue.maxConcurrentOperationCount = 5;
    // update symptoms
    [self syncSymptoms:operationQueue];
    // update interactions
    [self syncInteractions:operationQueue];
    // update incidents
    [self syncIncidents:operationQueue];
    [operationQueue ]
}

-(void)syncSymptoms: (NSOperationQueue*) queue {
    NSArray *symptoms = [_localDB allSymptoms];
    for(Symptom *symptom in symptoms) {
        [queue addOperation:[[CloudKitSyncSymptomOperation alloc] initWithSymptom:symptom forUserRecord:self.userRecordID inContainer:self.container withLocalDB:self.localDB]];
    }
}

-(void)syncInteractions: (NSOperationQueue*) queue {
    NSArray *interactions = [_localDB allSymptoms];
    for(Interaction *interaction in interactions) {
        [queue addOperation:[[CloudKitSyncInteractionOperation alloc] initWithInteraction:interaction forUserRecord:self.userRecordID inContainer:self.container withLocalDB:self.localDB]];
    }
}

-(void)syncIncidents: (NSOperationQueue*) queue {
    NSArray *incidents = [_localDB allIncidents];
    __weak typeof(self)weakself = self;
    for(Incidence *incident in incidents) {
        CKRecordID *incidentRecordID = [[CKRecordID alloc] initWithRecordName:incident.uuid];
        [_publicDB fetchRecordWithID:incidentRecordID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            typeof(weakself) strongself = weakself;
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
    }
}

-(NSArray *)companionItemsForIncidenceWithName:(NSString *)name {
    return [_localDB companionItemsForIncidenceWithName:name];
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
    [_localDB updateSymptomSelection:symptom isSelected:selected onSuccess:successBlock];
}

-(NSArray *)selectedSymptoms {
    return [_localDB selectedSymptoms];
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
    [_localDB updateInteractionSelection:interaction isSelected:selected onSuccess:successBlock];
}

-(NSArray *)selectedInteractions {
    return [_localDB selectedInteractions];
}

@end
