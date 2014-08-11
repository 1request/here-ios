//
//  HERENavigationViewController.m
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HERENavigationViewController.h"
#import "HERESignInUpViewController.h"
@interface HERENavigationViewController ()

@end

@implementation HERENavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognized:)]];
}

#pragma mark - Gesture recognizer


- (void)swipeGestureRecognized:(UIPanGestureRecognizer *)sender
{
    
    if (![self.visibleViewController isKindOfClass:[HERESignInUpViewController class]]) {
        [self showMenu];
    }
}

@end
