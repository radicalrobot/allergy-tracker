//
//  CloudKitSyncSymptomOperation.m
//  AllergyTracker
//
//  Created by Emily Toop on 26/08/2016.
//  Copyright © 2016 Radical Robot. All rights reserved.
//

#import "CloudKitSyncSymptomOperation.h"

@interface CloudKitSyncSymptomOperation () {
    CKRecordID *_userRecordID;
    Symptom *_symptom;
    CKContainer *_container;
    LocalDataManager *_localDB;
}

@end

@implementation CloudKitSyncSymptomOperation

-(instancetype)initWithSymptom:(Symptom *)symptom forUserRecord:(CKRecordID *)userRecordID inContainer:(CKContainer *)container withLocalDB:(LocalDataManager*)localDB {
    if(self = [super init]) {
        _symptom = symptom;
        _userRecordID = userRecordID;
        _container = container;
    }
    return self;
}

-(void)main {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Name = %@", _symptom.name];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Symptom" predicate:predicate];
    [_container.publicCloudDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        CKRecord *record = nil;
        if (error) {
            record = [_symptom cloudKitRecord];
            if(error.code == CKErrorUnknownItem) {
                [_container.privateCloudDatabase saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                    NSLog(@"synced symptom record %@", _symptom.name);
                    [self updateSelected:record];
                }];
            } else {
                // Error handling for failed fetch from public database
                NSLog(@"Error fetching symptom %@! %@", _symptom.name, error);
            }
        } else {
            record = [results firstObject];
            if(record && ![record[@"name"] isEqualToString: _symptom.symptomId]) {
                _symptom.symptomId = record[@"name"];
                [_localDB updateSymptom:_symptom];
                [self updateSelected:record];
            }
        }
    }];
}

-(void)updateSelected: (CKRecord*) record {
    if(_symptom.selected.boolValue && record) {
        CKRecord* selectedSymptomRecord = [[CKRecord alloc] initWithRecordType:@"SelectedSymptoms"];
        selectedSymptomRecord[@"Symptom"] = [[CKReference alloc] initWithRecord:record action:CKReferenceActionNone];
        [_container.privateCloudDatabase saveRecord:selectedSymptomRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            NSLog(@"synced selected symptom record %@", _symptom.name);
        }];
    }
}

@end
