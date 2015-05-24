//
//  RRTriangleView.m
//  CoreGraphicsDrawing
//
//  Created by Emily Toop on 11/04/2014.
//  Copyright (c) 2014 Radical Robot. All rights reserved.
//

#import "TriangleView.h"

@implementation TriangleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.enabled = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(UIColor *)fillColor
{
    if(!_fillColor)
    {
        _fillColor = [UIColor blackColor];
    }
    
    return _fillColor;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    [self setNeedsDisplay];
}

-(CGSize)triangleSize
{
    if(_triangleSize.width == CGSizeZero.width
       && _triangleSize.height == CGSizeZero.height)
    {
        _triangleSize = self.bounds.size;
    }
    return _triangleSize;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGPoint baseStartPoint = CGPointZero, baseEndPoint = CGPointZero, tipPoint = CGPointZero;
    CGPoint anchorPoint = (CGPoint){(self.bounds.size.width - self.triangleSize.width)/2, (self.bounds.size.height - self.triangleSize.height)/2};
    
    if(self.direction == MHPTriangleDirectionRight)
    {
        baseStartPoint = (CGPoint){anchorPoint.x, anchorPoint.y};
        baseEndPoint = (CGPoint){anchorPoint.x, anchorPoint.y + self.triangleSize.height};
        tipPoint = (CGPoint){anchorPoint.x + self.triangleSize.width, self.bounds.size.height/2};
    }
    else if(self.direction == MHPTriangleDirectionLeft)
    {
        baseStartPoint = (CGPoint){anchorPoint.x + self.triangleSize.width, anchorPoint.y};
        baseEndPoint = (CGPoint){anchorPoint.x + self.triangleSize.width,anchorPoint.y + self.triangleSize.height};
        tipPoint = (CGPoint){anchorPoint.x, self.bounds.size.height/2};
    }
    else if(self.direction == MHPTriangleDirectionUp)
    {
        baseStartPoint = (CGPoint){anchorPoint.x, (self.bounds.size.height + self.triangleSize.height)/2};
        baseEndPoint = (CGPoint){anchorPoint.x + self.triangleSize.width,(self.bounds.size.height + self.triangleSize.height)/2};
        tipPoint = (CGPoint){self.bounds.size.width/2, anchorPoint.y};
    }
    else if(self.direction == MHPTriangleDirectionDown)
    {
        baseStartPoint = (CGPoint){anchorPoint.x,anchorPoint.y};
        baseEndPoint = (CGPoint){anchorPoint.x + self.triangleSize.width,anchorPoint.y};
        tipPoint = (CGPoint){self.bounds.size.width/2, self.triangleSize.height + anchorPoint.y};
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Drawing code
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL,baseStartPoint.x, baseStartPoint.y);
    CGPathAddLineToPoint(path, NULL,baseEndPoint.x,baseEndPoint.y);
    CGPathAddLineToPoint(path, NULL,tipPoint.x,tipPoint.y);
    CGPathAddLineToPoint(path, NULL,baseStartPoint.x,baseStartPoint.y);
    CGPathCloseSubpath(path);
    
    CGContextSetFillColorWithColor(context, (self.enabled ? self.fillColor.CGColor : [UIColor lightGrayColor].CGColor));
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    CGPathRelease(path);
}


@end
