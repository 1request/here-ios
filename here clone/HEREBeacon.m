//
//  HEREBeacon.m
//  here clone
//
//  Created by Joseph Cheung on 12/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREBeacon.h"

@implementation HEREBeacon

- (id)init
{
    self = [self initWithData:nil];
    return self;
}

- (id)initWithData:(NSDictionary *)data
{
    self = [super init];
    
    self.uuid = [[NSUUID alloc] initWithUUIDString:data[kHEREBeaconUUIDKey]];
    self.major = [data[kHEREBeaconMajorKey] intValue];
    self.minor = [data[kHEREBeaconMinorKey] intValue];
    self.name = data[kHEREBeaconNameKey];
    
    return self;
}

@end
