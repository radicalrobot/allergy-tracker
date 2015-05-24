//
//  UIColor+Utilities.m
//  AllergyTracker
//
//  Created by Emily Toop on 24/05/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "UIColor+Utilities.h"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation UIColor (Utilities)

+(UIColor *)rr_backgroundColor {
    return RGB(170, 170, 170);
}

+(UIColor *)rr_foregroundColor {
    return RGB(74,171,186);
}

+(UIColor *)rr_borderColor {
    return RGB(167, 167, 170);
}

@end
