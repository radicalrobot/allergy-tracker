//
//  MagicalRecord+BackgroundTask.h
//  AllergyTracker
//
//  Created by Emily Toop on 13/03/2016.
//  Copyright © 2016 Radical Robot. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>

@interface MagicalRecord (BackgroundTask)

+ (void) saveOnBackgroundThreadWithBlock:(void(^)(NSManagedObjectContext *localContext))block;
+ (void) saveOnBackgroundThreadWithBlock:(void(^)(NSManagedObjectContext *localContext))block completion:(MRSaveCompletionHandler)completion;
+ (void) saveOnBackgroundThreadWithBlockAndWait:(void(^)(NSManagedObjectContext *localContext))block;

@end
