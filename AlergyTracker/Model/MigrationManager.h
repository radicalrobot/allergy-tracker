//
//  MigrationManager.h
//  AlergyTracker
//
//  Created by Emily Toop on 24/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MigrationManager : NSObject

+(instancetype) sharedInstance;

-(void)migrateFromVersion:(NSString*)version;

@end
