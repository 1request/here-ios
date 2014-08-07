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

@interface HEREHomeViewController : UIViewController <AVAudioPlayerDelegate, AVAudioRecorderDelegate>

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic)AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) IBOutlet UIButton *recordMessageButton;
@property (strong, nonatomic) IBOutlet UIButton *avatarButton;

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender;
- (IBAction)recordMessageButtonPressed:(UIButton *)sender;
- (IBAction)recordMessageButtonTouchedDown:(UIButton *)sender;
- (IBAction)avatarButtonPressed:(UIButton *)sender;
@end
