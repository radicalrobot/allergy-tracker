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
#import "UIView+FrameAccessors.h"

#import <MagicalRecord/MagicalRecord.h>
#import <Analytics.h>
#import "MagicalRecord+BackgroundTask.h"

@interface SettingsTableViewController () {
    BOOL isFirstRun;
    NSInteger maxNumberOfSelectedAllergens;
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
    
    [self updateOptions];
    
    self.navigationItem.title = isFirstRun ? @"Setup" : @"Settings";
    
    if(isFirstRun) {
        self.closeButton.enabled = NO;
    }
    
    self.choices = [[UISegmentedControl alloc] initWithItems:@[@"Symptoms", @"Allergens"]];
    [self.choices setSelectedSegmentIndex:0];
    [self.choices addTarget:self action:@selector(selectedSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.tableHeaderView = self.choices;
    
    maxNumberOfSelectedAllergens = floor((self.view.width - 44) / 44);
    
    [[SEGAnalytics sharedAnalytics] screen:@"Settings"
                                properties:nil];
}

-(void)updateOptions {
    NSArray *symptoms = [Symptom MR_findAllSortedBy:@"name" ascending:YES];
    
     NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    self.symptoms = [symptoms sortedArrayUsingDescriptors:@[sort]];
    
    self.allergens = [Interaction MR_findAllSortedBy:@"name" ascending:YES];
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

- (IBAction)addCustomSetting:(id)sender {
    NSLog(@"adding a custom setting");
    
    NSString *type = self.choices.selectedSegmentIndex == 0 ? @"Symptom" : @"Allergen";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Add a new %@", type ]
                                                                   message: [NSString stringWithFormat:@"Enter the name of the %@ you would like to add", type]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = type;
         [textField addTarget:self
                       action:@selector(alertTextFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style: UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *settingName = alert.textFields.firstObject;
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            switch(self.choices.selectedSegmentIndex) {
                case 0: {
                    Symptom *newSymptom = [Symptom MR_createEntityInContext: localContext];
                    newSymptom.name = settingName.text;
                    break;
                }
                case 1: {
                    Interaction *newAllergen = [Interaction MR_createEntityInContext:localContext];
                    newAllergen.name = settingName.text;
                }
                    break;
                default:
                    break;
            }
        } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
            if(!contextDidSave){
                NSLog(@"Unable to save new %@: %@", type, error);
            }
            
            [self updateOptions];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }];
    createAction.enabled = NO;
    [alert addAction:cancelAction];
    [alert addAction:createAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertTextFieldDidChange:(UITextField *)sender
{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController)
    {
        UITextField *settingName = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = settingName.text.length > 1;
    }
}

- (IBAction)settingChanged:(id)sender {
    UISwitch *switchView = sender;
    SettingTableViewCell *settingCell = (SettingTableViewCell*)[[switchView superview] superview];
    NSIndexPath *cellIndex = [self.tableView indexPathForCell:settingCell];
    
    [MagicalRecord saveOnBackgroundThreadWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        switch (self.choices.selectedSegmentIndex) {
            case 0:
            {
                Symptom *symptom = [self.symptoms[cellIndex.row] MR_inContext:localContext];
                symptom.selected = @(switchView.on);
                [[SEGAnalytics sharedAnalytics] track:@"Updated Symptoms"
                                           properties:@{ @"name": symptom.name,
                                                         @"on": symptom.selected }];
                break;
            }
            case 1:{
                Interaction *allergen = [self.allergens[cellIndex.row] MR_inContext:localContext];
                if(switchView.on){
                    NSInteger numberOfSelectedAllergens = [self.allergens filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected=YES"]].count;
                    if(numberOfSelectedAllergens >= maxNumberOfSelectedAllergens){
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Max number of allergens reached"
                                                                                       message:@"You may ony track up to %ld allergens at a time"
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK"
                                                                               style: UIAlertActionStyleCancel
                                                                             handler:nil];
                        [alert addAction:cancelAction];
                        [self presentViewController:alert animated:YES completion:nil];
                        switchView.on = NO;
                    }
                }
                allergen.selected = @(switchView.on);
                [[SEGAnalytics sharedAnalytics] track:@"Updated Allergens"
                                           properties:@{ @"name": allergen.name,
                                                         @"on": allergen.selected }];
                break;
            }
            default:
                break;
        }
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
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
            cell.settingNameLabel.text = [symptom.displayName capitalizedStringWithLocale:[NSLocale currentLocale]];
            cell.settingSwitch.on = [symptom.selected boolValue];
            break;
        }
        case 1:{
            Interaction *allergen = self.allergens[indexPath.row];
            cell.settingNameLabel.text = allergen.displayName;
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
            return @"Select up to 5 allergens to track";
        default:
            break;
    }
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
@end