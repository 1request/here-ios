//
//  HEREAddBeaconViewController.h
//  here clone
//
//  Created by Joseph Cheung on 7/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "REFrostedViewController.h"

@interface HEREAddBeaconViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *majorLabel;
@property (strong, nonatomic) IBOutlet UILabel *minorLabel;
@property (strong, nonatomic) IBOutlet UITextField *beaconNameTextField;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender;
- (IBAction)addBeaconButtonPressed:(UIButton *)sender;
- (IBAction)cancelButtonPressed:(UIButton *)sender;

@end
