//
//  HEREStatusViewController.h
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import "UIViewController+HEREMenu.h"


@interface HEREStatusViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *locationLabel;

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender;

@end
