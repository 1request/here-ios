//
//  HERENavigationViewController.h
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import "UIViewController+HEREMenu.h"

@interface HERENavigationViewController : UINavigationController

- (void)swipeGestureRecognized:(UIPanGestureRecognizer *)sender;

@end
