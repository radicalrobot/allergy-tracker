//
//  RRViewController.m
//  PagingTableView
//
//  Created by Emily Toop on 29/04/2014.
//  Copyright (c) 2014 Radical Robot. All rights reserved.
//

#import "PagingViewController.h"
#import "NSDate+Utilities.h"
#import "NSDateFormatter+Utilities.h"

@interface PagingViewController ()
{
    BOOL _isAnimating;
    NSInteger _currentPageIndex;
}

@property (nonatomic, strong) UIView *internalPageView;

@end

@implementation PagingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _isAnimating = NO;
    _currentPageIndex = 0;
    
    CGRect headerViewFrame = self.view.frame; 
    if (![UIApplication sharedApplication].statusBarHidden)
        headerViewFrame.origin.y += 20;
    if(self.navigationController)
        headerViewFrame.origin.y += 44;
    headerViewFrame.size.height = 44;
    _headerView = [PagingHeaderView new];
    _headerView.frame = headerViewFrame;
    _headerView.backgroundColor = [UIColor clearColor];
    
    
    // add an arrow on the left hand side of the title
    UITapGestureRecognizer *rightTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_rightArrowTapped:)];
    rightTap.numberOfTapsRequired = 1;
    [_headerView.rightArrow addGestureRecognizer:rightTap];
    
    UITapGestureRecognizer *leftTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_leftArrowTapped:)];
    leftTap.numberOfTapsRequired = 1;
    [_headerView.leftArrow addGestureRecognizer:leftTap];
    
    [self.view addSubview:_headerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(_internalPageView)
    {
        [_internalPageView removeFromSuperview];
    }
    
    _internalPageView = [self viewForPageAtIndex:_currentPageIndex];
    CGRect pageViewFrame = self.view.frame;
    pageViewFrame.origin.y = _headerView.frame.origin.y + _headerView.frame.size.height;
    pageViewFrame.size.height -= pageViewFrame.origin.y;
    // reduce the height of the page view if there is a tab bar controller
    if((self.tabBarController && !self.tabBarController.tabBar.hidden)
       || (self.navigationController.tabBarController && !self.navigationController.tabBarController.tabBar.hidden))
        pageViewFrame.size.height -= 49;
    _internalPageView.frame = pageViewFrame;
    [self.view addSubview:_internalPageView];
    
    _internalPageView.backgroundColor = [UIColor clearColor];
    
    UISwipeGestureRecognizer *rightRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_pageSwiped:)];
    rightRecogniser.direction = UISwipeGestureRecognizerDirectionRight;
    [_internalPageView addGestureRecognizer:rightRecogniser];
    
    UISwipeGestureRecognizer *leftRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_pageSwiped:)];
    leftRecogniser.direction = UISwipeGestureRecognizerDirectionLeft;
    [_internalPageView addGestureRecognizer:leftRecogniser];
    
    _headerView.titleLabel.text = [self titleForPageAtIndex:_currentPageIndex];
    _headerView.leftArrow.enabled = [self canProvidePreviousPage:_currentPageIndex];
    _headerView.rightArrow.enabled = [self canProvideNextPage:_currentPageIndex];
}

#pragma mark - getters

-(UIView *)pageView
{
    return _internalPageView;
}

#pragma mark - private

-(void)_changePageFromIndex:(NSInteger)currentIndex toIndex:(NSInteger)newPageIndex
{
    // get the view for the next page
    UIView *nextPageView = [self _viewForPageAtIndex:newPageIndex];
    [self.view addSubview:nextPageView];
    
    // amend the title header
    UILabel *newLabel = [self _labelForPageAtIndex:newPageIndex];
    [self.headerView insertSubview:newLabel atIndex:0];
    
    // get the frames that we need to animate each view to
    CGRect newFrameForNewView = self.pageView.frame;
    CGRect newFrameForOldView = newFrameForNewView;
    
    CGRect newFrameForNewLabel = self.headerView.titleLabel.frame;
    CGRect newFrameForOldLabel = newFrameForNewLabel;
    
    
    if(newPageIndex < currentIndex)
    {
        newFrameForOldView.origin.x = newFrameForNewView.size.width;
        newFrameForOldLabel.origin.x = newFrameForNewLabel.size.width;
    }
    else
    {
        newFrameForOldView.origin.x = 0 - newFrameForNewView.size.width;
        newFrameForOldLabel.origin.x = 0 - newFrameForNewLabel.size.width;
    }
    
    // set our animating flag so we don't have to worry about multiple transition requests while we're performing a page transition
    _isAnimating = YES;

    _headerView.leftArrow.enabled = [self canProvidePreviousPage:newPageIndex];
    _headerView.rightArrow.enabled = [self canProvideNextPage:newPageIndex];

    // do the animation and then clear up after ourselves
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        nextPageView.frame = newFrameForNewView;
        self.pageView.frame = newFrameForOldView;
        
        newLabel.frame = newFrameForNewLabel;
        self.headerView.titleLabel.frame = newFrameForOldLabel;

    } completion:^(BOOL finished) {
        [_internalPageView removeFromSuperview];
        _internalPageView = nextPageView;
        [self.headerView.titleLabel removeFromSuperview];
        self.headerView.titleLabel = newLabel;
        
        _isAnimating = NO;
        
        // perform any post page change requirements
        if([self respondsToSelector:@selector(pageDidChangeFromIndex:toIndex:)])
            [self pageDidChangeFromIndex:_currentPageIndex toIndex:newPageIndex];
        
        // update our current page index for future use
        _currentPageIndex = newPageIndex;

    }];
}

