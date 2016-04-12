//
//  Symptom+Extras.m
//  AlergyTracker
//
//  Created by Emily Toop on 11/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "Symptom+Extras.h"
#import <MagicalRecord/MagicalRecord.h>

@implementation Symptom (Extras)

-(NSString*)displayName {
    return [self.name capitalizedStringWithLocale:[NSLocale currentLocale]];
}

-(void)awakeFromInsert {
    [super awakeFromInsert];
    self.symptomId = [[NSUUID UUID] UUIDString];
}

+(NSArray *)alphabeticacisedSymptomsSelected:(bool) selected {
    NSPredicate *predicate = nil;
    if(selected) {
        predicate = [NSPredicate predicateWithFormat:@"selected=1"];
    }
    NSArray *symptoms = [Symptom MR_findAllWithPredicate:predicate];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    return [symptoms sortedArrayUsingDescriptors:@[sort]];
}

@end
