//
//  HEREBeaconsMessagesTableViewController.h
//  here clone
//
//  Created by Joseph Cheung on 11/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessages.h>
#import <AVFoundation/AVFoundation.h>
#import "Location.h"

@interface HEREBeaconsMessagesTableViewController : JSQMessagesViewController <AVAudioPlayerDelegate, AVAudioRecorderDelegate>

@property (strong, nonatomic) Location *location;

@end
