//
//  HEREHomeViewController.m
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREHomeViewController.h"

@interface HEREHomeViewController ()

@property (strong, nonatomic) HEREBeacon *beacon;
@property (strong, nonatomic) NSMutableArray *audioRecords;
@property (strong, nonatomic) NSMutableArray *beacons;

@end

@implementation HEREHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HEREFactory *factory = [[HEREFactory alloc] init];
    [factory queryBeacons];
    self.beacons = [factory returnBeacons];
    
    self.location = [HERELocation new];

    self.location.delegate = self;

    [self.location monitorBeacons];
    
    [self.navigationController setNavigationBarHidden:NO];
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
    
    self.usernameLabel.text = [PFUser currentUser].username;
    
    [self.avatarButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    if (self.beacon) [self queryAudio];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"setBeacon" object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *dict = [note userInfo];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"parseId == %@", dict[kHEREBeaconParseIdKey]];
        HEREBeacon *beacon = [[self.beacons filteredArrayUsingPredicate:pred] firstObject];
        self.beacon = beacon;
        self.locationLabel.text = beacon.name;
        [self queryAudio];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[HEREBeaconsMessagesTableViewController class]]) {
        HEREBeaconsMessagesTableViewController *beaconsMessagesTableViewController = segue.destinationViewController;
        beaconsMessagesTableViewController.delegate = self;
    }
}

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
    if (self.beacon) {
        [self uploadAudio];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location not selected" message:@"Location is not selected yet. Please press + sign on navigation bar to select one." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

- (IBAction)avatarButtonPressed:(UIButton *)sender
{
    if (!self.audioRecorder.recording) {
        PFObject *audio = [self.audioRecords lastObject];
        NSError *error;
        if (audio) {
            NSLog(@"Play audio from parse");
            PFFile *audioFile = audio[kHEREAudioFileKey];
            NSURL *url = [[NSURL alloc] initWithString:[audioFile url]];
            NSData *data = [NSData dataWithContentsOfURL:url];
            self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
        } else {
            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioRecorder.url error:&error];
        }
        if (!error) {
            NSLog(@"no error, play audio");
            [self.audioPlayer play];
        }
        else {
            NSLog(@"Error palying audio: %@", error.description);
        }
    }
}

#pragma mark - beaconsMessagesTableViewController Delegate

- (void)didSelectBeacon:(HEREBeacon *)beacon
{
    NSLog(@"did select beacon, parseId: %@", beacon.parseId
          );
    self.beacon = beacon;
    [self queryAudio];
    self.locationLabel.text = beacon.name;
}

#pragma mark - helper methods

- (void)uploadAudio
{
    self.activityView.hidden = NO;
    [self showActivityIndicator];
    self.activityLabel.text = @"Uploading";
    self.avatarButton.enabled = NO;
    
    NSData *audioData = [NSData dataWithContentsOfURL:self.audioRecorder.url];
    
    PFFile *audioFile = [PFFile fileWithName:@"memo.m4a" data:audioData];
    
    [audioFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PFObject *audio = [PFObject objectWithClassName:kHEREAudioClassKey];
            [audio setObject:[PFUser currentUser] forKey:kHEREAudioUserKey];
            [audio setObject:audioFile forKey:kHEREAudioFileKey];
            [audio setObject:[NSNumber numberWithBool:NO] forKey:kHEREAudioIsReadKey];
            audio[kHEREAudioBeaconKey] = [PFObject objectWithoutDataWithClassName:kHEREBeaconClassKey objectId:self.beacon.parseId];
            [audio saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"save audio file and collection successfully");
                    [self hideActivityIndicator];
                    self.activityView.hidden = YES;
                    [self queryAudio];
                }
            }];
        }
    }];
}

- (void)queryAudio
{
    [self showActivityIndicator];
    self.activityLabel.text = @"Querying";
    self.activityView.hidden = NO;
    self.avatarButton.enabled = NO;
    
    PFQuery *query = [PFQuery queryWithClassName:kHEREAudioClassKey];
    [query whereKey:kHEREAudioBeaconKey equalTo:[PFObject objectWithoutDataWithClassName:kHEREBeaconClassKey objectId:self.beacon.parseId]];
    [query whereKey:kHEREAudioUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"queried audio records at location %@, count: %tu", self.beacon.name, [objects count]);
            self.audioRecords = [objects mutableCopy];
            [self hideActivityIndicator];
            self.activityView.hidden = YES;
            self.avatarButton.enabled = YES;
        }
        else {
            NSLog(@"error when querying audio in home view controller: %@", error.description);
        }
    }];
}

#pragma mark - activity indicator
- (void) showActivityIndicator {
    [UIView animateWithDuration:0.3 animations:^{
        self.activityIndicator.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.activityIndicator startAnimating];
    }];
}

- (void) hideActivityIndicator {
    [UIView animateWithDuration:0.3 animations:^{
        self.activityIndicator.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.activityIndicator stopAnimating];
    }];
}

#pragma mark - factory delegate

- (void)notifyWhenEntryBeacon:(HEREBeacon *)beacon
{
    self.beacon = beacon;
}

- (void)notifyWhenExitBeacon:(CLBeaconRegion *)beaconRegion
{
//    NSLog(@"exit region: %@", beaconRegion);
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
