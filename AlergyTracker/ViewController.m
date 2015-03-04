//
//  ViewController.m
//  AlergyTracker
//
//  Created by Emily Toop on 03/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "ViewController.h"

#import "RRLocationManager.h"
#import "Incidence.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *foreground;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.foreground addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tapped:(UIGestureRecognizer*) recogniser {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.foreground.backgroundColor = [UIColor colorWithRed:170/255 green:170/255 blue:170/255 alpha:0.0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            self.foreground.backgroundColor = [UIColor lightGrayColor];
        } completion:nil];
    }];
//    CLLocation *currentLocation = [RRLocationManager currentLocation];
//    __block Incidence *incidence;
//    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
//        incidence = [Incidence MR_createInContext:localContext];
//        incidence.latitude = @(currentLocation.coordinate.latitude);
//        incidence.longitude = @(currentLocation.coordinate.longitude);
//        incidence.time = [NSDate date];
//    } completion:nil];
}
@end
