//
//  DataManager.h
//  AllergyTracker
//
//  Created by Emily Toop on 18/05/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RRDataManager.h"


@interface LocalDataManager : NSObject<DataManager>

-(void)updateInteraction:(Interaction*)interaction;
-(void)updateSymptom:(Symptom*)symptom;

@end
