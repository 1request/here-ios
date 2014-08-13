//
//  HEREBeaconsTableViewController.m
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREBeaconsTableViewController.h"
#import "HEREBeacon.h"

@interface HEREBeaconsTableViewController (){
    NSMutableArray *beacons;
    HEREFactory *factory;
}
@end

@implementation HEREBeaconsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    factory = [[HEREFactory alloc] init];
    factory.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [factory queryBeacons];
    beacons = [factory returnBeacons];
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
    
    HEREBeacon *beacon = beacons[indexPath.row];
    
    cell.textLabel.text = beacon.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Major: %i, Minor: %i", beacon.major, beacon.minor];
    
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
        HEREBeacon *beacon = beacons[indexPath.row];
        PFObject *beaconObject = [PFObject objectWithoutDataWithClassName:kHEREBeaconClassKey objectId:beacon.parseId];
        
        [beaconObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                if (succeeded) {
                    NSLog(@"Deleted beacon (name: %@)", beacon.name);
                    [factory queryBeacons];
                }
            }
            else {
                NSLog(@"Error when delete beacon, error: %@", error.description);
            }
        }];
        
        [beacons removeObjectAtIndex:indexPath.row];
        
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

#pragma mark - addBeaconTableViewController Delegate

- (void)didAddBeacon
{
    NSLog(@"Did add beacon");
    [factory queryBeacons];
}

#pragma mark - factory delegate
- (void)didFinishQueryingBeaconsFromParse
{
    NSLog(@"did finish querying beacons from parse");
    beacons = [factory returnBeacons];
    [self.tableView reloadData];
}

@end
