//
//  Location+API.h
//  here clone
//
//  Created by Joseph Cheung on 16/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "Location.h"

@interface Location (API)

+ (Location *)locationWithAPIInfo:(NSDictionary *)locationDictionary
           inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *)loadLocationsFromAPIArray:(NSArray *)locations //of API NSDictionary
         intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
