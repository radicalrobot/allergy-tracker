//
//  IncidenceTableViewController.h
//  AlergyTracker
//
//  Created by Emily Toop on 04/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IncidenceTableViewController : UITableViewController

@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, weak) UIViewController *parentController;

@end
