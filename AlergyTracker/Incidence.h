//
//  Incidence.h
//  AlergyTracker
//
//  Created by Emily Toop on 04/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Incidence : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * type;

@end
