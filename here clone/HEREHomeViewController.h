//
//  HEREHomeViewController.h
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "REFrostedViewController.h"
#import "UIViewController+HEREMenu.h"
#import "HEREBeaconsMessagesTableViewController.h"
#import "HEREFactory.h"
#import "HERELocation.h"

@interface HEREHomeViewController : UIViewController <AVAudioPlayerDelegate, AVAudioRecorderDelegate, CLLocationManagerDelegate, beaconsMessagesTableViewControllerDelegate, locationDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic)AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) IBOutlet UIButton *recordMessageButton;
@property (strong, nonatomic) IBOutlet UIButton *avatarButton;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *activityLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIView *activityView;
@property (strong, nonatomic) HERELocation *location;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender;
- (IBAction)recordMessageButtonPressed:(UIButton *)sender;
- (IBAction)recordMessageButtonTouchedDown:(UIButton *)sender;
- (IBAction)avatarButtonPressed:(UIButton *)sender;
@end
