//
//  Symptom.h
//  AlergyTracker
//
//  Created by Emily Toop on 22/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Symptom : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * symptomId;
@property (nonatomic, retain) NSNumber * selected;

@end
