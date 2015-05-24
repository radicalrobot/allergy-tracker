//
//  NSDate+MHPUtilities.m
//  MHPParkinsons
//
//  Created by Emily Toop on 26/03/2014.
//  Copyright (c) 2014 My Health Pal. All rights reserved.
//

#import "NSDate+Utilities.h"

@implementation NSDate (Utilities)

-(BOOL)rr_isSameDayAsDate:(NSDate *)dateToCompare
{
    NSDate *date1 = [[self class] rr_dateBySettingHour:1 minute:1 second:1 timezone:[NSTimeZone localTimeZone] onDate:self];
    NSDate *date2 = [[self class] rr_dateBySettingHour:1 minute:1 second:1 timezone:[NSTimeZone localTimeZone] onDate:dateToCompare];
    
    return [date1 compare:date2] == NSOrderedSame;
}

-(NSDate *)rr_addNumberOfDays:(NSInteger)numberOfDays
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate: self];
    components.day = numberOfDays;
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

+(NSDate*)rr_dateBySettingSecond:(NSInteger)second onDate:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate: date];
    [components setSecond:second];
    return [calendar dateFromComponents: components];
}

+(NSDate*)rr_dateBySettingMinute:(NSInteger)minute onDate:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate: date];
    [components setMinute:minute];
    return [calendar dateFromComponents: components];
}

+(NSDate*)rr_dateBySettingHour:(NSInteger)hour onDate:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate: date];
    [components setHour:hour];
    return [calendar dateFromComponents: components];
}

+(NSDate*)rr_dateBySettingYear:(NSInteger)year onDate:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate: date];
    [components setYear:year];
    return [calendar dateFromComponents: components];
}

+(NSDate *)rr_dateBySettingHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second timezone:(NSTimeZone*)timezone onDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitTimeZone) fromDate: date];
    [components setHour:hour];
    [components setMinute:minute];
    [components setSecond:second];
    [components setTimeZone:timezone];
    NSDate *changedDate = [calendar dateFromComponents: components];
    return changedDate;
}

+(NSDate *)rr_dateBySettingDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year onDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate: date];
    [components setDay:day];
    [components setMonth:month];
//    if(year > 0)
        [components setYear:year];
//    else
//        [components setYear:2000];
    NSDate *changedDate = [calendar dateFromComponents: components];
    return changedDate;
}


+(NSDate *)rr_dateForDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate: [NSDate new]];
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    NSDate *changedDate = [calendar dateFromComponents: components];
    return changedDate;
}

+(NSDate *)rr_timeForHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second timezone:(NSTimeZone*)timezone
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitTimeZone) fromDate: [NSDate new]];
    [components setHour:hour];
    [components setMinute:minute];
    [components setSecond:second];
    [components setTimeZone:timezone];
    NSDate *changedDate = [calendar dateFromComponents: components];
    return changedDate;
}

+(BOOL)rr_is24HourClock
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    
    return [[dateFormatter dateFormat] rangeOfString:@"a"].location == NSNotFound;
}

- (NSString *)RR_dateTag {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                                   fromDate:self];

    return  [NSString stringWithFormat:@"%ld-%ld-%ld",
                                       (long)components.year,
                                       (long)components.month,
                                       (long)components.day];
}

@end
