//
//  UIViewController+HEREMenu.m
//  here clone
//
//  Created by Joseph Cheung on 8/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "UIViewController+HEREMenu.h"

@implementation UIViewController (HEREMenu)

- (void)showMenu
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];
}

@end
