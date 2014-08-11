//
//  HERECreateUserViewController.m
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HERECreateUserViewController.h"
#import "HEREHomeViewController.h"

@interface HERECreateUserViewController ()

@end

@implementation HERECreateUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender
{
    [self showMenu];
}

- (IBAction)signUpButtonPressed:(UIButton *)sender
{
    PFUser *user = [[PFUser alloc] init];
    user.username = self.usernameTextField.text;
    user.password = self.passwordTextField.text;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.signUpButton.enabled = NO;
        if (!succeeded) {
            NSLog(@"Error happen when saving user: %@", error.description);
        }
        else {
            NSLog(@"user created!, username: %@, password: %@", user.username, user.password);
            [self performSegueWithIdentifier:@"signUpToHomeSegue" sender:nil];
        }
    }];
}
@end
