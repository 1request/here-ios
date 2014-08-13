//
//  HEREBeaconsTableViewController.h
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import "UIViewController+HEREMenu.h"
#import "HEREAddBeaconViewController.h"

@interface HEREBeaconsTableViewController : UITableViewController <addBeaconViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender;

@end
