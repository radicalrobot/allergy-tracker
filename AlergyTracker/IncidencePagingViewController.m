//
//  IncidencePagingViewController.m
//  AllergyTracker
//
//  Created by Emily Toop on 24/05/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "IncidencePagingViewController.h"

#import "NSDate+Utilities.h"
#import "EditIncidenceViewController.h"

@interface IncidencePagingViewController ()

@property (nonatomic, strong) IncidenceTableViewController *currentController;
@property (nonatomic, strong) IncidenceTableViewController *lastController;

@end

@implementation IncidencePagingViewController

static NSString * const PresentationViewStoryboardID = @"IncidenceTableViewController";
static NSString * const kSegueIdentifier = @"EditIncidenceSegue";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PagingViewControllerDelegate

-(UIView *)viewForPageAtIndex:(NSInteger)index {
    self.lastController = self.currentController;
    self.currentController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:PresentationViewStoryboardID];
    self.currentController.currentDate = [[NSDate date] rr_addNumberOfDays:index];
    self.currentController.parentController = self;
    [self.currentController viewWillAppear:YES];
    return self.currentController.view;
}

-(NSString *)titleForPageAtIndex:(NSInteger)index {
    return [self titleTextForDate:self.currentController.currentDate];
}

-(BOOL)canProvideNextPage:(NSInteger)index {
    if([self.currentController.currentDate rr_isSameDayAsDate:[NSDate date]]) {
        return NO;
    }
    
    return YES;
}

-(BOOL)canProvidePreviousPage:(NSInteger)index {
    return YES;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:kSegueIdentifier]) {
        Incidence *selectedIncidence = (Incidence*)sender;
        EditIncidenceViewController *eivc = (EditIncidenceViewController*)segue.destinationViewController;
        eivc.incidence = selectedIncidence;
    }
}

@end