//
//  Incidence+Extras.m
//  AlergyTracker
//
//  Created by Emily Toop on 27/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "Incidence+Extras.h"

@implementation Incidence(Extras)

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

@end
