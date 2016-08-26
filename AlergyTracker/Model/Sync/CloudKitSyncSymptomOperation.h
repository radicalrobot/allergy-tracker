//
//  CloudKitSyncSymptomOperation.h
//  AllergyTracker
//
//  Created by Emily Toop on 26/08/2016.
//  Copyright © 2016 Radical Robot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

#import "Symptom+Extras.h"
#import "LocalDataManager.h"

@interface CloudKitSyncSymptomOperation : NSOperation

-(instancetype) initWithSymptom:(Symptom*) symptom forUserRecord:(CKRecordID*)userRecordID inContainer:(CKContainer*) container withLocalDB:(LocalDataManager*)localDB;

@end
