//
//  DataManager.h
//  AllergyTracker
//
//  Created by Emily Toop on 18/05/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

+(void)setup;
+(void)cleanup;

+(BOOL)isFirstRun;
+(NSInteger)numberOfSelectedSymptoms;

@end
