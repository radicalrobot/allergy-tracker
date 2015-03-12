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
@property (weak, nonatomic) IBOutlet UIButton *incidenceNumber;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pillButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *catButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dogButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pollenButton;

@end

@implementation ViewController

static NSString* const kIncidenceSegue = @"IncidentViewSegue";

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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateIncidence];
    [self setupMedicationNotification];
}

-(void)setupMedicationNotification {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDate *from = [calendar dateBySettingHour:0  minute:0  second:0  ofDate:now options:0];
    NSDate *to   = [calendar dateBySettingHour:23 minute:59 second:59 ofDate:now options:0];
    
    NSNumber *numberOfIncidents = [Incidence MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"time >= %@ && time <= %@ && type='Medication'", from, to]];
    if([numberOfIncidents intValue] > 0){
        [self.pillButton setImage:[UIImage imageNamed:@"PillFilled"]];
    }
    else {
        [self.pillButton setImage:[UIImage imageNamed:@"Pill"]];
    }
    numberOfIncidents = [Incidence MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"time >= %@ && time <= %@ && type='Cat'", from, to]];
    if([numberOfIncidents intValue] > 0){
        [self.catButton setImage:[UIImage imageNamed:@"CatFilled"]];
    }
    else {
        [self.catButton setImage:[UIImage imageNamed:@"Cat"]];
    }
    numberOfIncidents = [Incidence MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"time >= %@ && time <= %@ && type='Dog'", from, to]];
    if([numberOfIncidents intValue] > 0){
        [self.dogButton setImage:[UIImage imageNamed:@"DogFilled"]];
    }
    else {
        [self.dogButton setImage:[UIImage imageNamed:@"Dog"]];
    }
    numberOfIncidents = [Incidence MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"time >= %@ && time <= %@ && type='Pollen'", from, to]];
    if([numberOfIncidents intValue] > 0){
        [self.pollenButton setImage:[UIImage imageNamed:@"FlowersFilled"]];
    }
    else {
        [self.pollenButton setImage:[UIImage imageNamed:@"Flowers"]];
    }
}

-(void)updateIncidence {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDate *from = [calendar dateBySettingHour:0  minute:0  second:0  ofDate:now options:0];
    NSDate *to   = [calendar dateBySettingHour:23 minute:59 second:59 ofDate:now options:0];

    NSNumber *numberOfIncidents = [Incidence MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"time >= %@ && time <= %@ && type='attack'", from, to]];
    [self.incidenceNumber setTitle:[numberOfIncidents stringValue]  forState:UIControlStateNormal];
}

-(void)tapped:(UIGestureRecognizer*) recogniser {
    if(recogniser.state == UIGestureRecognizerStateEnded){
        [self logIncidence];
    }
}

- (IBAction)segueToIncidenceViewer:(id)sender {
        [self performSegueWithIdentifier:kIncidenceSegue sender:sender];
}

-(void)logIncidence {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.foreground.backgroundColor = [UIColor colorWithRed:170/255 green:170/255 blue:170/255 alpha:0.0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            self.foreground.backgroundColor = [UIColor lightGrayColor];
        } completion:nil];
    }];
    CLLocation *currentLocation = [RRLocationManager currentLocation];
    __block Incidence *incidence;
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        incidence = [Incidence MR_createInContext:localContext];
        incidence.latitude = @(currentLocation.coordinate.latitude);
        incidence.longitude = @(currentLocation.coordinate.longitude);
        incidence.time = [NSDate date];
        incidence.type = @"attack";
    } completion:^(BOOL success, NSError *error) {
        if(success){
            [self updateIncidence];
        }
    }];
}

- (IBAction)actionTaken:(id)sender {
    NSString *incidenceType;
    
    if([sender tag] == 0) {
        incidenceType = @"Medication";
        [sender setImage:[UIImage imageNamed:@"PillFilled"]];
    }
    else if([sender tag] == 1) {
        incidenceType = @"Cat";
        [sender setImage:[UIImage imageNamed:@"CatFilled"]];
    }
    else if([sender tag] == 2) {
        incidenceType = @"Dog";
        [sender setImage:[UIImage imageNamed:@"DogFilled"]];
    }
    else if([sender tag] == 3) {
        incidenceType = @"Pollen";
        [sender setImage:[UIImage imageNamed:@"FlowersFilled"]];
    }
    __block Incidence *incidence;
    CLLocation *currentLocation = [RRLocationManager currentLocation];
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        incidence = [Incidence MR_createInContext:localContext];
        incidence.latitude = @(currentLocation.coordinate.latitude);
        incidence.longitude = @(currentLocation.coordinate.longitude);
        incidence.time = [NSDate date];
        incidence.type = incidenceType;
    } completion:nil];
}

@end
