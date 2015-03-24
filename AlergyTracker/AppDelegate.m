//
//  AppDelegate.m
//  AlergyTracker
//
//  Created by Emily Toop on 03/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "AppDelegate.h"
#import "RRLocationManager.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "Symptom+Extras.h"
#import "Interaction+Extras.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    [RRLocationManager start];
    
    [self setupData];
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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [MagicalRecord cleanUp];
}

-(void)setupData {
    NSArray *symptoms = @[@"wheezy",
                          @"vomiting",
                          @"hives",
                          @"diarrhea",
                          @"itchy skin",
                          @"rash",
                          @"swollen throat",
                          @"low blood pressure",
                          @"runny nose",
                          @"abdominal pain",
                          @"headaches",
                          @"anxiety",
                          @"itchy eye",
                          @"watery eye",
                          @"swelling",
                          @"nausea",
                          @"dizziness",
                          @"runny nose",
                          @"stuffy nose",
                          @"sneeze",
                          @"cough",
                          @"conjunctivitis",
                          @"nosebleed",
                          @"itchy nose"];
    
    NSArray *interactions = @[@"Dairy",
                              @"Eggs",
                              @"Wheat",
                              @"Nuts",
                              @"Fish",
                              @"Shellfish",
                              @"Soy",
                              @"Pollen",
                              @"Mould",
                              @"Dog",
                              @"Cat",
                              @"Dust",
                              @"Alcohol"];
    
    __block Symptom *symptom;
    __block Interaction *interaction;
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        for(NSString *symptomName in symptoms) {
            symptom = [Symptom MR_findFirstByAttribute:@"name" withValue:symptomName inContext:localContext];
            if(!symptom){
                symptom = [Symptom MR_createInContext:localContext];
                symptom.name = symptomName;
            }
        }
        
        for(NSString *interactionName in interactions) {
            interaction = [Interaction MR_findFirstByAttribute:@"name" withValue:interactionName inContext:localContext];
            if(!interaction){
                interaction = [Interaction MR_createInContext:localContext];
                interaction.name = interactionName;
            }
        }
    }];
}

@end
