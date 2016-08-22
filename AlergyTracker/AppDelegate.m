//
//  AppDelegate.m
//  AlergyTracker
//
//  Created by Emily Toop on 03/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "AppDelegate.h"
#import "RRLocationManager.h"
#import "LocalDataManager.h"
#import "Incidence+Extras.h"
#import "QuickActions.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Analytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Fabric with:@[CrashlyticsKit]];
    [SEGAnalytics setupWithConfiguration:[SEGAnalyticsConfiguration configurationWithWriteKey:@"FoGKredUEwSGQq3SLZyBkKvcsO9PJV8e"]];
    [[SEGAnalytics sharedAnalytics] identify:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                      traits:@{ @"name": [[UIDevice currentDevice] name]}];
    [LocalDataManager setup];
    
    [RRLocationManager start];
    
    if([[launchOptions allKeys] containsObject:UIApplicationLaunchOptionsShortcutItemKey]) {
        UIApplicationShortcutItem *shortcutItem = launchOptions[UIApplicationLaunchOptionsShortcutItemKey];
        [QuickActions handleShortcut:shortcutItem];
        return NO;
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSArray *top2Incidents = [Incidence getTopIncidentsWithLimit:2];
    [QuickActions addTopIncidents: top2Incidents];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [LocalDataManager cleanup];
}

-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    completionHandler([QuickActions handleShortcut:shortcutItem]);
}

@end
