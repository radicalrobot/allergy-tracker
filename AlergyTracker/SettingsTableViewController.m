//
//  SettingsTableViewController.m
//  AlergyTracker
//
//  Created by Emily Toop on 11/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "Symptom+Extras.h"
#import "Interaction+Extras.h"
#import "SettingTableViewCell.h"
#import "DataManager.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>

@interface SettingsTableViewController () {
    BOOL isFirstRun;
}

@property (nonatomic, strong) NSArray *symptoms;
@property (nonatomic, strong) NSArray *allergens;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;

@property (nonatomic, strong) UISegmentedControl *choices;

@end

@implementation SettingsTableViewController

static NSString * const CellIdentifier = @"SettingsCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isFirstRun = [DataManager isFirstRun];
    
    self.symptoms = [Symptom MR_findAllSortedBy:@"name" ascending:YES];
    
    self.allergens = [Interaction MR_findAllSortedBy:@"name" ascending:YES];
    
    self.navigationItem.title = isFirstRun ? @"Setup" : @"Settings";
    
    if(isFirstRun) {
        self.closeButton.enabled = NO;
    }
    
    self.choices = [[UISegmentedControl alloc] initWithItems:@[@"Symptoms", @"Allergens"]];
    [self.choices setSelectedSegmentIndex:0];
    [self.choices addTarget:self action:@selector(selectedSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.tableHeaderView = self.choices;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)selectedSegmentChanged:(id)sender {
    [self.tableView reloadData];
}


- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)settingChanged:(id)sender {
    UISwitch *switchView = sender;
    SettingTableViewCell *settingCell = (SettingTableViewCell*)[[switchView superview] superview];
    NSIndexPath *cellIndex = [self.tableView indexPathForCell:settingCell];
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        
        switch (self.choices.selectedSegmentIndex) {
            case 0:
            {
                Symptom *symptom = [self.symptoms[cellIndex.row] MR_inContext:localContext];
                symptom.selected = @(switchView.on);
                break;
            }
            case 1:{
                Interaction *allergen = [self.allergens[cellIndex.row] MR_inContext:localContext];
                allergen.selected = @(switchView.on);
                break;
            }
            default:
                break;
        }
    } completion:^(BOOL success, NSError *error) {
        if([DataManager numberOfSelectedSymptoms] > 0){
            self.closeButton.enabled = YES;
        }
        else {
            self.closeButton.enabled = NO;
        }
    }];
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (self.choices.selectedSegmentIndex) {
        case 0:
            return [self.symptoms count];
        case 1:
            return [self.allergens count];
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    switch (self.choices.selectedSegmentIndex) {
        case 0:
        {
            Symptom *symptom = self.symptoms[indexPath.row];
            cell.settingNameLabel.text = symptom.name;
            cell.settingSwitch.on = [symptom.selected boolValue];
            break;
        }
        case 1:{
            Interaction *allergen = self.allergens[indexPath.row];
            cell.settingNameLabel.text = allergen.name;
            cell.settingSwitch.on = [allergen.selected boolValue];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (self.choices.selectedSegmentIndex) {
        case 0:
            return @"Select symptoms to track";
        case 1:
            return @"Select allergens to track";
        default:
            break;
    }
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
@end