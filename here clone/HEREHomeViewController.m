//
//  HEREHomeViewController.m
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREHomeViewController.h"
#import "Location.h"
#import "HERELocationHelper.h"

@interface HEREHomeViewController () <NSFetchedResultsControllerDelegate, locationDelegate>

{
    NSTimer *timer;
    NSTimeInterval timeInterval;
}

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) HEREBeacon *beacon;
@property (strong, nonatomic) NSMutableArray *audioRecords;
@property (strong, nonatomic) NSMutableArray *beacons;
@property (strong, nonatomic) NSData *audioData;
@property (strong, nonatomic) NSMutableArray *locations;
@property (strong, nonatomic) HERELocationHelper *locationHelper;

@end

@implementation HEREHomeViewController

#pragma mark - instantiation

- (NSMutableArray *)locations
{
    if (!_locations) _locations = [[NSMutableArray alloc] init];
    return _locations;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self.navigationController setNavigationBarHidden:NO];
        
    self.locationHelper = [[HERELocationHelper alloc] init];
    self.locationHelper.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.locationHelper stopMonitoringBeacons];
    [self.locationHelper monitorBeacons];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = sender;
        HEREBeaconsMessagesTableViewController *beaconsMessagesTableVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        beaconsMessagesTableVC.location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kHERELocationClassKey];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:kHEREAPILocationNameKey
                                                              ascending:YES
                                                               ]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender
{
    [self showMenu];
}

#pragma mark - UITableView Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"groupCell"];
    
    Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = location.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)[location.messages count]];
    
    return cell;
}

@end
