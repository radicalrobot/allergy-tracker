//
//  IncidentCollectionViewCell.m
//  AlergyTracker
//
//  Created by Emily Toop on 23/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "IncidentCollectionViewCell.h"
#import "UIColor+Utilities.h"

@implementation IncidentCollectionViewCell

-(void)flash {
    UIColor *originalColor = self.backgroundColor;
    [UIView animateWithDuration:0.1 animations:^{
        self.backgroundColor = [UIColor rr_backgroundColor];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.backgroundColor = originalColor;
        } completion:nil];
    }];
}

@end
