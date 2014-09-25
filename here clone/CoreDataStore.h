//
//  CoreDataStore.h
//  here clone
//
//  Created by Joseph Cheung on 24/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface CoreDataStore : NSObject

+ (instancetype)defaultStore;

+ (NSManagedObjectContext *)mainQueueContext;
+ (NSManagedObjectContext *)privateQueueContext;

+ (NSManagedObjectID *)managedObjectIDFromString:(NSString *)managedObjectIDString;

@end
