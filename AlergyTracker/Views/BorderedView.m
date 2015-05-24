//
//  MHPBorderedView.m
//  MHPParkinsons
//
//  Created by Emily Toop on 02/04/2014.
//  Copyright (c) 2014 My Health Pal. All rights reserved.
//

#import "BorderedView.h"

#import "UIColor+Utilities.h"

@implementation BorderedView

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor rr_borderColor].CGColor;
    bottomBorder.borderWidth = 0.5;
    bottomBorder.frame = CGRectMake(-1, 0, CGRectGetWidth(self.bounds) + 2, CGRectGetHeight(self.bounds));
    
    [self.layer addSublayer:bottomBorder];
}

@end
