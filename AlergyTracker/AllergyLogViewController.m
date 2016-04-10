//
//  ViewController.m
//  AlergyTracker
//
//  Created by Emily Toop on 03/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "AllergyLogViewController.h"

#import "RRLocationManager.h"
#import "DataManager.h"
#import "Incidence+Extras.h"
#import "Interaction+Extras.h"
#import "Symptom+Extras.h"
#import "IncidentCollectionViewCell.h"
#import "ScrollableToolbarView.h"
#import "QuickActions.h"

#import "UIView+FrameAccessors.h"
#import "UIColor+Utilities.h"
#import "MagicalRecord+BackgroundTask.h"

#import <MagicalRecord/MagicalRecord.h>
#import "UIButton+Badge.h"

#import <AudioToolbox/AudioServices.h>
#import <Analytics.h>

#define CELL_SPACING 5
#define MINIMUM_CELL_HEIGHT 100
#define MEDICATION_TAG 200

@interface AllergyLogViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    CGSize cellSize;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet ScrollableToolbarView *allergenToolbarView;

@property (nonatomic, strong) NSArray *selectedSymptoms;
@property (nonatomic, strong) NSArray *selectedAllergens;

@end

@implementation AllergyLogViewController {
    NSDate *_dayStart;
    NSDate *_dayEnd;
}

static NSString* const kIncidenceSegue = @"IncidentViewSegue";
static NSString* const kSettingsSegue = @"SettingsViewSegue";
static NSString* const kCellIdentifier = @"SymptomCell";
static UIColor* badgeColor;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    badgeColor = [UIColor rr_foregroundColor];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewStatus) name:@"NewIncidenceCreated" object:nil];
    [self updateViewStatus];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewIncidenceCreated" object:nil];
}

-(void)applicationDidEnterForeground:(NSNotification*)notification {
    [self updateViewStatus];
}

-(void)updateViewStatus {
    [[SEGAnalytics sharedAnalytics] screen:@"Allergy Log"
                                properties:nil];
    if([DataManager isFirstRun]){
        [self performSegueWithIdentifier:kSettingsSegue sender:self];
    }
    cellSize = CGSizeZero;
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

-(UIButton*)toolbarButtonWithImageNamed:(NSString*)imageName tag:(NSInteger)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(actionTaken:) forControlEvents:UIControlEventTouchUpInside];
    button.size = (CGSize){40, 44};
    button.tag = tag;
    button.shouldHideBadgeAtZero = YES;
    
    return button;
}

-(void)setupAllergens {
    self.selectedAllergens = [Interaction MR_findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"selected=1"]];
    UIButton *medication = [self toolbarButtonWithImageNamed:@"Pill" tag:MEDICATION_TAG];
    NSMutableArray *items = [NSMutableArray arrayWithObject:medication];
    UIButton *allergen;
    for(int idx = 0; idx < [self.selectedAllergens count]; ++idx) {
        Interaction *interaction = self.selectedAllergens[idx];
        allergen = [self toolbarButtonWithImageNamed:interaction.name tag:idx];
        [items addObject:allergen];
    }
    self.allergenToolbarView.items = items;
}

-(void)updateAllergens {
    [self setupAllergens];
    for(UIButton *button in self.allergenToolbarView.items) {
        [self updateAllergen:button];
    }
}

-(void)updateAllergen:(id)sender {
    UIButton *button = sender;
    NSInteger numberOfIncidentsOfInteraction;
    if(button.tag == MEDICATION_TAG) {
        numberOfIncidentsOfInteraction = [DataManager numberOfIncidentsWithName:@"Medication" betweenDate:_dayStart endDate:_dayEnd];
        button.badgeValue = [NSString stringWithFormat:@"%ld", (long)numberOfIncidentsOfInteraction];
        if(numberOfIncidentsOfInteraction > 0){
            [button setImage:[UIImage imageNamed:@"PillFilled"] forState:UIControlStateNormal];
        }
        else {
            [button setImage:[UIImage imageNamed:@"Pill"] forState:UIControlStateNormal];
        }
    }
    else {
        Interaction *allergen = self.selectedAllergens[button.tag];
        numberOfIncidentsOfInteraction = [DataManager numberOfIncidentsWithName:allergen.name betweenDate:_dayStart endDate:_dayEnd];
        
        button.badgeValue = [NSString stringWithFormat:@"%ld", (long)numberOfIncidentsOfInteraction];
        if(numberOfIncidentsOfInteraction > 0){
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@Filled", allergen.name]] forState:UIControlStateNormal];
        }
        else {
            button.badgeValue = @"0";
            [button setImage:[UIImage imageNamed:allergen.name] forState:UIControlStateNormal];
        }
    }
    button.badgeOriginX = 25;
    button.badgeOriginY = 20;
    button.badgeBGColor = badgeColor;
}

