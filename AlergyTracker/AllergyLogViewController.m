//
//  ViewController.m
//  AlergyTracker
//
//  Created by Emily Toop on 03/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "AllergyLogViewController.h"

#import "RRLocationManager.h"
#import "Incidence.h"
#import "Interaction+Extras.h"
#import "Symptom+Extras.h"
#import "IncidentCollectionViewCell.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>

#define CELL_SPACING 5

@interface AllergyLogViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *pillButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *catButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dogButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pollenButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *selectedSymptoms;
@property (nonatomic, strong) NSArray *selectedAllergens;

@end

@implementation AllergyLogViewController

static NSString* const kIncidenceSegue = @"IncidentViewSegue";
static NSString* const kCellIdentifier = @"SymptomCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterForeground:)
                                                name: UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    self.selectedAllergens = [Interaction MR_findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"selected=1"]];
    self.selectedSymptoms = [Symptom MR_findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"selected=1"]];
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
    [self updateAllergens];
}

-(void)updateAllergens {
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
    cell.incidenceCountLabel.text = [[Incidence MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"type=%@", selectedSymptom.name]] stringValue];
    
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
    
    Symptom *selectedSymptom = self.selectedSymptoms[indexPath.row];
    [self logIncidenceForSymptom:selectedSymptom];
    
    __weak typeof(collectionView) weakview = collectionView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        typeof(weakview) localview = weakview;
        [localview reloadItemsAtIndexPaths:@[indexPath]];
    });
}

@end
