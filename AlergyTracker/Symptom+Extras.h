//
//  Symptom+Extras.h
//  AlergyTracker
//
//  Created by Emily Toop on 11/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "Symptom.h"

@interface Symptom (Extras)

@property (nonnull, readonly) NSString *displayName;

+(NSArray * _Nullable ) alphabeticacisedSymptomsSelected:(bool) selected;

@end
