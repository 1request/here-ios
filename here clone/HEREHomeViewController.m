//
//  HEREHomeViewController.m
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREHomeViewController.h"

@interface HEREHomeViewController () {
    NSTimer *timer;
}

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) HEREBeacon *beacon;
@property (strong, nonatomic) NSMutableArray *audioRecords;
@property (strong, nonatomic) NSMutableArray *beacons;
@property (strong, nonatomic) NSURLConnection *connectionManager;
@property (strong, nonatomic) NSData *audioData;
@property (strong, nonatomic) NSURLResponse *urlResponse;

@end

@implementation HEREHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateBeacons];
    
    [self triggerBeacon];
    
    timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.audioData = nil;
    
    [self updateBeacons];
    
    self.location = [HERELocation new];
    
    self.location.delegate = self;
    
    [self.location stopMonitoringBeacons];
    [self.location monitorBeacons];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerBeacon) name:@"setBeacon" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        
        self.startDate = [NSDate date];
        
        [self.recordMessageButton setTitle:@"Recording..." forState:UIControlStateNormal];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    }
    else {
        [self.audioRecorder pause];
        [self.recordMessageButton setTitle:@"Pausing recorder..." forState:UIControlStateNormal];
    }
}

- (IBAction)recordMessageButtonPressed:(UIButton *)sender
{
    [self.audioRecorder stop];
    [timer invalidate];
    timer = nil;
    [self.recordMessageButton setTitle:@"Leave a message" forState:UIControlStateNormal];
    [self.recordMessageButton setTitle:@"Recording..." forState:UIControlStateHighlighted];
    
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
        if (self.audioData) {
            NSError *error;
            self.audioPlayer = [[AVAudioPlayer alloc] initWithData:self.audioData error:&error];
            self.audioPlayer.delegate = self;
            [self.audioPlayer play];
            [self showActivityIndicator];
            self.activityLabel.text = @"Playing";
//            [self enableAvatarButton:NO];
            self.activityView.hidden = NO;
            [self performSelector:@selector(highlightButton:) withObject:sender afterDelay:0.0];
        }
    }
}

#pragma mark - beaconsMessagesTableViewController Delegate

- (void)didSelectBeacon:(HEREBeacon *)beacon
{
    NSLog(@"did select beacon, %@", beacon.name);
    [self updateBeacon:beacon];
}

#pragma mark - helper methods

- (void)updateTimer
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:self.startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    NSString *timeString = [formatter stringFromDate:timerDate];
    [self.recordMessageButton setTitle:[NSString stringWithFormat: @"Recording...%@", timeString] forState:UIControlStateHighlighted];
}

- (void)uploadAudio
{
    [self enableAvatarButton:NO];
    self.activityLabel.text = @"Uploading";
    [self showActivityIndicator];
    
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
                    [self queryAudio];
                }
            }];
        }
    } progressBlock:^(int percentDone) {
        [self showActivityIndicator];
        self.activityLabel.text = [NSString stringWithFormat: @"Uploading %i%%", percentDone];
    }];
}

- (void)queryAudio
{
    [self showActivityIndicator];
    self.activityLabel.text = @"Querying";
    [self enableAvatarButton:NO];
    
    PFQuery *query = [PFQuery queryWithClassName:kHEREAudioClassKey];
    [query whereKey:kHEREAudioBeaconKey equalTo:[PFObject objectWithoutDataWithClassName:kHEREBeaconClassKey objectId:self.beacon.parseId]];
    [query whereKey:kHEREAudioUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"queried audio records at location %@, count: %tu", self.beacon.name, [objects count]);
            self.audioRecords = [objects mutableCopy];
            PFObject *audio = [objects lastObject];
            if (audio) {
                self.audioData = [[NSMutableData alloc] init];
                [self downloadAudio:audio];
            }
            else [self enableAvatarButton:YES];
        }
        else {
            NSLog(@"error when querying audio in home view controller: %@", error.description);
        }
    }];
}

- (void)downloadAudio:(PFObject *)audio
{
    NSLog(@"Download audio from parse");
    PFFile *audioFile = audio[kHEREAudioFileKey];
    [audioFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"Error downloading audio: %@%%", error.description);
            [self downloadAudio:audio];
        }
        else {
            [self hideActivityIndicator];
            self.activityLabel.text = nil;
            [self enableAvatarButton:YES];
            self.audioData = data;
        }
    } progressBlock:^(int percentDone) {
        self.activityLabel.text = [NSString stringWithFormat:@"Downloading %i%%", percentDone];
    }];
}

- (void)enableAvatarButton:(BOOL)state
{
    self.avatarButton.highlighted = !state;
    self.avatarButton.enabled = state;
    self.activityView.hidden = state;
}

- (void)highlightButton:(UIButton *)button {
    button.highlighted = YES;
}

- (void)triggerBeacon
{
    NSString *parseId = [[NSUserDefaults standardUserDefaults] objectForKey:kHEREBeaconTriggeredKey];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"parseId == %@", parseId];
    HEREBeacon *beacon = [[self.beacons filteredArrayUsingPredicate:pred] firstObject];
    if (beacon) [self updateBeacon:beacon];
}

- (void)updateBeacon:(HEREBeacon *)beacon
{
    self.beacon = beacon;
    self.locationLabel.text = beacon.name;
    [self queryAudio];
}

- (void)updateBeacons
{
    HEREFactory *factory = [[HEREFactory alloc] init];
    [factory queryBeacons];
    self.beacons = [factory returnBeacons];
}

//- (void)adjustActivityLabelWidth
//{
//    float widthIs = [self.activityLabel.text boundingRectWithSize:self.activityLabel.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : self.activityLabel.font } context:nil].size.width;
//    self.activityLabel.frame.size = CGSizeMake(widthIs, <#CGFloat height#>)
//}

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

#pragma mark - AVAudioPlayer Delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self enableAvatarButton:YES];
    [self hideActivityIndicator];
    self.activityLabel.text = nil;
}

@end