- (IBAction)segueToIncidenceViewer:(id)sender {
        [self performSegueWithIdentifier:kIncidenceSegue sender:sender];
}

-(void)logIncidenceForSymptom:(Symptom*)symptom {
    CLLocation *currentLocation = [RRLocationManager currentLocation];
    NSDate *now = [NSDate date];
    NSNumber *latitude = @(currentLocation.coordinate.latitude);
    NSNumber *longitude = @(currentLocation.coordinate.latitude);
    [self createIncident:now latitude:latitude longitude:longitude type:symptom.displayName onSuccess:nil];
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
    NSDate *now = [NSDate date];
    
    NSNumber *latitude = @(currentLocation.coordinate.latitude);
    NSNumber *longitude = @(currentLocation.coordinate.latitude);
    [self createIncident:now latitude:latitude longitude:longitude type:incidenceType onSuccess:^{
        typeof(weakself) localself = weakself;
        [localself updateAllergen:sender];
    }];
}

-(void) createIncident: (NSDate*) now latitude:(NSNumber*) latitude longitude:(NSNumber*) longitude type:(NSString*) incidenceType onSuccess:(void (^)())successBlock {
    [MagicalRecord saveOnBackgroundThreadWithBlock:^(NSManagedObjectContext *localContext) {
        Incidence *incidence = [Incidence MR_createEntityInContext:localContext];
        incidence.latitude = latitude;
        incidence.longitude = longitude;
        incidence.time = now;
        incidence.type = incidenceType;
    } completion:^(BOOL success, NSError *error) {
        if(success) {
            if(successBlock) {
                successBlock();
            }
            Incidence *newlyCreatedIncidence = [Incidence MR_findFirstByAttribute:@"time" withValue:now];
            
            NSArray *top2Incidents = [Incidence getTopIncidentsWithLimit:2];
            [QuickActions addTopIncidents: top2Incidents];
            
            [[SEGAnalytics sharedAnalytics] track:@"Logged Incident"
                                       properties:@{ @"id": newlyCreatedIncidence.uuid,
                                                     @"name": newlyCreatedIncidence.type,
                                                     @"time": newlyCreatedIncidence.formattedTime,
                                                     @"latitude": newlyCreatedIncidence.latitude,
                                                     @"longitude": newlyCreatedIncidence.longitude,
                                                     @"notes": newlyCreatedIncidence.notes ? newlyCreatedIncidence.notes : [NSNull null],
                                                    @"writeSuccess": @(success)}];
        } else {
            [[SEGAnalytics sharedAnalytics] track:@"Logged Incident"
                                       properties:@{ @"id": [NSNull null],
                                                     @"name": incidenceType,
                                                     @"time": now,
                                                     @"latitude": latitude,
                                                     @"longitude": longitude,
                                                     @"notes": [NSNull null],
                                                     @"writeSuccess": @(success)}];
        }
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
    cell.symptomNameLabel.text = selectedSymptom.displayName;
    cell.incidenceCountLabel.text = [[Incidence MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"time >= %@ && time <= %@ && type=[c]%@", _dayStart, _dayEnd, selectedSymptom.name]] stringValue];
    
    return cell;
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(cellSize.width == CGSizeZero.width && cellSize.height == CGSizeZero.height) {
        CGFloat collectionViewHeight = self.collectionView.bounds.size.height - (self.navigationController.navigationBar.bounds.size.height + (2 * CELL_SPACING));
        if(self.selectedSymptoms.count == 1) {
            cellSize = CGSizeMake(self.collectionView.width - (2 * CELL_SPACING), collectionViewHeight - CELL_SPACING);
        }
        else {
            CGFloat width = ((collectionView.width - CELL_SPACING) / 2) - CELL_SPACING;
            NSInteger spaces = [self.selectedSymptoms count] * CELL_SPACING;
            NSInteger numberOfRows = ceilf(self.selectedSymptoms.count / 2.0);
            CGFloat height = MAX(MINIMUM_CELL_HEIGHT, (collectionViewHeight - spaces) / numberOfRows);
            
            cellSize = CGSizeMake(width, height);
        }
    }
    return cellSize;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return CELL_SPACING;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return CELL_SPACING;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    IncidentCollectionViewCell *cell = (IncidentCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [cell flash];
    cell.incidenceCountLabel.text = [NSString stringWithFormat:@"%d", [cell.incidenceCountLabel.text intValue] + 1];

    Symptom *selectedSymptom = self.selectedSymptoms[indexPath.row];
    [self logIncidenceForSymptom:selectedSymptom];
    
}

@end
