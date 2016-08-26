//
//  CloudKitSyncInteractionOperation.h
//  AllergyTracker
//
//  Created by Emily Toop on 26/08/2016.
//  Copyright © 2016 Radical Robot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

#import "Interaction+Extras.h"
#import "LocalDataManager.h"

@interface CloudKitSyncInteractionOperation : NSOperation

-(instancetype) initWithInteraction:(Interaction*) interaction forUserRecord:(CKRecordID*)userRecordID inContainer:(CKContainer*) container withLocalDB:(LocalDataManager*)localDB;

@end
