//
//  HEREHomeViewController.m
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREHomeViewController.h"

@interface HEREHomeViewController ()

@end

@implementation HEREHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image = [UIImage imageNamed:@"here.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];

    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    NSError *error;
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    self.audioRecorder.delegate = self;
    self.audioRecorder.meteringEnabled = YES;
    [self.audioRecorder prepareToRecord];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    self.usernameLabel.text = [PFUser currentUser].username;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender
{
    [self showMenu];
}

- (IBAction)recordMessageButtonTouchedDown:(UIButton *)sender
{
    if (self.audioPlayer.playing) {
        [self.audioPlayer stop];
    }
    
    if (!self.audioRecorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        [self.audioRecorder record];
        
        [self.recordMessageButton setTitle:@"Recording..." forState:UIControlStateNormal];
    }
    else {
        [self.audioRecorder pause];
        [self.recordMessageButton setTitle:@"Pausing recorder..." forState:UIControlStateNormal];
    }
}

- (IBAction)recordMessageButtonPressed:(UIButton *)sender
{
    [self.audioRecorder stop];
    [self.recordMessageButton setTitle:@"Leave a message" forState:UIControlStateNormal];
}

- (IBAction)avatarButtonPressed:(UIButton *)sender
{
    if (!self.audioRecorder.recording) {
        NSError *error;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioRecorder.url error:&error];
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        else {
            [self.audioPlayer play];
        }
    }
}
@end
