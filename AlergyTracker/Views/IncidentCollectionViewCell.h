//
//  IncidentCollectionViewCell.h
//  AlergyTracker
//
//  Created by Emily Toop on 23/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IncidentCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *symptomNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *incidenceCountLabel;

-(void)flash;

@end
