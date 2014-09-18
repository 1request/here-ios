//
//  HERESetUsernameViewController.m
//  here clone
//
//  Created by Joseph Cheung on 18/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HERESetUsernameViewController.h"

@interface HERESetUsernameViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@end

@implementation HERESetUsernameViewController

- (void)setUsernameTextField:(UITextField *)usernameTextField
{
    _usernameTextField = usernameTextField;
    
    _usernameTextField.text = ([User username]) ? [User username] : @"";
}

- (IBAction)saveButtonPressed:(UIBarButtonItem *)sender
{
    if ([self.usernameTextField.text length]) {
        [User setUser:self.usernameTextField.text CompletionHandler:^(BOOL success, NSDictionary *response, NSError *error) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid username" message:@"username cannot be updated. Please try another one." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid username" message:@"username cannot be blank" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
}

@end
