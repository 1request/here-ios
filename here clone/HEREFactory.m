//
//  HEREFactory.m
//  here clone
//
//  Created by Joseph Cheung on 13/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREFactory.h"
#import "HEREBeacon.h"

@interface HEREFactory ()
    @property (strong, nonatomic) NSMutableArray *beacons;
@end

@implementation HEREFactory

#pragma mark - helper methods

- (void)queryBeacons
{
    PFQuery *query = [PFQuery queryWithClassName:@"Beacon"];
//    [query whereKey:kHEREBeaconUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.beacons = [objects mutableCopy];
            NSLog(@"Queried successfully; count: %tu", [self.beacons count]);
            [self saveBeaconsLocally];
        }
        else {
            NSLog(@"Error when query beacons in beaconsTableViewController: %@", error.description);
        }
    }];
}

- (NSDictionary *)beaconObjectAsPropertyList:(PFObject *)beacon
{
    NSDictionary *beaconObjectAsPropertyList = @{kHEREBeaconUUIDKey : beacon[kHEREBeaconUUIDKey], kHEREBeaconMajorKey : beacon[kHEREBeaconMajorKey], kHEREBeaconMinorKey : beacon[kHEREBeaconMinorKey], kHEREBeaconNameKey : beacon[kHEREBeaconNameKey], kHEREBeaconParseIdKey : beacon.objectId};
    
    return beaconObjectAsPropertyList;
}

- (void)saveBeaconsLocally
{
    NSMutableArray *localBeaconObjectData = [[NSMutableArray alloc] init];
    for (PFObject *beacon in self.beacons) {
        [localBeaconObjectData addObject:[self beaconObjectAsPropertyList:beacon]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:localBeaconObjectData forKey:kHEREBeaconClassKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.delegate didFinishQueryingBeaconsFromParse];
}


- (HEREBeacon *)beaconObjectForDictionary:(NSDictionary *)dictionary
{
    HEREBeacon *beacon = [[HEREBeacon alloc] initWithData:dictionary];
    return beacon;
}


- (NSMutableArray *)returnBeacons
{    
    NSArray *beaconObjectsAsPropertyLists = [[NSUserDefaults standardUserDefaults] objectForKey:kHEREBeaconClassKey];
    NSMutableArray *beaconObjects = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dictionary in beaconObjectsAsPropertyLists) {
        HEREBeacon *beacon = [self beaconObjectForDictionary:dictionary];
        [beaconObjects addObject:beacon];
    }
    
    return beaconObjects;
}

@end
