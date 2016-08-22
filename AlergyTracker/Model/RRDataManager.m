//
//  RRDataManager.m
//  AllergyTracker
//
//  Created by Emily Toop on 22/08/2016.
//  Copyright © 2016 Radical Robot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RRDataManager.h"

@implementation RRDataManager

static id<DataManager> currentDataManager;

+(id<DataManager>)currentDataManager {
    return currentDataManager;
}

+(void)setCurrentDataManager:(id<DataManager>)manager {
    currentDataManager = manager;
}

@end
