//
//  HEREBeaconsMessagesTableViewController.m
//  here clone
//
//  Created by Joseph Cheung on 11/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREBeaconsMessagesTableViewController.h"

@interface HEREBeaconsMessagesTableViewController ()

@property (strong, nonatomic) NSMutableArray *beacons;

@end

@implementation HEREBeaconsMessagesTableViewController

#pragma mark - Lazy Instantiation
- (NSMutableArray *)beacons
{
    if (!_beacons) {
        _beacons = [[NSMutableArray alloc] init];
    }
    return _beacons;
}

#pragma mark - Controller Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSArray *beaconObjectsAsPropertyLists = [[NSUserDefaults standardUserDefaults] objectForKey:kHEREBeaconClassKey];
    for (NSDictionary *dictionary in beaconObjectsAsPropertyLists) {
        HEREBeacon *beacon = [self beaconObjectForDictionary:dictionary];
        [self.beacons addObject:beacon];
    }
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
    NSLog(@"local beacon count: %tu", [self.beacons count]);
    return [self.beacons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BeaconsMessagesCell" forIndexPath:indexPath];
    HEREBeacon *beacon = self.beacons[indexPath.row];
    cell.textLabel.text = beacon.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected row %tu", indexPath.row);
    NSLog(@"beacons: %@", [self.beacons[indexPath.row] class]);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate didSelectBeacon:self.beacons[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - helper methods
- (HEREBeacon *)beaconObjectForDictionary:(NSDictionary *)dictionary
{
    HEREBeacon *beacon = [[HEREBeacon alloc] initWithData:dictionary];
    return beacon;
}

@end
