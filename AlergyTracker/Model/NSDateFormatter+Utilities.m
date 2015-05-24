//
//  NSDateFormatter+MHPUtilities.m
//  MHPParkinsons
//
//  Created by Emily Toop on 28/05/2014.
//  Copyright (c) 2014 My Health Pal. All rights reserved.
//

#import "NSDateFormatter+Utilities.h"

@implementation NSDateFormatter (Utilities)


+(NSDateFormatter *)rr_ISO8601DateFormatter
{
    id _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setLocale:[NSLocale currentLocale]];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    return _dateFormatter;
}

+(NSDateFormatter*)rr_timeFormatter
{
    id _timeFormatter = [[NSDateFormatter alloc] init];
    [_timeFormatter setLocale:[NSLocale currentLocale]];
    [_timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [_timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    return _timeFormatter;
}

+(NSDateFormatter*)rr_dateTimeFormatter
{
    id _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setLocale:[NSLocale currentLocale]];
    [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return _dateFormatter;
}

+(NSDateFormatter*)rr_dateFormatter
{
    id _dateFormatter= [[NSDateFormatter alloc] init];
    [_dateFormatter setLocale:[NSLocale currentLocale]];
    [_dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return _dateFormatter;
}

@end
