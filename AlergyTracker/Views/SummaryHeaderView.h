//
//  SummaryHeaderView.h
//  AllergyTracker
//
//  Created by Emily Toop on 19/03/2016.
//  Copyright © 2016 Radical Robot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryHeaderView : UIView

@property (nonatomic, strong) NSArray* symptoms;
@property (nonatomic, strong) NSArray* interactions;
@property (nonatomic, strong) NSDate* date;

@property (nonatomic) CGFloat maxRowHeight;
@property (nonatomic) int maxNumberOfCellsInRow;

//-(instancetype) initWithSymptoms: (NSArray*) symptoms interactions: (NSArray*) interactions forDate:(NSDate*)date;

@end
