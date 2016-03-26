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

#import <MagicalRecord/MagicalRecord.h>
#import <Analytics.h>

#import "MagicalRecord+BackgroundTask.h"

@interface IncidenceTableViewController ()

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, weak) IBOutlet SummaryHeaderView *summaryView;

@end

@implementation IncidenceTableViewController

static NSString * const kSegueIdentifier = @"EditIncidenceSegue";
static NSString * const kCellIdentifier = @"IncidenceCell";

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(!_currentDate){
        _currentDate = [NSDate date];
    }
    
    NSArray *selectedSymptoms = [Symptom MR_findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"selected=1"]];
    NSArray *selectedInteractions = [Interaction MR_findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"selected=1"]];
    _summaryView.interactions = selectedInteractions;
    _summaryView.symptoms = selectedSymptoms;
    _summaryView.date = _currentDate;
    _summaryView.maxRowHeight = 60;
    _summaryView.maxNumberOfCellsInRow = 4;
    _summaryView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 60);
    
    [self eventsForTheDay:_currentDate];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"EEE, MMM dd, YYYY";
    self.navigationItem.title = [formatter stringFromDate:_currentDate];
    
    [[SEGAnalytics sharedAnalytics] track:@"View Incidences"
                               properties:@{ @"date": self.navigationItem.title }];
    
    [self.tableView reloadData];
}

-(void)eventsForTheDay:(NSDate*) date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *from = [calendar dateBySettingHour:0  minute:0  second:0  ofDate:date options:0];
    NSDate *to   = [calendar dateBySettingHour:23 minute:59 second:59 ofDate:date options:0];
    self.events = [Incidence MR_findAllSortedBy:@"time" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"time >= %@ && time <= %@", from, to]];
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
        // Delete the row from the data source
        __block NSString *uuid, *name, *time, *notes;
        __block NSNumber *lat, *lon;
        Incidence *incidence = self.events[indexPath.row];
        uuid = incidence.uuid;
        name = incidence.type;
        time = incidence.formattedTime;
        notes = incidence.notes;
        lat = incidence.latitude;
        lon = incidence.longitude;
        [MagicalRecord saveOnBackgroundThreadWithBlock:^(NSManagedObjectContext *localContext) {
            Incidence *localIncidence = [incidence MR_inContext:localContext];
            [localIncidence MR_deleteEntityInContext:localContext];
        } completion:^(BOOL success, NSError *error) {
            if(success){
                [self eventsForTheDay:_currentDate];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            [[SEGAnalytics sharedAnalytics] track:@"Delete Incidence"
                                       properties:@{ @"id": uuid,
                                                     @"name": name,
                                                     @"time": time,
                                                     @"latitude": lat,
                                                     @"longitude": lon,
                                                     @"notes": notes ? notes : [NSNull null],
                                                     @"writeSuccess": @(success)}];
        }];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

@end
