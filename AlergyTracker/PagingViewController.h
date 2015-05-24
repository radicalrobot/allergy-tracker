//
//  RRViewController.h
//  PagingTableView
//
//  Created by Emily Toop on 29/04/2014.
//  Copyright (c) 2014 Radical Robot. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PagingHeaderView.h"
#import "PagingViewControllerDelegate.h"


@interface PagingViewController : UIViewController<PagingViewControllerDelegate>

@property (nonatomic, strong, readonly) UIView *pageView;
@property (nonatomic, strong, readonly) PagingHeaderView *headerView;

- (void)resetDefaultPage;

- (NSString *)titleTextForDate:(NSDate *)date;
@end
