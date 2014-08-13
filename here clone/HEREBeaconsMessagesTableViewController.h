//
//  HEREBeaconsMessagesTableViewController.h
//  here clone
//
//  Created by Joseph Cheung on 11/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEREBeacon.h"

@protocol beaconsMessagesTableViewControllerDelegate <NSObject>

- (void)didSelectBeacon:(HEREBeacon *)beacon;

@end

@interface HEREBeaconsMessagesTableViewController : UITableViewController

@property (weak, nonatomic) id <beaconsMessagesTableViewControllerDelegate> delegate;

@end
