//
//  HERECoreDataHelper.m
//  here clone
//
//  Created by Joseph Cheung on 1/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HERECoreDataHelper.h"

@implementation HERECoreDataHelper

+ (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate respondsToSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate respondsToSelector:@selector(persistentStoreCoordinator)]) {
        persistentStoreCoordinator = [delegate persistentStoreCoordinator];
    }
    return persistentStoreCoordinator;
}

@end
