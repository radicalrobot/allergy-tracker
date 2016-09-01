//
//  Incidence+Extras.m
//  AlergyTracker
//
//  Created by Emily Toop on 27/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "Incidence+Extras.h"
#import "RRDataManager.h"
#import "Symptom+Extras.h"
#import "Interaction+Extras.h"
#import "NSNumber+Utilities.h"

#import <CoreLocation/CoreLocation.h>

@implementation Incidence(Extras)

-(NSString*)displayName {
    return [self.type capitalizedStringWithLocale:[NSLocale currentLocale]];
}

-(void)awakeFromInsert {
    [super awakeFromInsert];
    self.uuid = [[NSUUID UUID] UUIDString];
}

-(void)setTime:(NSDate *)time {
    [self willChangeValueForKey:@"time"];
    [self setPrimitiveValue:time forKey:@"time"];
    [self didChangeValueForKey:@"time"];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ";
    timeFormatter.timeZone = [NSTimeZone defaultTimeZone];
    timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    
    NSMutableString *formattedTime = [NSMutableString stringWithString:[timeFormatter stringFromDate:time]];
    [formattedTime insertString:@":" atIndex:formattedTime.length-2];
    [self setFormattedTime:formattedTime];
}

+(NSArray *)getTopIncidents {
    NSArray *alltypes = [[RRDataManager currentDataManager] allTypes];
    NSMutableDictionary *topIncidents = [NSMutableDictionary dictionary];
    for(NSObject *type in alltypes) {
        NSString *name;
        if([type isKindOfClass:[Symptom class]]) {
            name = ((Symptom*)type).name;
        } else {
            name = ((Interaction*)type).name;
        }
        topIncidents[name] = [[RRDataManager currentDataManager] numberOfIncidentsOfType:name];
    }
    return [[topIncidents allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString* key1, NSString* key2) {
        return [topIncidents[key1] reverseCompare: topIncidents[key2]];
    }];
}

+(NSArray *)getTopIncidentsWithLimit:(int)limit {
    NSArray *topInteractions = [self getTopIncidents];
    if(limit > topInteractions.count) {
        return topInteractions;
    }
    return [topInteractions subarrayWithRange:NSMakeRange(0, limit)];
}



-(CKRecord *)cloudKitRecord {
    if(!self.uuid) {
        self.uuid = [[NSUUID UUID] UUIDString];
        [[RRDataManager currentDataManager] saveIncidence:self withCompletion:nil];
    }
    NSString *recordName = self.uuid;
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:recordName];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Incidence" recordID:recordID];
    record[@"FormattedTime"] = self.formattedTime;
    record[@"Location"] = [[CLLocation alloc] initWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue];
    record[@"Notes"] = self.notes;
    record[@"Time"] = self.time;
    record[@"Type"] = self.type;
    record[@"UUID"] = self.uuid;
    return record;
}

@end
