//
//  Location+API.m
//  here clone
//
//  Created by Joseph Cheung on 16/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "Location+API.h"

@implementation Location (API)

+ (Location *)locationWithAPIInfo:(NSDictionary *)locationDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Location *location = nil;
    
    NSString *locationId = locationDictionary[kHEREAPIIdKey];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kHERELocationClassKey];
    request.predicate = [NSPredicate predicateWithFormat:@"locationId == %@", locationId];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        NSLog(@"error when fetching location in locationWithAPIInfo, %@", error.localizedDescription);
    }
    else if ([matches count]) {
        location = [matches firstObject];
    }
    else {
        location = [NSEntityDescription insertNewObjectForEntityForName:kHERELocationClassKey inManagedObjectContext:context];
        location.locationId = locationId;
        if (locationDictionary[kHEREAPILocationUUIDKey] != [NSNull null]) location.uuid = [locationDictionary valueForKeyPath:kHEREAPILocationUUIDKey];
        if (locationDictionary[kHEREAPILocationMajorKey] != [NSNull null]) location.major = [locationDictionary valueForKeyPath:kHEREAPILocationMajorKey];
        if (locationDictionary[kHEREAPILocationMinorKey] != [NSNull null]) location.minor = [locationDictionary valueForKeyPath:kHEREAPILocationMinorKey];
        if (locationDictionary[kHEREAPILocationMacAddressKey] != [NSNull null]) location.macAddress = [locationDictionary valueForKeyPath:kHEREAPILocationMacAddressKey];
        if (locationDictionary[kHEREAPILocationAccessIdKey] != [NSNull null]) location.accessId = [locationDictionary valueForKeyPath:kHEREAPILocationAccessIdKey];
        if (locationDictionary[kHEREAPILocationLatitudeKey] != [NSNull null]) location.latitude = [locationDictionary valueForKeyPath:kHEREAPILocationLatitudeKey];
        if (locationDictionary[kHEREAPILocationLongitudeKey] != [NSNull null]) location.longitude = [locationDictionary valueForKeyPath:kHEREAPILocationLongitudeKey];
        if (locationDictionary[kHEREAPILocationNameKey] != [NSNull null]) location.name = [locationDictionary valueForKeyPath:kHEREAPILocationNameKey];
        [context save:NULL];
    }
    return location;
}

+ (NSArray *)loadLocationsFromAPIArray:(NSArray *)locations intoManagedObjectContext:(NSManagedObjectContext *)context
{
    NSMutableArray *coreDataLocations = [[NSMutableArray alloc] init];
    for (NSDictionary *location in locations) {
        [coreDataLocations addObject:[self locationWithAPIInfo:location inManagedObjectContext:context]];
    }
    return [coreDataLocations copy];
}

@end
