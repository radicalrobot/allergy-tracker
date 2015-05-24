//
//  MHPScheduleDayHeaderView.h
//  MHPParkinsons
//
//  Created by Emily Toop on 15/04/2014.
//  Copyright (c) 2014 My Health Pal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TriangleView.h"
#import "BorderedView.h"

@interface PagingHeaderView : BorderedView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong, readonly) TriangleView *rightArrow;
@property (nonatomic, strong, readonly) TriangleView *leftArrow;

@end
