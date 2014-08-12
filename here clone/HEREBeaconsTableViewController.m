//
//  HEREBeaconsTableViewController.m
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREBeaconsTableViewController.h"

@interface HEREBeaconsTableViewController (){
    NSMutableArray *beacons;
}
@end

@implementation HEREBeaconsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self queryBeacons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [beacons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BeaconCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    PFObject *beacon = beacons[indexPath.row];
    
    cell.textLabel.text = beacon[kHEREBeaconNameKey];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Major: %@, Minor: %@", beacon[kHEREBeaconMajorKey], beacon[kHEREBeaconMinorKey]];
    
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
        PFObject *beacon = beacons[indexPath.row];
        
        [beacon deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                if (succeeded) {
                    NSLog(@"Deleted beacon (name: %@)", beacon[kHEREBeaconNameKey]);
                }
            }
            else {
                NSLog(@"Error when delete beacon, error: %@", error.description);
            }
        }];
        
        [beacons removeObjectAtIndex:indexPath.row];
        [self saveBeaconsLocally];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[HEREAddBeaconViewController class]]) {
        HEREAddBeaconViewController *addBeaconViewController = segue.destinationViewController;
        addBeaconViewController.delegate = self;
    }
}

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender
{
    [self showMenu];
}

#pragma mark - helper methods

- (void)queryBeacons
{
    PFQuery *query = [PFQuery queryWithClassName:@"Beacon"];
    [query whereKey:kHEREBeaconUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Queried successfully; count: %tu", [beacons count]);
            beacons = [objects mutableCopy];
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Error when query beacons in beaconsTableViewController: %@", error.description);
        }
    }];
}

- (NSDictionary *)beaconObjectAsPropertyList:(PFObject *)beacon
{
    NSDictionary *beaconObjectAsPropertyList = @{kHEREBeaconUUIDKey : beacon[kHEREBeaconUUIDKey], kHEREBeaconMajorKey : beacon[kHEREBeaconMajorKey], kHEREBeaconMinorKey : beacon[kHEREBeaconMinorKey], kHEREBeaconNameKey : beacon[kHEREBeaconNameKey]};
    
    return beaconObjectAsPropertyList;
}

- (void)saveBeaconsLocally
{
    NSMutableArray *localBeaconObjectData = [[NSMutableArray alloc] init];
    for (PFObject *beacon in beacons) {
        [localBeaconObjectData addObject:[self beaconObjectAsPropertyList:beacon]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:localBeaconObjectData forKey:kHEREBeaconClassKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - addBeaconTableViewController Delegate

- (void)didAddBeacon
{
    NSLog(@"Did add beacon");
    [self queryBeacons];
    [self saveBeaconsLocally];
}

@end
