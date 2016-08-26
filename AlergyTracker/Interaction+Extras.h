//
//  Interaction+Extras.h
//  AlergyTracker
//
//  Created by Emily Toop on 11/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "Interaction.h"

#import <CloudKit/CloudKit.h>

@interface Interaction (Extras)

@property (nonatomic, readonly) NSString* displayName;

-(CKRecord *)cloudKitRecord;

@end
