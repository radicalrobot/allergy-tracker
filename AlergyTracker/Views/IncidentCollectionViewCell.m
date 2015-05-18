//
//  IncidentCollectionViewCell.m
//  AlergyTracker
//
//  Created by Emily Toop on 23/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "IncidentCollectionViewCell.h"

@implementation IncidentCollectionViewCell

-(void)flash {
    UIColor *originalColor = self.backgroundColor;
    [UIView animateWithDuration:0.1 animations:^{
        self.backgroundColor = [UIColor colorWithRed:170/255 green:170/255 blue:170/255 alpha:0.0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.backgroundColor = originalColor;
        } completion:nil];
    }];
}

@end