- (void)resetDefaultPage {
    if( _currentPageIndex != 0 ) {
        [self _changePageFromIndex:_currentPageIndex toIndex:0];
    }
}

-(void)_rightArrowTapped:(UIGestureRecognizer*)recognizer
{
    NSInteger targetIndex = _currentPageIndex + 1;
    if(!_isAnimating && recognizer.state == UIGestureRecognizerStateEnded && [self canProvideNextPage:_currentPageIndex])
    {
        [self _changePageFromIndex:_currentPageIndex toIndex:targetIndex];
        
        // and position it off the screen to the right
        
        // disable the button until after the animation has completed
        // transition it from the right while transitioning the current view off to the left
        // also transition off the title label for the header view to the left while transitioning the title view for the next date on from the right
        // replace dayScheduleView with new view and get rid of old one
        
    }
}

-(void)_leftArrowTapped:(UIGestureRecognizer*)recognizer
{
    NSInteger targetIndex = _currentPageIndex - 1;
    if(!_isAnimating && recognizer.state == UIGestureRecognizerStateEnded && [self canProvidePreviousPage:_currentPageIndex] )
    {
        [self _changePageFromIndex:_currentPageIndex toIndex:targetIndex];
    }
}

-(void)_pageSwiped:(UISwipeGestureRecognizer*)recogniser
{
    if(recogniser.state == UIGestureRecognizerStateEnded)
    {
        if(recogniser.direction == UISwipeGestureRecognizerDirectionRight)
            [self _leftArrowTapped:recogniser];
        else
            [self _rightArrowTapped:recogniser];
    }
}


-(UILabel*)_labelForPageAtIndex:(NSInteger)pageIndex
{
    UILabel *newLabel = [UILabel new];
    CGRect frame = self.headerView.titleLabel.frame;
    
    if(pageIndex > _currentPageIndex)
        frame.origin.x += frame.size.width;
    else
        frame.origin.x -= frame.size.width;
    
    newLabel.textAlignment = NSTextAlignmentCenter;
    newLabel.backgroundColor = [UIColor clearColor];
    newLabel.text = [self titleForPageAtIndex:pageIndex];
    newLabel.frame = frame;
    [self.headerView insertSubview:newLabel atIndex:0];
    
    return newLabel;
}


-(UIView*)_viewForPageAtIndex:(NSInteger)pageIndex
{
    // create new day schedule view
    // and position it off to the left
    UIView *nextPageView = [self viewForPageAtIndex:pageIndex];
    CGRect pageViewFrame = self.pageView.frame;
    
    if(pageIndex > _currentPageIndex)
        pageViewFrame.origin.x = pageViewFrame.size.width;
    else
        pageViewFrame.origin.x = 0 - pageViewFrame.size.width;
    nextPageView.frame = pageViewFrame;
    
    UISwipeGestureRecognizer *rightRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_pageSwiped:)];
    rightRecogniser.direction = UISwipeGestureRecognizerDirectionRight;
    [nextPageView addGestureRecognizer:rightRecogniser];
    
    UISwipeGestureRecognizer *leftRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_pageSwiped:)];
    leftRecogniser.direction = UISwipeGestureRecognizerDirectionLeft;
    [nextPageView addGestureRecognizer:leftRecogniser];
    
    return nextPageView;
}

#pragma mark - RRPaginTableViewDelegate

-(UIView *)viewForPageAtIndex:(NSInteger)index
{
    [NSException raise:@"Incomplete Class" format:@"You must override viewForPageAtIndex: in a subclass in order to use this class"];
    return nil;
}

-(NSString *)titleForPageAtIndex:(NSInteger)index
{
    [NSException raise:@"Incomplete Class" format:@"You must override titleForPageAtIndex: in a subclass in order to use this class"];
    return nil;
}

- (BOOL)canProvidePreviousPage:(NSInteger)index {
    return NO;
}
- (BOOL)canProvideNextPage:(NSInteger)index {
    return NO;
}

-(NSString*)titleTextForDate:(NSDate*)date
{
    NSString *titleTextForDate;
    NSDate *today = [NSDate date];
    NSDate *tomorrow = [today rr_addNumberOfDays:1];
    NSDate *yesterday = [today rr_addNumberOfDays:-1];

    if([date rr_isSameDayAsDate:[NSDate date]])
    {
        titleTextForDate = @"Today";
    }
    else if([date rr_isSameDayAsDate:tomorrow])
    {
        titleTextForDate = @"Tomorrow";
    }
    else if([date rr_isSameDayAsDate:yesterday])
    {
        titleTextForDate = @"Yesterday";
    }
    else
    {
        titleTextForDate = [[NSDateFormatter rr_dateFormatter] stringFromDate:date];
    }
    return titleTextForDate;
}
@end
