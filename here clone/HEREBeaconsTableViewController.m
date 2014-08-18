//
//  HEREBeaconsTableViewController.m
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREBeaconsTableViewController.h"
#import "HEREBeacon.h"
#import "HERELocation.h"
#import "CustomCell.h"

@interface HEREBeaconsTableViewController (){
    NSMutableArray *beacons;
    HEREFactory *factory;
}
@property (strong, nonatomic) HERELocation *location;
@end

@implementation HEREBeaconsTableViewController

- (HERELocation *)location
{
    if (!_location) {
        _location = [[HERELocation alloc] init];
    }
    return _location;
}

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
    static NSString *CellIdentifier = @"BeaconCell";
    
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSMutableArray *rightButtons = [NSMutableArray new];
    
    [rightButtons sw_addUtilityButtonWithColor: [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0] title:@"Rename"];
    [rightButtons sw_addUtilityButtonWithColor: [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] title:@"Delete"];
    
    cell.rightUtilityButtons = rightButtons;
    cell.delegate = self;
    
    // Configure the cell...
    
    HEREBeacon *beacon = beacons[indexPath.row];
    
    cell.titleLabel.text = beacon.name;
    cell.subtitleLabel.text = [NSString stringWithFormat:@"Major: %i, Minor: %i", beacon.major, beacon.minor];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        HEREBeacon *beacon = beacons[indexPath.row];
//        PFObject *beaconObject = [PFObject objectWithoutDataWithClassName:kHEREBeaconClassKey objectId:beacon.parseId];
//        
//        [beaconObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (!error) {
//                if (succeeded) {
//                    NSLog(@"Deleted beacon (name: %@)", beacon.name);
//                    [factory queryBeacons];
//                    [self.location stopMonitoringBeacon:beacon];
//                }
//            }
//            else {
//                NSLog(@"Error when delete beacon, error: %@", error.description);
//            }
//        }];
//        
//        [beacons removeObjectAtIndex:indexPath.row];
//        
//        NSMutableArray *beaconsDict = [[[NSUserDefaults standardUserDefaults] objectForKey:kHEREBeaconClassKey] mutableCopy];
//        [beaconsDict removeObjectAtIndex:indexPath.row];
//        [[NSUserDefaults standardUserDefaults] setObject:beaconsDict forKey:kHEREBeaconClassKey];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//}

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

#pragma mark - SWTableViewCell Delegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (index) {
        case 0:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rename" message:@"Rename this beacon:" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles: @"Rename", nil];
            
            alert.tag = indexPath.row;
            
            alert.delegate = self;
            
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            
            UITextField *textField = [alert textFieldAtIndex:0];
            textField.placeholder = @"New name";
            
            [alert show];
            
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            // Delete button was pressed

            HEREBeacon *beacon = beacons[indexPath.row];
            PFObject *beaconObject = [PFObject objectWithoutDataWithClassName:kHEREBeaconClassKey objectId:beacon.parseId];
            
            [beaconObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    if (succeeded) {
                        NSLog(@"Deleted beacon (name: %@)", beacon.name);
                        [factory queryBeacons];
                        [self.location stopMonitoringBeacon:beacon];
                    }
                }
                else {
                    NSLog(@"Error when delete beacon, error: %@", error.description);
                }
            }];
            
            [beacons removeObjectAtIndex:indexPath.row];
            
            NSMutableArray *beaconsDict = [[[NSUserDefaults standardUserDefaults] objectForKey:kHEREBeaconClassKey] mutableCopy];
            [beaconsDict removeObjectAtIndex:indexPath.row];
            [[NSUserDefaults standardUserDefaults] setObject:beaconsDict forKey:kHEREBeaconClassKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *text = [alertView textFieldAtIndex:0].text;
        NSInteger row = alertView.tag;
        
        NSMutableArray *beaconsDict = [[[NSUserDefaults standardUserDefaults] objectForKey:kHEREBeaconClassKey] mutableCopy];
        
        NSMutableDictionary *beaconDict = [beaconsDict[row] mutableCopy];
        [beaconDict setValue:text forKey:kHEREBeaconNameKey];
        [beaconsDict setObject:beaconDict atIndexedSubscript:alertView.tag];
        [[NSUserDefaults standardUserDefaults] setObject:beaconsDict forKey:kHEREBeaconClassKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        HEREBeacon *beacon = beacons[row];
        PFObject *beaconObject = [PFObject objectWithoutDataWithClassName:kHEREBeaconClassKey objectId:beacon.parseId];
        
        beaconObject[kHEREBeaconNameKey] = text;
        [beaconObject saveInBackground];
        beacons = [factory returnBeacons];
        [self.tableView reloadData];
    }
}

@end
