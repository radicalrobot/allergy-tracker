//
//  NSDateFormatter+MHPUtilities.h
//  MHPParkinsons
//
//  Created by Emily Toop on 28/05/2014.
//  Copyright (c) 2014 My Health Pal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (Utilities)


+(NSDateFormatter*)rr_ISO8601DateFormatter;
+(NSDateFormatter*)rr_timeFormatter;
+(NSDateFormatter*)rr_dateTimeFormatter;
+(NSDateFormatter*)rr_dateFormatter;

@end
