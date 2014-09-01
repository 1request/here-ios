//
//  HEREHomeViewController.m
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREHomeViewController.h"
#import "HEREAPIHelper.h"
#import "HERECoreDataHelper.h"
#import "Location.h"
#import "HERELocationHelper.h"

@interface HEREHomeViewController () <apiDelegate, NSFetchedResultsControllerDelegate, locationDelegate>

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
@property (strong, nonatomic) HEREAPIHelper *apiHelper;

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
    
    self.managedObjectContext = [HERECoreDataHelper managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:kHERELocationClassKey];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    
    
    NSError *error = nil;
    
    if (error) {
        NSLog(@"Unabled to perform core data fetch at home view controller.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
    self.locationHelper = [[HERELocationHelper alloc] init];
    self.locationHelper.delegate = self;
    
    self.apiHelper = [[HEREAPIHelper alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.apiHelper fetchLocation];
    
    [self.locationHelper stopMonitoringBeacons];
    [self.locationHelper monitorBeacons];
    
    [self fetchLocations];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = sender;
        HEREBeaconsMessagesTableViewController *beaconsMessagesTableVC = segue.destinationViewController;
        beaconsMessagesTableVC.titleText = cell.textLabel.text;
    }
}

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender
{
    [self showMenu];
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"groupCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Location *location = [self.locations objectAtIndex:indexPath.row];
    
    cell.textLabel.text = location.name;
    
    return cell;
}

#pragma mark - helper methods

- (void)fetchLocations
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kHERELocationClassKey];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    
    NSError *error = nil;
    
    NSArray *fetchedLocations = [[HERECoreDataHelper managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    self.locations = [fetchedLocations mutableCopy];
    
    [self.tableView reloadData];
}


#pragma mark - locationHelper delegate

- (void)notifyWhenEntryBeacon:(CLBeaconRegion *)beaconRegion
{
    NSLog(@"Enter region: %@", beaconRegion);
}

- (void)notifyWhenExitBeacon:(CLBeaconRegion *)beaconRegion
{
    NSLog(@"exit region: %@", beaconRegion);
}

- (void)notifyWhenFar:(CLBeacon *)beacon
{
    //    NSLog(@"far from beacon: %@", beacon);
}

- (void)notifyWhenImmediate:(CLBeacon *)beacon
{
    //    NSLog(@"Immediate to beacon: %@", beacon);
}

- (void)notifyWhenNear:(CLBeacon *)beacon
{
    //    NSLog(@"Near beacon: %@", beacon);
}

@end
