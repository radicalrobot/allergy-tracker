//
//  NSNumber+Utilities.m
//  AllergyTracker
//
//  Created by Emily Toop on 28/03/2016.
//  Copyright © 2016 Radical Robot. All rights reserved.
//

#import "NSNumber+Utilities.h"

@implementation NSNumber(Utilities)


- (NSComparisonResult)reverseCompare:(NSNumber *)aNumber {
    return [aNumber compare:self];
}

@end
