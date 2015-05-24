//
//  RRPagingTableViewDelegate.h
//  PagingTableView
//
//  Created by Emily Toop on 29/04/2014.
//  Copyright (c) 2014 Radical Robot. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PagingViewControllerDelegate <NSObject>

-(UIView*)viewForPageAtIndex:(NSInteger)index;
-(NSString*)titleForPageAtIndex:(NSInteger)index;
-(BOOL)canProvidePreviousPage:(NSInteger)index;
-(BOOL)canProvideNextPage:(NSInteger)index;

@optional
-(void)pageDidChangeFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end
