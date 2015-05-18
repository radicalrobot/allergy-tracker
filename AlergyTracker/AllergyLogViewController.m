//
//  ViewController.m
//  AlergyTracker
//
//  Created by Emily Toop on 03/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "AllergyLogViewController.h"

#import "RRLocationManager.h"
#import "Incidence+Extras.h"
#import "Interaction+Extras.h"
#import "Symptom+Extras.h"
#import "IncidentCollectionViewCell.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <AudioToolbox/AudioServices.h>

#define CELL_SPACING 5
#define MEDICATION_TAG 200

@interface AllergyLogViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIToolbar *allergenToolbar;

@property (nonatomic, strong) NSArray *selectedSymptoms;
@property (nonatomic, strong) NSArray *selectedAllergens;

@end

@implementation AllergyLogViewController {
    NSDate *_dayStart;
    NSDate *_dayEnd;
}

static NSString* const kIncidenceSegue = @"IncidentViewSegue";
static NSString* const kCellIdentifier = @"SymptomCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterForeground:)
                                                name: UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateViewStatus];
}

-(void)applicationDidEnterForeground:(NSNotification*)notification {
    [self updateViewStatus];
}

-(void)updateViewStatus {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    _dayStart = [calendar dateBySettingHour:0  minute:0  second:0  ofDate:now options:0];
    _dayEnd   = [calendar dateBySettingHour:23 minute:59 second:59 ofDate:now options:0];
    [self updateAllergens];
    [self updateSymptoms];
}

-(void)updateSymptoms {
    self.selectedSymptoms = [Symptom MR_findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"selected=1"]];
    [self.collectionView reloadData];
}

-(void)setupAllergens {
    self.selectedAllergens = [Interaction MR_findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"selected=1"]];
    UIBarButtonItem *medication = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Pill"] style:UIBarButtonItemStylePlain target:self action:@selector(actionTaken:)];
    medication.tag = MEDICATION_TAG;
    NSMutableArray *items = [NSMutableArray arrayWithObject:medication];
    UIBarButtonItem *allergen;
    for(int idx = 0; idx < [self.selectedAllergens count]; ++idx) {
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        Interaction *interaction = self.selectedAllergens[idx];
        allergen = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:interaction.name] style:UIBarButtonItemStylePlain target:self action:@selector(actionTaken:)];
        allergen.tag = idx;
        [items addObject:allergen];
    }
    self.allergenToolbar.items = items;
}

-(void)updateAllergens {
    [self setupAllergens];
    for(UIBarButtonItem *button in self.allergenToolbar.items) {
        if(button.style == UIBarButtonItemStylePlain){
            [self updateAllergen:button];
        }
    }
}

-(void)updateAllergen:(id)sender {
    UIBarButtonItem *button = sender;
    if(button.tag == MEDICATION_TAG) {
        NSNumber *numberOfIncidents = [Incidence MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"time >= %@ && time <= %@ && type=[c]'Medication'", _dayStart, _dayEnd]];
        if([numberOfIncidents intValue] > 0){
            [button setImage:[UIImage imageNamed:@"PillFilled"]];
        }
        else {
            [button setImage:[UIImage imageNamed:@"Pill"]];
        }
    }
    else {
        Interaction *allergen = self.selectedAllergens[button.tag];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"time >= %@ && time <= %@ && type=[c]%@", _dayStart, _dayEnd, allergen.name];
        NSNumber *numberOfIncidents = [Incidence MR_numberOfEntitiesWithPredicate:predicate];
        if([numberOfIncidents intValue] > 0){
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@Filled", allergen.name]]];
        }
        else {
            [button setImage:[UIImage imageNamed:allergen.name]];
        }
    }
}

- (IBAction)segueToIncidenceViewer:(id)sender {
        [self performSegueWithIdentifier:kIncidenceSegue sender:sender];
}

-(void)logIncidenceForSymptom:(Symptom*)symptom {
    CLLocation *currentLocation = [RRLocationManager currentLocation];
    __block Incidence *incidence;
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        incidence = [Incidence MR_createInContext:localContext];
        incidence.latitude = @(currentLocation.coordinate.latitude);
        incidence.longitude = @(currentLocation.coordinate.longitude);
        incidence.time = [NSDate date];
        incidence.type = symptom.name;
    } completion:nil];
}

- (IBAction)actionTaken:(id)sender {
    NSString *incidenceType;
    
    if([sender tag] == MEDICATION_TAG) {
        incidenceType = @"Medication";
    }
    else {
        Interaction *allergen = self.selectedAllergens[[sender tag]];
        incidenceType = allergen.name;
    }
    __weak typeof(self) weakself = self;
    CLLocation *currentLocation = [RRLocationManager currentLocation];
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        Incidence *incidence = [Incidence MR_createInContext:localContext];
        incidence.latitude = @(currentLocation.coordinate.latitude);
        incidence.longitude = @(currentLocation.coordinate.longitude);
        incidence.time = [NSDate date];
        incidence.type = incidenceType;
    } completion:^(BOOL success, NSError *error) {
        typeof(weakself) localself = weakself;
        [localself updateAllergen:sender];
    }];
    
}

#pragma mark - UICollectionView methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.selectedSymptoms count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Symptom *selectedSymptom = self.selectedSymptoms[indexPath.row];
    IncidentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.symptomNameLabel.text = selectedSymptom.name;
    cell.incidenceCountLabel.text = [[Incidence MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"time >= %@ && time <= %@ && type=[c]%@", _dayStart, _dayEnd, selectedSymptom.name]] stringValue];
    
    return cell;
}

CGSize cellSize;

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(cellSize.width == CGSizeZero.width && cellSize.height == CGSizeZero.height) {
        CGFloat width = (collectionView.frame.size.width - (3 * CELL_SPACING)) / 2;
        NSInteger spaces = [self.selectedSymptoms count] * CELL_SPACING;
        CGFloat height = (collectionView.frame.size.height - spaces) / ([self.selectedSymptoms count] / 2);
        
        cellSize = CGSizeMake(width, height);
    }
    return cellSize;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return CELL_SPACING;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    IncidentCollectionViewCell *cell = (IncidentCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [cell flash];
    BOOL enabledSounds = CFPreferencesGetAppBooleanValue(
                                                         CFSTR("keyboard"),
                                                         CFSTR("/var/mobile/Library/Preferences/com.apple.preferences.sounds"),
                                                         NULL);
    NSLog(@"sounds %@", enabledSounds? @"enabled" : @"disabled");
    if(enabledSounds){
        
        AudioServicesPlaySystemSound( 1104 );
    }
    
    Symptom *selectedSymptom = self.selectedSymptoms[indexPath.row];
    [self logIncidenceForSymptom:selectedSymptom];
    
    __weak typeof(collectionView) weakview = collectionView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        typeof(weakview) localview = weakview;
        [localview reloadItemsAtIndexPaths:@[indexPath]];
    });
}

@end
