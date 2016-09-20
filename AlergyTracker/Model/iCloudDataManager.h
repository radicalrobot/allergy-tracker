//
//  iCloudDataManager.h
//  AllergyTracker
//
//  Created by Emily Toop on 22/08/2016.
//  Copyright © 2016 Radical Robot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RRDataManager.h"
#import "LocalDataManager.h"

@interface iCloudDataManager : NSObject<DataManager>

-(instancetype)initWithLocalDataManager:(LocalDataManager*)localManager;

@end
