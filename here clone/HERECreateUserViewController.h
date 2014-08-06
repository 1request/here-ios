//
//  HERECreateUserViewController.h
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HERECreateUserViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UIButton *signUpButtonPressed;

@end
