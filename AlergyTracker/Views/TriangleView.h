//
//  RRTriangleView.h
//  CoreGraphicsDrawing
//
//  Created by Emily Toop on 11/04/2014.
//  Copyright (c) 2014 Radical Robot. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MHPTriangleDirectionUp,
    MHPTriangleDirectionDown,
    MHPTriangleDirectionLeft,
    MHPTriangleDirectionRight
} TriangleDirection;

@interface TriangleView : UIView

@property (nonatomic) CGSize triangleSize;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic) TriangleDirection direction;
@property (nonatomic, assign) BOOL enabled;
@end
