//
//  SummaryHeaderView.m
//  AllergyTracker
//
//  Created by Emily Toop on 19/03/2016.
//  Copyright © 2016 Radical Robot. All rights reserved.
//

#import "SummaryHeaderView.h"
#import "Interaction+Extras.h"
#import "Incidence+Extras.h"
#import "Symptom+Extras.h"
#import <MagicalRecord/MagicalRecord.h>

@interface SummaryHeaderView () {
    NSDate *_dayStart;
    NSDate *_dayEnd;
}

@property (nonatomic, strong) NSMutableArray* summaryViews;

@end

@implementation SummaryHeaderView

-(instancetype)initWithSymptoms:(NSArray*) symptoms interactions:(NSArray *)interactions forDate:(NSDate*)date {
    if(self = [super initWithFrame:CGRectZero]) {
        self.interactions = interactions;
        self.symptoms = symptoms;
        self.summaryViews = [NSMutableArray array];
        self.maxNumberOfCellsInRow = 4;
        self.date = date;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    int numberOfRows = ceil((CGFloat)_summaryViews.count / (CGFloat)_maxNumberOfCellsInRow);
    CGFloat width = self.bounds.size.width / MIN(_summaryViews.count, _maxNumberOfCellsInRow);
    CGFloat height = self.bounds.size.height / numberOfRows;
    
    int currentRow = 0;
    int currentCell = 0;
    for(UIView *view in _summaryViews) {
        if(!view.superview) {
            [self addSubview:view];
        }
        [view.topAnchor constraintEqualToAnchor:self.topAnchor constant:height * currentRow].active = true;
        [view.heightAnchor constraintEqualToConstant:height].active = true;
        [view.widthAnchor constraintEqualToConstant:width].active = true;
        [view.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:width * currentCell].active = true;
        [view updateConstraints];
        currentCell++;
        if(currentCell == _maxNumberOfCellsInRow) {
            currentRow++;
            currentCell = 0;
        }
    }
}

-(void)setDate:(NSDate *)date {
    _date = date;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    _dayStart = [calendar dateBySettingHour:0  minute:0  second:0  ofDate:date options:0];
    _dayEnd   = [calendar dateBySettingHour:23 minute:59 second:59 ofDate:date options:0];
    
    [_summaryViews removeAllObjects];
    
    for(Symptom *symptom in _symptoms) {
        NSNumber *numberOfIncidents = [Incidence MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"time >= %@ && time <= %@ && type=[c]%@", _dayStart, _dayEnd, symptom.name]];
        if(numberOfIncidents.intValue > 0) {
            [_summaryViews addObject:[self summaryViewWithTitle:symptom.name numberOfIncidents:numberOfIncidents]];
        }
    }
    
    for(Interaction *interaction in _interactions) {
        NSNumber *numberOfIncidents = [Incidence MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"time >= %@ && time <= %@ && type=[c]%@", _dayStart, _dayEnd, interaction.name]];
        if(numberOfIncidents.intValue > 0) {
            [_summaryViews addObject:[self summaryViewWithTitle:interaction.name numberOfIncidents:numberOfIncidents]];
        }
    }
    
    [self setNeedsLayout];
}

-(UIView*)summaryViewWithTitle:(NSString*)title numberOfIncidents:(NSNumber*)numberOfIncidents {
    UIView *view = [UIView new];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    view.layer.borderColor= [UIColor lightGrayColor].CGColor;
    view.layer.borderWidth= 0.5f;
    UILabel *titleLabel = [UILabel new];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    titleLabel.text = [title capitalizedString];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 2;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [view addSubview:titleLabel];
    [titleLabel.topAnchor constraintEqualToAnchor:view.topAnchor constant:5].active = true;
    [titleLabel.leftAnchor constraintEqualToAnchor:view.leftAnchor constant:2].active = true;
    [titleLabel.rightAnchor constraintEqualToAnchor:view.rightAnchor constant:-2].active = true;
    UILabel *numberLabel = [UILabel new];
    [numberLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    numberLabel.text = [numberOfIncidents stringValue];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.font = [UIFont boldSystemFontOfSize:17];
    if(numberOfIncidents.intValue > 5) {
        numberLabel.textColor = [UIColor redColor];
    } else if(numberOfIncidents.intValue > 3) {
        numberLabel.textColor = [UIColor yellowColor];
    } else {
        numberLabel.textColor = [UIColor colorWithRed:0.0 green:0.39 blue:0.0 alpha:1.0];
    }
    [view addSubview:numberLabel];
    [numberLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor].active = true;
    [numberLabel.leftAnchor constraintEqualToAnchor:view.leftAnchor constant:2].active = true;
    [numberLabel.rightAnchor constraintEqualToAnchor:view.rightAnchor constant:-2].active = true;
    [numberLabel.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:-5].active = true;
    return view;
}

@end
