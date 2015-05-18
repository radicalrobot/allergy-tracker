//
//  UIView+FrameAccessors.h
//  AllergyTracker
//
//  Created by Emily Toop on 18/05/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameAccessors)

@property (nonatomic) CGSize size;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;

@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat right;

@end
