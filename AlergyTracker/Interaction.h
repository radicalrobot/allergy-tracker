//
//  Interaction.h
//  AlergyTracker
//
//  Created by Emily Toop on 22/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Interaction : NSManagedObject

@property (nonatomic, retain) NSString * interactionId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * selected;

@end
