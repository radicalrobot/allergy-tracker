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

#import <MagicalRecord/CoreData+MagicalRecord.h>

@interface IncidenceTableViewController ()

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDate *currentDate;

@end

@implementation IncidenceTableViewController

static NSString * const kSegueIdentifier = @"EditIncidenceSegue";
static NSString * const kCellIdentifier = @"IncidenceCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    [self eventsForTheDay:_currentDate];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"EEE, MMM dd, YYYY";
    self.navigationItem.title = [formatter stringFromDate:_currentDate];
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
- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            
            Incidence *incidence = self.events[indexPath.row];
            [incidence MR_deleteEntity];
        } completion:^(BOOL success, NSError *error) {
            [self eventsForTheDay:_currentDate];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:kSegueIdentifier]) {
        Incidence *selectedIncidence = self.events[[self.tableView indexPathForSelectedRow].row];
        EditIncidenceViewController *eivc = (EditIncidenceViewController*)segue.destinationViewController;
        eivc.incidence = selectedIncidence;
    }
}


@end
