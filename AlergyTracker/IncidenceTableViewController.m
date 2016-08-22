//
//  IncidenceTableViewController.m
//  AlergyTracker
//
//  Created by Emily Toop on 04/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import "IncidenceTableViewController.h"

#import "Incidence+Extras.h"
#import "RRLocationManager.h"
#import "EditIncidenceViewController.h"
#import "NSDate+Utilities.h"
#import "SummaryHeaderView.h"
#import "Symptom+Extras.h"
#import "Interaction+Extras.h"
#import "QuickActions.h"
#import "RRDataManager.h"

#import <Analytics.h>

@interface IncidenceTableViewController ()

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, weak) IBOutlet SummaryHeaderView *summaryView;

@end

@implementation IncidenceTableViewController

static NSString * const kSegueIdentifier = @"EditIncidenceSegue";
static NSString * const kCellIdentifier = @"IncidenceCell";

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:@"NewIncidenceCreated" object:nil];
    
    if(!_currentDate){
        _currentDate = [NSDate date];
    }
    
    NSArray *selectedSymptoms = [[RRDataManager currentDataManager] selectedSymptoms];
    NSArray *selectedInteractions = [[RRDataManager currentDataManager] selectedInteractions];
    _summaryView.interactions = selectedInteractions;
    _summaryView.symptoms = selectedSymptoms;
    _summaryView.date = _currentDate;
    _summaryView.maxRowHeight = 60;
    _summaryView.maxNumberOfCellsInRow = 4;
    _summaryView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 60);
    
    self.events = [[RRDataManager currentDataManager] eventsForTheDay:_currentDate];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"EEE, MMM dd, YYYY";
    self.navigationItem.title = [formatter stringFromDate:_currentDate];
    
    [[SEGAnalytics sharedAnalytics] track:@"View Incidences"
                               properties:@{ @"date": self.navigationItem.title }];
    
    [self reload];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewIncidenceCreated" object:nil];
}

-(void)reload {
    NSArray *selectedSymptoms = [[RRDataManager currentDataManager] selectedSymptoms];
    NSArray *selectedInteractions = [[RRDataManager currentDataManager] selectedInteractions];
    _summaryView.interactions = selectedInteractions;
    _summaryView.symptoms = selectedSymptoms;
    [_summaryView setNeedsLayout];
    
    [self.tableView reloadData];
}

-(NSDateFormatter *)dateFormatter {
    if(!_dateFormatter){
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.dateFormat = @"HH:mm:ss";
    }
    
    return _dateFormatter;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.events.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    Incidence *incidence = self.events[indexPath.row];
    // Configure the cell...
    cell.textLabel.text = incidence.type;
    if([incidence.type isEqualToString:@"location"]){
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[incidence.latitude doubleValue] longitude:[incidence.longitude doubleValue]];
        __weak typeof(cell) weakcell = cell;
        [RRLocationManager locationStringForLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            typeof(weakcell) localcell = weakcell;
            CLPlacemark *placemark = [placemarks lastObject];
            localcell.textLabel.text = [placemark.addressDictionary[@"FormattedAddressLines"]
                                        componentsJoinedByString:@", "];
        }];
    }
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:incidence.time];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Incidence *incidence = self.events[indexPath.row];
    [self.parentController performSegueWithIdentifier:kSegueIdentifier sender:incidence];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __weak typeof(self) weakself = self;
        [[RRDataManager currentDataManager] deleteIncidence:self.events[indexPath.row] onSuccess:^{
            typeof(weakself) strongself = weakself;
            strongself.events = [[RRDataManager currentDataManager] eventsForTheDay:_currentDate];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            NSArray *top2Incidents = [Incidence getTopIncidentsWithLimit:2];
            [QuickActions addTopIncidents: top2Incidents];
            
            [strongself reload];
        }];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

@end
