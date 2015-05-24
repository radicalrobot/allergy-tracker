//
//  MHPScheduleDayHeaderView.m
//  MHPParkinsons
//
//  Created by Emily Toop on 15/04/2014.
//  Copyright (c) 2014 My Health Pal. All rights reserved.
//

#import "PagingHeaderView.h"
#import "UIColor+Utilities.h"

@implementation PagingHeaderView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self _setupViews];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect arrowFrame = self.bounds;
    arrowFrame.size.height -= 1;
    arrowFrame.size.width = arrowFrame.size.height;
    _leftArrow.frame = arrowFrame;
    _leftArrow.backgroundColor = self.backgroundColor;
    
    if(!_titleLabel.superview)
    {
        [self insertSubview:_titleLabel atIndex:0];
        CGRect labelFrame = self.bounds;
        labelFrame.origin.x = arrowFrame.size.width;
        labelFrame.size.width = self.bounds.size.width - (arrowFrame.size.width * 2);
        _titleLabel.frame = labelFrame;
    }
    
    if(!_leftArrow.superview)
        [self addSubview:_leftArrow];
    
    if(!_rightArrow.superview)
        [self addSubview:_rightArrow];
    
    arrowFrame.origin.x = self.bounds.size.width - arrowFrame.size.width;
    _rightArrow.frame = arrowFrame;
    _rightArrow.backgroundColor = self.backgroundColor;
    
}

-(void)_setupViews
{
    if(!_titleLabel)
    {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    
    if(!_rightArrow)
    {
        _rightArrow = [TriangleView new];
        _rightArrow.direction = MHPTriangleDirectionRight;
        _rightArrow.triangleSize = (CGSize){10,10};
        _rightArrow.fillColor = [UIColor rr_foregroundColor];
        _rightArrow.userInteractionEnabled = YES;
    }
    
    if(!_leftArrow)
    {
        _leftArrow = [TriangleView new];
        _leftArrow.direction = MHPTriangleDirectionLeft;
        _leftArrow.triangleSize = (CGSize){10,10};
        _leftArrow.fillColor = [UIColor rr_foregroundColor];
        _leftArrow.userInteractionEnabled = YES;
    }
}

@end
