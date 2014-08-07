//
//  HEREBeaconsTableViewController.h
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"

@interface HEREBeaconsTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender;

@end
