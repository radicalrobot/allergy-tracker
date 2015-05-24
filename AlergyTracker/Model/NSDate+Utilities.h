//
//  NSDate+MHPUtilities.h
//  MHPParkinsons
//
//  Created by Emily Toop on 26/03/2014.
//  Copyright (c) 2014 My Health Pal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Utilities)

+(BOOL)rr_is24HourClock;

+(NSDate*)rr_dateBySettingSecond:(NSInteger)second onDate:(NSDate*)date;
+(NSDate*)rr_dateBySettingMinute:(NSInteger)minute onDate:(NSDate*)date;
+(NSDate*)rr_dateBySettingHour:(NSInteger)hour onDate:(NSDate*)date;
+(NSDate*)rr_dateBySettingYear:(NSInteger)year onDate:(NSDate*)date;
+(NSDate*)rr_dateBySettingHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second timezone:(NSTimeZone*)timezone onDate:(NSDate*)date;
+(NSDate *)rr_dateBySettingDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year onDate:(NSDate *)date;

+(NSDate*)rr_dateForDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year;
+(NSDate*)rr_timeForHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second timezone:(NSTimeZone*)timezone;

-(BOOL)rr_isSameDayAsDate:(NSDate*)dateToCompare;
-(NSDate*)rr_addNumberOfDays:(NSInteger)numberOfDays;
- (NSString*)RR_dateTag;

@end
