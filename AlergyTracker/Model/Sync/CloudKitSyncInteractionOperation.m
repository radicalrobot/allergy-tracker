//
//  CloudKitSyncInteractionOperation.m
//  AllergyTracker
//
//  Created by Emily Toop on 26/08/2016.
//  Copyright © 2016 Radical Robot. All rights reserved.
//

#import "CloudKitSyncInteractionOperation.h"

@interface CloudKitSyncInteractionOperation () {
    CKRecordID *_userRecordID;
    Interaction *_interaction;
    CKContainer *_container;
    LocalDataManager *_localDB;
}

@end

@implementation CloudKitSyncInteractionOperation

-(instancetype)initWithInteraction:(Interaction *)interaction forUserRecord:(CKRecordID *)userRecordID inContainer:(CKContainer *)container withLocalDB:(LocalDataManager*)localDB {
    if(self = [super init]) {
        _interaction = interaction;
        _userRecordID = userRecordID;
        _container = container;
    }
    return self;
}

-(void)main {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Name = %@", _interaction.name];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Interaction" predicate:predicate];
    [_container.publicCloudDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        CKRecord *record = nil;
        if (error) {
            record = [_interaction cloudKitRecord];
            if(error.code == CKErrorUnknownItem) {
                [_container.privateCloudDatabase saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                    NSLog(@"synced interaction record %@", _interaction.name);
                    [self updateSelected:record];
                }];
            } else {
                // Error handling for failed fetch from public database
                NSLog(@"Error fetching interaction %@! %@", _interaction.name, error);
            }
        } else {
            record = [results firstObject];
            if(record && ![record[@"name"] isEqualToString: _interaction.interactionId]) {
                _interaction.interactionId = record[@"name"];
                [_localDB updateInteraction:_interaction];
                [self updateSelected:record];
            }
        }
    }];
}

-(void)updateSelected: (CKRecord*) record {
    if(_interaction.selected.boolValue && record) {
        CKRecord* selectedInteractionRecord = [[CKRecord alloc] initWithRecordType:@"SelectedInteractions"];
        selectedInteractionRecord[@"Interaction"] = [[CKReference alloc] initWithRecord:record action:CKReferenceActionNone];
        [_container.privateCloudDatabase saveRecord:selectedInteractionRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            NSLog(@"synced selected interaction record %@", _interaction.name);
        }];
    }
}

@end
