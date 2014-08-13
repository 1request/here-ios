//
//  AppDelegate.m
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

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
        NSLog(@"localnotification in didfinishlaunching");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setBeacon" object:nil userInfo:localNotification.userInfo];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    application.applicationIconBadgeNumber = 0;
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        NSLog(@"applicationactive didreceivelocationnotification");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:notification.alertBody delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if (state == UIApplicationStateInactive) {
        NSLog(@"applicationinactive didreceivelocationnotification");
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setBeacon" object:nil userInfo:notification.userInfo];
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate");
}

@end
