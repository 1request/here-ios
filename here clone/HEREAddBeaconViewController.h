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
#import "Canvas.h"
#import "UIViewController+HEREMenu.h"

@interface HEREAddBeaconViewController : UIViewController <CLLocationManagerDelegate>


@property (strong, nonatomic) IBOutlet UILabel *majorLabel;
@property (strong, nonatomic) IBOutlet UILabel *minorLabel;
@property (strong, nonatomic) IBOutlet UILabel *majorNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *minorNumberLabel;
@property (strong, nonatomic) IBOutlet UITextField *beaconNameTextField;
@property (strong, nonatomic) IBOutlet CSAnimationView *animationView;
@property (strong, nonatomic) IBOutlet UIButton *scanBeaconButton;
@property (strong, nonatomic) IBOutlet UIButton *addBeaconButton;
@property (strong, nonatomic) IBOutlet UILabel *scanningBeaconsLabel;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender;
- (IBAction)addBeaconButtonPressed:(UIButton *)sender;
- (IBAction)cancelButtonPressed:(UIButton *)sender;
- (IBAction)scanBeaconButtonPressed:(UIButton *)sender;

@end
