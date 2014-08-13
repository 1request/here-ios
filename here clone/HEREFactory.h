//
//  HEREFactory.h
//  here clone
//
//  Created by Joseph Cheung on 13/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol factoryDelegate <NSObject>

- (void)didFinishQueryingBeaconsFromParse;

@end

@interface HEREFactory : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) id <factoryDelegate> delegate;

- (void)queryBeacons;
- (NSMutableArray *)returnBeacons;

@end
