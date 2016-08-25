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
#import "LocalDataManager.h"
#import "UIView+FrameAccessors.h"
#import "RRDataManager.h"

#import <Analytics.h>

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
    isFirstRun = [[RRDataManager currentDataManager] isFirstRun];
    
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
    self.symptoms = [Symptom alphabetisedSymptomsSelected:NO];
    self.allergens = [[RRDataManager currentDataManager] allInteractions];
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
        void (^successBlock)() = ^{
            [self.tableView reloadData];
        };
        switch(self.choices.selectedSegmentIndex) {
            case 0:
                [[RRDataManager currentDataManager] createSymptom:settingName.text onSuccess:successBlock];
                break;
            case 1:
                [[RRDataManager currentDataManager] createInteraction:settingName.text onSuccess:successBlock];
                break;
            default:
                break;
        }
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
    void (^successBlock)() = ^{
        if([[RRDataManager currentDataManager] numberOfSelectedSymptoms] > 0){
            self.closeButton.enabled = YES;
        }
        else {
            self.closeButton.enabled = NO;
        }
    };
    
    switch (self.choices.selectedSegmentIndex) {
        case 0:
        {
            [[RRDataManager currentDataManager] updateSymptomSelection:self.symptoms[cellIndex.row] isSelected:@(switchView.on) onSuccess:successBlock];
            break;
        }
        case 1:{
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
                    break;
                }
            }
            [[RRDataManager currentDataManager] updateInteractionSelection:self.allergens[cellIndex.row] isSelected:@(switchView.on) onSuccess:successBlock];
            break;
        }
        default:
            break;
    }
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