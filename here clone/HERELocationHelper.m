//
//  HERELocationHelper.m
//  here clone
//
//  Created by Joseph Cheung on 13/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HERELocationHelper.h"
#import "Location.h"
#import "HERECoreDataHelper.h"

@interface HERELocationHelper () {
    NSTimer *timer;
}
@property (strong, nonatomic) NSMutableArray *beaconRegions;
@property (weak, nonatomic) NSString *previousTriggeredBeaconParseId;
@end

@implementation HERELocationHelper

#pragma mark - instantiation

- (NSMutableArray *)beaconRegions
{
    if (!_beaconRegions) _beaconRegions = [[NSMutableArray alloc] init];
    return _beaconRegions;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

#pragma mark - beacon notification

- (void)loadBeacons
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kHERELocationClassKey];
    
    NSArray *locations = [[HERECoreDataHelper managedObjectContext] executeFetchRequest:fetchRequest error:nil];
    
    for (Location *location in locations) {
        if (location.uuid && location.major && location.minor && location.name) {
            CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:location.uuid] major:[location.major integerValue] minor:[location.minor integerValue] identifier:location.name];
            beaconRegion.notifyEntryStateOnDisplay = YES;
            beaconRegion.notifyOnEntry = YES;
            beaconRegion.notifyOnExit = YES;
            [self.beaconRegions addObject:beaconRegion];
        }
    }
}

- (void)monitorBeacons
{
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self loadBeacons];
    
    for (CLBeaconRegion *beaconRegion in self.beaconRegions) {
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

//- (void)stopMonitoringBeacon:(HEREBeacon *)beacon
//{
//    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beacon.uuid major:beacon.major minor:beacon.minor identifier:beacon.name];
//    [self.locationManager stopMonitoringForRegion:beaconRegion];
//    [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
//}

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
    
    [self loadBeacons];
    
    if (self.delegate) {
        if (region.major && region.minor) {
//            self.previousTriggeredBeaconParseId = [[NSUserDefaults standardUserDefaults] objectForKey:kHEREBeaconTriggeredKey];
            [self.delegate notifyWhenEntryBeacon:region];
            [self sendLocalNotificationWithMessage:[NSString stringWithFormat:@"New message from %@!", region.identifier]];
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

- (void)sendLocalNotificationWithMessage:(NSString *)message
{
    UILocalNotification *notification = [UILocalNotification new];
    
    // Notification details
    notification.alertBody = message;
    // notification.alertBody = [NSString stringWithFormat:@"Entered beacon region for UUID: %@",
    //                         region.proximityUUID.UUIDString];   // Major and minor are not available at the monitoring stage
    notification.alertAction = NSLocalizedString(@"View Details", nil);
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    if ([notification respondsToSelector:@selector(regionTriggersOnce)]) {
        notification.regionTriggersOnce = YES;
    }
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    }
    
    NSLog(@"notification: %@", notification);
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}
@end
