//
//  Symptom+Extras.m
//  AlergyTracker
//
//  Created by Emily Toop on 11/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "Symptom+Extras.h"
#import "RRDataManager.h"

@implementation Symptom (Extras)

-(NSString*)displayName {
    return [self.name capitalizedStringWithLocale:[NSLocale currentLocale]];
}

-(void)awakeFromInsert {
    [super awakeFromInsert];
    self.symptomId = [[NSUUID UUID] UUIDString];
}

+(NSArray *)alphabetisedSymptomsSelected:(bool) selected {
    NSArray *symptoms = selected ? [[RRDataManager currentDataManager] selectedSymptoms] : [[RRDataManager currentDataManager] allSymptoms];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    return [symptoms sortedArrayUsingDescriptors:@[sort]];
}

@end
