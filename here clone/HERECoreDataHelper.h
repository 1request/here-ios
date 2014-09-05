//
//  HERECoreDataHelper.h
//  here clone
//
//  Created by Joseph Cheung on 1/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HERECoreDataHelper : NSObject

+ (NSManagedObjectContext *)managedObjectContext;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
@end
