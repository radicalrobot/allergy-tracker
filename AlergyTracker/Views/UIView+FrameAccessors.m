//
//  UIView+FrameAccessors.m
//  AllergyTracker
//
//  Created by Emily Toop on 18/05/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "UIView+FrameAccessors.h"

@implementation UIView(FrameAccessors)

-(CGSize)size {
    return self.bounds.size;
}

-(void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

-(CGFloat)height {
    return self.bounds.size.height;
}

-(void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

-(CGFloat)width {
    return self.bounds.size.width;
}

-(void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

-(CGPoint)origin {
    return self.frame.origin;
}

-(void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

-(CGFloat)x {
    return self.frame.origin.x;
}

-(void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

-(CGFloat)y {
    return self.frame.origin.y;
}

-(void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

-(CGFloat)centerX {
    return self.center.x;
}

-(void)setCenterX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

-(CGFloat)centerY {
    return self.center.y;
}

-(void)setCenterY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

-(CGFloat)top {
    return self.y;
}

-(void)setTop:(CGFloat)top {
    self.y = top;
}

-(CGFloat)right {
    return self.x + self.width;
}

-(void)setRight:(CGFloat)right {
    self.x = right - self.width;
}

-(CGFloat)bottom {
    return self.y + self.height;
}

-(void)setBottom:(CGFloat)bottom {
    self.y = bottom - self.height;
}

-(CGFloat)left {
    return self.x;
}

-(void)setLeft:(CGFloat)left {
    self.x = left;
}

@end
