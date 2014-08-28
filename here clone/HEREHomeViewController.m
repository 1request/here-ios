//
//  HEREHomeViewController.m
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREHomeViewController.h"

@interface HEREHomeViewController () {
    NSTimer *timer;
    NSTimeInterval timeInterval;
}

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) HEREBeacon *beacon;
@property (strong, nonatomic) NSMutableArray *audioRecords;
@property (strong, nonatomic) NSMutableArray *beacons;
@property (strong, nonatomic) NSData *audioData;

@end

@implementation HEREHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"groupCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Home";
            cell.detailTextLabel.text = @"2";
            break;
        case 1:
            cell.textLabel.text = @"Garage Society";
            cell.detailTextLabel.text = @"1";
            break;
        case 2:
            cell.textLabel.text = @"Cyberport";
            cell.detailTextLabel.text = @"4";
            break;
        case 3:
            cell.textLabel.text = @"UNO";
            cell.detailTextLabel.text = @"1";
            break;
        default:
            break;
    }
    
    return cell;
}

@end
