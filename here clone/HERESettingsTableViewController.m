//
//  HERESettingsTableViewController.m
//  here clone
//
//  Created by Joseph Cheung on 18/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HERESettingsTableViewController.h"
#import "UIViewController+HEREMenu.h"

@implementation HERESettingsTableViewController

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
}


#pragma mark - Target Action

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender
{
    [self showMenu];
}

#pragma mark - UITableViewControllerDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Settings Cell" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Avatar";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case 1:
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = ([User username]) ? [User username] : @"";
            break;
        case 2:
            cell.textLabel.text = @"My Beacons";
            cell.detailTextLabel.text = @"";
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableVieweControllerDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 1:
            [self performSegueWithIdentifier:@"Set Username" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"Add Beacon" sender:self];
            break;
        default:
            break;
    }
}

@end
