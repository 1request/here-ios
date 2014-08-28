//
//  HEREBeaconsMessagesTableViewController.h
//  here clone
//
//  Created by Joseph Cheung on 11/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEREBeacon.h"
#import <JSQMessages.h>

@interface HEREBeaconsMessagesTableViewController : JSQMessagesViewController

@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSMutableArray *messages;
@property (copy, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender;

@end
