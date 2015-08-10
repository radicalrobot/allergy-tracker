//
//  Symptom+Extras.m
//  AlergyTracker
//
//  Created by Emily Toop on 11/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "Symptom+Extras.h"

@implementation Symptom (Extras)

-(void)awakeFromInsert {
    [super awakeFromInsert];
    self.symptomId = [[NSUUID UUID] UUIDString];
}

@end
