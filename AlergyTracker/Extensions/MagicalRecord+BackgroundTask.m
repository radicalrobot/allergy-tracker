//
//  MagicalRecord+BackgroundTask.m
//  AllergyTracker
//
//  Created by Emily Toop on 13/03/2016.
//  Copyright © 2016 Radical Robot. All rights reserved.
//

#import "MagicalRecord+BackgroundTask.h"

@implementation MagicalRecord (BackgroundTask)

+(void)saveOnBackgroundThreadWithBlock:(void (^)(NSManagedObjectContext *))block {
    [self saveOnBackgroundThreadWithBlock:block completion:nil];
}

+(void)saveOnBackgroundThreadWithBlock:(void(^)(NSManagedObjectContext *localContext))block completion:(MRSaveCompletionHandler)completion {
    UIApplication *application = [UIApplication sharedApplication];
    
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    [MagicalRecord saveWithBlock:block completion:^(BOOL success, NSError *error) {
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
        if(completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success, error);
            });
        }
    }];
}

+(void)saveOnBackgroundThreadWithBlockAndWait:(void (^)(NSManagedObjectContext *))block {
    UIApplication *application = [UIApplication sharedApplication];
    
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    [MagicalRecord saveWithBlockAndWait:block];
    
    [application endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
}

@end
