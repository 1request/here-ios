//
//  HERERootViewController.h
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "REFrostedViewController.h"

@interface HERERootViewController : REFrostedViewController
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIViewController *contentViewController;
@end
