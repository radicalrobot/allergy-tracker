//
//  Interaction+Extras.m
//  AlergyTracker
//
//  Created by Emily Toop on 11/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "Interaction+Extras.h"

@implementation Interaction (Extras)

-(NSString*)displayName {
    return [self.name capitalizedStringWithLocale:[NSLocale currentLocale]];
}

-(void)awakeFromInsert {
    [super awakeFromInsert];
    self.interactionId = [[NSUUID UUID] UUIDString];
}

@end
