//
//  Interaction+Extras.m
//  AlergyTracker
//
//  Created by Emily Toop on 11/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "Interaction+Extras.h"

@implementation Interaction (Extras)

-(void)awakeFromInsert {
    [super awakeFromInsert];
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    self.interactionId = (__bridge_transfer NSString *)string;
}

@end
