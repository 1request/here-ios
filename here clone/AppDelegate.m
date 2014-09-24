//
//  AppDelegate.m
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "AppDelegate.h"
#import "HERERootViewController.h"
#import "HEREHomeViewController.h"
#import "APIManager.h"
#import "HEREMenuTableViewController.h"
#import "HERELocationHelper.h"
#import "CoreDataStore.h"

@interface AppDelegate () <locationDelegate>

@property (strong, nonatomic) HERELocationHelper *locationHelper;
@property (strong, nonatomic) NSManagedObjectContext *mainQueueContext;
@property (strong, nonatomic) NSManagedObjectContext *privateQueueContext;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse setApplicationId:@"JCkWGxB3gkoCe9yaZM3LTNy6pAsN67ssdibhetdP"
                  clientKey:@"wEYJFhzp2qhcamcXKBLCx4VJ2PFbb1Hldtvpml1B"];
    NSLog(@"didlaunched here clone");
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    application.applicationIconBadgeNumber = 0;
    if (localNotification) {
        NSLog(@"local notification in didfinishlaunching");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setBeacon" object:nil];
    }
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:@"all" forKey:@"channels"];
    [currentInstallation saveInBackground];
    
    UIApplication *app = [UIApplication sharedApplication];
    if ([app respondsToSelector:@selector(registerForRemoteNotifications)]) {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [app registerUserNotificationSettings:settings];
        [app registerForRemoteNotifications];
    } else {
        [app registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    }
    
    HERERootViewController *rootVC = (HERERootViewController *)self.window.rootViewController;

    HEREMenuTableViewController *menuVC = (HEREMenuTableViewController *)rootVC.menuViewController;
    UINavigationController *nav = (UINavigationController *)rootVC.contentViewController;
    HEREHomeViewController *homeVC = (HEREHomeViewController *)nav.topViewController;
    
    self.mainQueueContext = [CoreDataStore mainQueueContext];
    self.privateQueueContext = [CoreDataStore privateQueueContext];
    
    menuVC.managedObjectContext = self.mainQueueContext;
    homeVC.managedObjectContext = self.mainQueueContext;

    self.locationHelper = [[HERELocationHelper alloc] init];
    
    self.locationHelper.managedObjectContext = self.privateQueueContext;
    
    self.locationHelper.delegate = self;
    
    __block AppDelegate *weakSelf = self;
    [APIManager fetchLocationsWithManagedObjectContext:self.privateQueueContext CompletionHandler:^(BOOL success, NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.locationHelper monitorBeacons];
        });
    }];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kHEREAppInstallationDateKey]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kHEREAppInstallationDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setBeacon" object:nil];
    [application setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate");
}

#pragma mark - Notifications

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    application.applicationIconBadgeNumber = 0;
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        NSLog(@"application active didreceivelocationnotification");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:notification.alertBody delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if (state == UIApplicationStateInactive) {
        NSLog(@"application inactive didreceivelocationnotification");
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kHERELocationClassKey];
        
        request.predicate = [NSPredicate predicateWithFormat:@"locationId == %@", [notification.userInfo objectForKey:kHERENotificationLocationIdKey]];
        
        NSArray *locations = [self.mainQueueContext executeFetchRequest:request error:NULL];
        
        if ([locations count]) {
            Location *location = [locations firstObject];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            HERERootViewController *rootVC = (HERERootViewController *)self.window.rootViewController;
            UINavigationController *nav = (UINavigationController *)rootVC.contentViewController;
            HEREHomeViewController *homeVC = [storyboard instantiateViewControllerWithIdentifier:@"homeController"];
            HEREBeaconsMessagesTableViewController *beaconsMessagesTVC = [storyboard instantiateViewControllerWithIdentifier:@"beaconsMessagesController"];
            beaconsMessagesTVC.location = location;
            [nav setViewControllers:@[homeVC, beaconsMessagesTVC]];
        }
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setBeacon" object:nil];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    [User setDeviceTokenFromData:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get token, error: %@", error);
    
    [User currentInstallation];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification");
    [PFPush handlePush:userInfo];
    [self clearNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"didReceiveRemoteNotification fetchCompletionHandler");
    [self clearNotifications];
}

- (void) clearNotifications
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
#pragma mark - locationHelper delegate

- (void)notifyWhenEntryBeacon:(CLBeaconRegion *)beaconRegion
{
    NSLog(@"Enter region (app delegate): %@", beaconRegion);
//    [self fetchMessagesForBeaconRegion:beaconRegion];
}

- (void)notifyWhenExitBeacon:(CLBeaconRegion *)beaconRegion
{
    NSLog(@"exit region (app delegate): %@", beaconRegion);
}

- (void)notifyWhenFar:(CLBeacon *)beacon
{
    //    NSLog(@"far from beacon: %@", beacon);
}

- (void)notifyWhenImmediate:(CLBeacon *)beacon
{
    //    NSLog(@"Immediate to beacon: %@", beacon);
}

- (void)notifyWhenNear:(CLBeacon *)beacon
{
    //    NSLog(@"Near beacon: %@", beacon);
}

@end
