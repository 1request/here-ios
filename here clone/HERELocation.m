//
//  HERELocation.m
//  here clone
//
//  Created by Joseph Cheung on 13/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HERELocation.h"

@interface HERELocation () {
    NSTimer *timer;
}
@property (strong, nonatomic) NSMutableArray *beacons;
@end

@implementation HERELocation

#pragma mark - instantiation

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

#pragma mark - beacon notification

- (NSMutableArray *)beacons
{
    HEREFactory *factory = [[HEREFactory alloc] init];
    if (!_beacons) {
        _beacons = [factory returnBeacons];
    }
    return _beacons;
}

- (void)monitorBeacons
{
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    for (HEREBeacon *beacon in self.beacons) {
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beacon.uuid major:beacon.major minor:beacon.minor identifier:beacon.name];
        beaconRegion.notifyEntryStateOnDisplay = YES;
        beaconRegion.notifyOnEntry = YES;
        beaconRegion.notifyOnExit = YES;
        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
        [self.locationManager startMonitoringForRegion:beaconRegion];
    }
}

- (void)stopMonitoringBeacons
{
    for (CLBeaconRegion *region in self.locationManager.monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region];
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
}

- (void)stopMonitoringBeacon:(HEREBeacon *)beacon
{
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beacon.uuid major:beacon.major minor:beacon.minor identifier:beacon.name];
    [self.locationManager stopMonitoringForRegion:beaconRegion];
    [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
}

#pragma mark - CLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Couldn't turn on monitoring: Location services are not enabled.");
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        NSLog(@"Couldn't turn on monitoring: Location services not authorised.");
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        NSLog(@"Couldn't turn on monitoring: Location services (Always) not authorised.");
        return;
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
//    NSLog(@"%s Range region: %@ with beacons %@",__PRETTY_FUNCTION__ ,region , beacons);
    
    for (CLBeacon *b in beacons) {
        if (b.proximity == CLProximityImmediate) {
            [self.delegate notifyWhenImmediate:b];
        } else if (b.proximity == CLProximityNear) {
            [self.delegate notifyWhenNear:b];
        } else if (b.proximity == CLProximityFar) {
            [self.delegate notifyWhenFar:b];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLBeaconRegion *)region
{
    NSLog(@"Did Entered region in HERELocation: %@", region);
    
    if (self.delegate) {
        if (region.major && region.minor) {
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"uuid.UUIDString == %@ AND major == %i AND minor == %i", region.proximityUUID.UUIDString, [region.major intValue], [region.minor intValue]];
            NSArray *filteredBeacons = [self.beacons filteredArrayUsingPredicate:pred];
            if ([filteredBeacons count] > 0) {
                HEREBeacon *beacon = [filteredBeacons firstObject];
                [self.delegate notifyWhenEntryBeacon:beacon];
                [self sendLocalNotificationWithMessage:[NSString stringWithFormat:@"New message from %@!", beacon.name] withBeacon:beacon];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLBeaconRegion *)region
{
//    NSLog(@"Exited region: %@", region);
    
    if (self.delegate) {
        
        [self.delegate notifyWhenExitBeacon:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSString *stateString = nil;
    switch (state) {
        case CLRegionStateInside:
            stateString = @"inside";
            break;
        case CLRegionStateOutside:
            stateString = @"outside";
            break;
        case CLRegionStateUnknown:
            stateString = @"unknown";
            break;
    }
//    NSLog(@"State changed to %@ for region %@.", stateString, region);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSString *message = [NSString stringWithFormat:@"error: %@ / region: %@", [error description], region.minor];
    NSLog(@"%@", message);
}

- (void)sendLocalNotificationWithMessage:(NSString*)message withBeacon:(HEREBeacon *)beacon
{
    UILocalNotification *notification = [UILocalNotification new];
    
    // Notification details
    notification.alertBody = message;
    // notification.alertBody = [NSString stringWithFormat:@"Entered beacon region for UUID: %@",
    //                         region.proximityUUID.UUIDString];   // Major and minor are not available at the monitoring stage
    notification.alertAction = NSLocalizedString(@"View Details", nil);
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    notification.userInfo = @{kHEREBeaconParseIdKey: beacon.parseId};
    
    if ([notification respondsToSelector:@selector(regionTriggersOnce)]) {
        notification.regionTriggersOnce = YES;
    }
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    }
    
    if (timer == nil) {
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
        timer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(turnOnLocal) userInfo:nil repeats:NO];
    }
}

- (void)turnOnLocal
{
    [timer invalidate];
    timer = nil;
}

@end
