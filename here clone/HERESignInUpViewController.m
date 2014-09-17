//
//  HERESignInUpViewController.m
//  here clone
//
//  Created by Joseph Cheung on 8/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HERESignInUpViewController.h"
#import "HEREHomeViewController.h" 

@interface HERESignInUpViewController ()

@end

@implementation HERESignInUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([User username]) {
        HEREHomeViewController *homeController = [self.storyboard instantiateViewControllerWithIdentifier:@"homeController"];
        [self.navigationController setViewControllers:@[homeController] animated:NO];
        homeController.managedObjectContext = self.managedObjectContext;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
