//
//  Incidence+Extras.h
//  AlergyTracker
//
//  Created by Emily Toop on 27/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "Incidence.h"

#import <CloudKit/CloudKit.h>

@interface Incidence(Extras)

@property (nonatomic, readonly) NSString * displayName;

+(NSArray*)getTopIncidents;
+(NSArray*)getTopIncidentsWithLimit:(int)limit;

-(CKRecord *)cloudKitRecord;

@end
