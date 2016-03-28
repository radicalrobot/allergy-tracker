//
//  Incidence+Extras.h
//  AlergyTracker
//
//  Created by Emily Toop on 27/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "Incidence.h"

@interface Incidence(Extras)

+(NSArray*)getTopIncidents;
+(NSArray*)getTopIncidentsWithLimit:(int)limit;

@end
