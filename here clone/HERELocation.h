//
//  HERELocation.h
//  here clone
//
//  Created by Joseph Cheung on 13/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "HEREFactory.h"
#import "HEREBeacon.h"

@protocol locationDelegate <NSObject>

- (void)notifyWhenEntryBeacon:(HEREBeacon *)beacon;
- (void)notifyWhenExitBeacon:(CLBeaconRegion*)beaconRegion;

- (void)notifyWhenImmediate:(CLBeacon *)beacon;
- (void)notifyWhenNear:(CLBeacon *)beacon;
- (void)notifyWhenFar:(CLBeacon *)beacon;

@end

@interface HERELocation : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) id <locationDelegate> delegate;

- (void)monitorBeacons;
- (void)stopMonitoringBeacons;
- (void)stopMonitoringBeacon:(HEREBeacon *)beacon;
@end
