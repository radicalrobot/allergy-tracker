//
//  QuickActions.h
//  AllergyTracker
//
//  Created by Emily Toop on 28/03/2016.
//  Copyright © 2016 Radical Robot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    LogInteraction,
    MarkLocation
} ShortcutType;

@interface QuickActions : NSObject

+(void)addTopIncidents: (NSArray*) incidents;
+(BOOL) handleShortcut: (UIApplicationShortcutItem*) item;

@end
