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

#import <MagicalRecord/CoreData+MagicalRecord.h>

@interface SettingsTableViewController ()

@property (nonatomic, strong) NSArray *symptoms;
@property (nonatomic, strong) NSArray *allergens;

@end

@implementation SettingsTableViewController

static NSString * const CellIdentifier = @"SettingsCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.symptoms = [Symptom MR_findAllSortedBy:@"name" ascending:YES];
    
    self.allergens = [Interaction MR_findAllSortedBy:@"name" ascending:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
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
    switch (indexPath.section) {
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
    
    switch (section) {
        case 0:
            return @"Symptoms";
        case 1:
            return @"Allergens";
        default:
            break;
    }
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)settingChanged:(id)sender {
    UISwitch *switchView = sender;
    SettingTableViewCell *settingCell = (SettingTableViewCell*)[[switchView superview] superview];
    NSIndexPath *cellIndex = [self.tableView indexPathForCell:settingCell];
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        
        switch (cellIndex.section) {
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
    } completion:nil];
    
}
@end
