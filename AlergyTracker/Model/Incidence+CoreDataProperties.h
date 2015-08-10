//
//  Incidence+CoreDataProperties.h
//  AllergyTracker
//
//  Created by Emily Toop on 09/08/2015.
//  Copyright © 2015 Radical Robot. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

#import "Incidence.h"

NS_ASSUME_NONNULL_BEGIN

@interface Incidence (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *formattedTime;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *notes;
@property (nullable, nonatomic, retain) NSDate *time;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *uuid;

@end

NS_ASSUME_NONNULL_END
