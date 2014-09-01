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
#import "HERELocation.h"

@interface HEREHomeViewController () <apiDelegate, NSFetchedResultsControllerDelegate>

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
@property (strong, nonatomic) HERELocation *locationHelper;

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
    
    self.locationHelper = [[HERELocation alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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

@end
