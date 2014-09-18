//
//  APIManager.h
//  here clone
//
//  Created by Joseph Cheung on 25/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEREBeacon.h"
#import "Location.h"

@interface APIManager : NSObject

typedef void (^HERECompletionBlock)(BOOL success, NSDictionary *response, NSError *error);

+ (void)updateUser:(NSString *)token username:(NSString *)name;

+ (void)pushAudioMessageToServer:(NSData *)data Location:(Location *)location;
+ (void)pushTextMessageToServer:(NSString *)text Location:(Location *)location;
+ (void)fetchLocationsWithManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)fetchMessagesForLocation:(Location *)location;
+ (void)createLocationInServer:(NSDictionary *)data;

@end
