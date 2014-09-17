//
//  HEREHomeViewController.h
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "REFrostedViewController.h"
#import "UIViewController+HEREMenu.h"
#import "HEREBeaconsMessagesTableViewController.h"
#import "CoreDataTableViewController.h"

@interface HEREHomeViewController : CoreDataTableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender;

@end
