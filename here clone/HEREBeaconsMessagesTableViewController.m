//
//  HEREBeaconsMessagesTableViewController.m
//  here clone
//
//  Created by Joseph Cheung on 11/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREBeaconsMessagesTableViewController.h"
#import "HEREFactory.h"
#import <Parse/Parse.h>
#import "UIViewController+HEREMenu.h"
#import "JSQMessagesActivityIndicatorView.h"
#import "HEREAudioPlayerView.h"
#import "HEREAPIHelper.h"
#import "HEREAudioHelper.h"
#import "MBProgressHUD.h"

@interface HEREBeaconsMessagesTableViewController () <MBProgressHUDDelegate>
{
    NSTimer *timer;
    NSTimeInterval timeInterval;
    NSDate *startDate;
    HEREAudioPlayerView *activePlayerView;
    MBProgressHUD *HUD;
}

@property (nonatomic) BOOL isRecording;
@property (strong, nonatomic) JSQMessagesComposerTextView *textView;
@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) HEREAPIHelper *apiHelper;
@property (strong, nonatomic) NSData *audioData;

@end

@implementation HEREBeaconsMessagesTableViewController

#pragma mark - Instantiation

- (NSMutableArray *)messages
{
    if (!_messages) {
        _messages = [[NSMutableArray alloc] init];
    }
    return _messages;
}

- (UIButton *)recordButton
{
    if (!_recordButton) {
        
        CGFloat cornerRadius = 6.0f;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"Hold and speak" forState:UIControlStateNormal];
        [button setTitle:@"Release and finish" forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        button.frame = self.inputToolbar.contentView.textView.frame;
        button.backgroundColor = [UIColor whiteColor];
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        button.layer.borderWidth = 0.5f;
        button.layer.cornerRadius = cornerRadius;

        _recordButton = button;
    }
    return _recordButton;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.titleText;
    
    self.sender = [[PFUser currentUser] username];
    
    self.outgoingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    self.incomingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleGreenColor]];
    self.isRecording = NO;
    self.inputToolbar.contentView.leftBarButtonItem = [self accessoryButtonItem];
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCollectionTapRecognizer:)];
    [self.collectionView addGestureRecognizer:tapRecognizer];
    self.textView = self.inputToolbar.contentView.textView;

    [self.recordButton addTarget:self action:@selector(holdDownButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(holdDownButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [self.recordButton addTarget:self action:@selector(holdDownButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(holdDownDragOutside:) forControlEvents:UIControlEventTouchDragExit];
    [self.recordButton addTarget:self action:@selector(holdDownDragInside:) forControlEvents:UIControlEventTouchDragEnter];
    
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
    self.apiHelper = [[HEREAPIHelper alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - helper methods

- (UIButton *)accessoryButtonItem
{
    UIImage *image = nil;
    if (!self.isRecording) image = [UIImage imageNamed:@"mic.png"];
    else image = [UIImage imageNamed:@"left_arrow.png"];
    
    UIImage *normal = [image jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
    UIImage *highlighted = [image jsq_imageMaskedWithColor:[UIColor darkGrayColor]];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setImage:normal forState:UIControlStateNormal];
    [button setImage:highlighted forState:UIControlStateHighlighted];
    
    button.contentMode = UIViewContentModeScaleAspectFit;
    button.backgroundColor = [UIColor clearColor];
    button.tintColor = [UIColor lightGrayColor];
    
    return button;
}

- (void)holdDownButtonTouchDown:(UIButton *)button
{
    [button setTitle:@"Release and finish" forState:UIControlStateNormal];
    
    button.backgroundColor = [UIColor lightGrayColor];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    
    [self.navigationController.view addSubview:HUD];
    
    HUD.delegate = self;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.square = YES;
    [HUD show:YES];
    
    [self normalHUD];
    
    [self recordAudio];
}

- (void)holdDownButtonTouchUpOutside:(UIButton *)button
{
    [self resetRecordButton];
    [self cancelRecordAudio];
    [HUD hide:YES];
}

- (void)holdDownButtonTouchUpInside:(UIButton *)button
{
    [self resetRecordButton];
    [self finishRecordAudio];
    [HUD hide:YES];
}

- (void)holdDownDragOutside:(UIButton *)button
{
    [self cancelHUD];
}

- (void)holdDownDragInside:(UIButton *)button
{
    [self normalHUD];
}

- (void)normalHUD
{
    HUD.labelText = @"Slide up to cancel";
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RecordingBkg"]];
    HUD.labelColor = [UIColor whiteColor];
}

- (void)cancelHUD
{
    HUD.labelText = @"Release and cancel";
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RecordCancel"]];
    HUD.labelColor = [UIColor redColor];
}

- (void)resetRecordButton
{
    [self.recordButton setTitle:@"Hold and speak" forState:UIControlStateNormal];
    [self.recordButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.recordButton.backgroundColor = [UIColor whiteColor];
}

- (void)recordAudio
{
    if (self.audioPlayer.playing) {
        [self.audioPlayer stop];
    }
    
    if (!self.audioRecorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        [self.audioRecorder record];
        
        startDate = [NSDate date];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    }
    else {
        [self.audioRecorder pause];
    }
}

- (void)updateTimer
{
    NSDate *currentDate = [NSDate date];
    
    timeInterval = [currentDate timeIntervalSinceDate:startDate];
}

- (void)finishRecordAudio
{
    [self.audioRecorder stop];
    [timer invalidate];
    timer = nil;
    
    if (timeInterval > 2) {
        NSData *audioData = [NSData dataWithContentsOfURL:self.audioRecorder.url];
        self.audioData = audioData;
        [self saveAudio];
        [self uploadAudio];
    }
    else {
        NSLog(@"Record is too short");
    }
    
    timeInterval = 0;
}

- (void)cancelRecordAudio
{
    NSLog(@"cancel record audio");
}

- (void)saveAudio
{
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyy-mm-dd HH-mm-ss"];
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    documentsURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", dateString]];
    [self.audioData writeToURL:documentsURL atomically:YES];
    JSQMessage *audioMessage = [JSQMessage messageWithAudioURL:documentsURL sender:self.sender];
    audioMessage.sourceURL = documentsURL;
    [self.messages addObject:audioMessage];
    [self finishSendingMessage];
}

- (void)uploadAudio
{
    NSLog(@"upload audio to server");
}

- (void)playAudio:(NSData *)data
{
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    self.audioPlayer.delegate = self;
    [self.audioPlayer play];
}

#pragma mark - navigation
- (void) handleCollectionTapRecognizer:(UITapGestureRecognizer*)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        if([self.inputToolbar.contentView.textView isFirstResponder])
            [self.inputToolbar.contentView.textView resignFirstResponder];
    }
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                    sender:(NSString *)sender
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithText:text sender:sender date:date];
    [self.messages addObject:message];
    
    [self finishSendingMessage];
}

- (void)didPressAccessoryButton:(UIButton *)sensder
{
    NSLog(@"AccessoryButton pressed!");
    /**
     *  Accessory button has no default functionality, yet.
     */
    self.isRecording = !self.isRecording;
    self.inputToolbar.contentView.leftBarButtonItem = [self accessoryButtonItem];
    self.inputToolbar.contentView.textView.text = nil;
    
    if (self.isRecording) {
        [self.inputToolbar addSubview:self.recordButton];
        if ([self.inputToolbar.contentView.textView isFirstResponder]) [self.inputToolbar.contentView.textView resignFirstResponder ];
    }
    else {
        [self.recordButton removeFromSuperview];
        [self.inputToolbar.contentView.textView becomeFirstResponder];
    }
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     */
    
    /**
     *  Reuse created bubble images, but create new imageView to add to each cell
     *  Otherwise, each cell would be referencing the same imageView and bubbles would disappear from cells
     */
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.sender isEqualToString:self.sender]) {
        return [[UIImageView alloc] initWithImage:self.outgoingBubbleImageView.image
                                 highlightedImage:self.outgoingBubbleImageView.highlightedImage];
    }
    
    return [[UIImageView alloc] initWithImage:self.incomingBubbleImageView.image
                             highlightedImage:self.incomingBubbleImageView.highlightedImage];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Reuse created avatar images, but create new imageView to add to each cell
     *  Otherwise, each cell would be referencing the same imageView and avatars would disappear from cells
     *
     *  Note: these images will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    UIImage *avatarImage = [self.avatars objectForKey:message.sender];
    return [[UIImageView alloc] initWithImage:avatarImage];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.sender isEqualToString:self.sender]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage sender] isEqualToString:message.sender]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.sender];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (UIView *)collectionView:(JSQMessagesCollectionView *)collectionView viewForVideoOverlayViewAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want overlay view for incoming video message.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingVideoOverlayViewSize = CGSizeZero;
     */
    
    /**
     *  You should create new view to add to each cell
     *  Otherwise, each cell would be referencing the same view.
     *
     *  Note: these views will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingVideoOverlayViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    
    UIImageView *incomingVideoOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"demo_play_button_in"] highlightedImage:nil];
    return incomingVideoOverlayView;
}

- (UIView *)collectionView:(JSQMessagesCollectionView *)collectionView outgoingVideoOverlayViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want overlay view for outgoing video message.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.outgoingVideoOverlayViewSize = CGSizeZero;
     */
    
    /**
     *  You should create new view to add to each cell
     *  Otherwise, each cell would be referencing the same view.
     *
     *  Note: these views will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.outgoingVideoOverlayViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    UIImageView *outgoingVideoOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"demo_play_button_out"] highlightedImage:nil];
    return outgoingVideoOverlayView;
}

- (UIView *)collectionView:(JSQMessagesCollectionView *)collectionView viewForAudioPlayerViewAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.messages[indexPath.item];
    HEREAudioPlayerView *player = [HEREAudioPlayerView new];
    player.message = message;
    player.incomingMessage = ![message.sender isEqual:self.sender];
    
    return player;
}

- (UIView <JSQMessagesActivityIndicator> *)collectionView:(JSQMessagesCollectionView *)collectionView viewForPhotoActivityIndicatorViewAtIndexPath:(NSIndexPath *)indexPath
{
    return [JSQMessagesActivityIndicatorView new];
}

- (UIView <JSQMessagesActivityIndicator> *)collectionView:(JSQMessagesCollectionView *)collectionView viewForVideoActivityIndicatorViewAtIndexPath:(NSIndexPath *)indexPath
{
    return [JSQMessagesActivityIndicatorView new];
}

- (UIView<JSQMessagesActivityIndicator> *)collectionView:(JSQMessagesCollectionView *)collectionView viewForAudioActivityIndicatorViewAtIndexPath:(NSIndexPath *)indexPath
{
    return [JSQMessagesActivityIndicatorView new];
}

- (CGSize)collectionView:(JSQMessagesCollectionView *)collectionView sizeForAudioPlayerViewAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    CGFloat duration = [HEREAudioHelper durationFromAudioFileURL:message.sourceURL];
    CGFloat width = (duration / 60.0) * 100.0;
    return CGSizeMake(100 + width, 40);
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
  wantsThumbnailForURL:(NSURL *)sourceURL thumbnailImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
       completionBlock:(JSQMessagesCollectionViewDataSourceCompletionBlock)completionBlock {
    
    JSQMessage *message = self.messages[indexPath.item];
    BOOL isOutgoingMessage = [[message sender] isEqualToString:self.sender];
    
    /**
     *  Here you can download images from the Internet.
     */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *thumbnail = nil;
        
        if (message.type == JSQMessageRemotePhoto) {
            NSData *imageData = [NSData dataWithContentsOfURL:sourceURL];
            
            if (imageData) {
                UIImage *sourceImage = [UIImage imageWithData:imageData];
                message.sourceImage = sourceImage;
                
                /**
                 *  Before the image display you should generate a thumbnail to improve performance.
                 */
                CGFloat screenScale = [[UIScreen mainScreen] scale];
                CGSize mediaImageViewSize = isOutgoingMessage
                ? collectionView.collectionViewLayout.outgoingThumbnailImageSize
                : collectionView.collectionViewLayout.incomingThumbnailImageSize;
                
                CGRect contextBounds = CGRectMake(0.f, 0.f, mediaImageViewSize.width * screenScale, mediaImageViewSize.height * screenScale);
                
                UIGraphicsBeginImageContext(contextBounds.size);
                [sourceImage drawInRect:contextBounds];
                thumbnail = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                message.thumbnailImage = thumbnail;
                message.type = JSQMessagePhoto;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(thumbnail);
                });
            }
            else {
                NSLog(@"Error, Can not download image for URL:%@", message.sourceURL);
            }
        }
        else if (message.type == JSQMessageRemoteVideo) {
            
            /**
             *  Generate thumbnails from remote url.
             */
            UIImage *remoteThumbnail = [JSQMessagesThumbnailFactory thumbnailFromVideoURL:sourceURL];
            
            /**
             *  May not support this format or video encoding is incorrect or network error.
             */
            if (!remoteThumbnail) {
                NSLog(@"Error, Can not generate thumbnail for URL: %@", sourceURL);
            }
            else {
                thumbnail = remoteThumbnail;
                
                message.videoThumbnail = remoteThumbnail;
                message.videoThumbnailPlaceholder = nil;
                
                /**
                 *  Change the message type, so next time we will not need to ask the data source method.
                 */
                message.type = JSQMessageVideo;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(thumbnail);
                });
            }
        }
    });
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if (cell.textView) {
        if ([msg.sender isEqualToString:self.sender]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}


#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage sender] isEqualToString:self.sender]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage sender] isEqualToString:[currentMessage sender]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapPhoto:(UIImageView *)imageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapVideoForURL:(NSURL *)videoURL atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAudio:(NSData *)audioData atIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewAudioCellIncoming *incomingAudioCell = (JSQMessagesCollectionViewAudioCellIncoming *)[collectionView cellForItemAtIndexPath:indexPath];
    HEREAudioPlayerView *player = (HEREAudioPlayerView *)incomingAudioCell.playerView;
    
    if (activePlayerView == player && [self.audioPlayer isPlaying]) {
        [activePlayerView stopAnimation];
        [self.audioPlayer stop];
        self.audioPlayer = nil;
        return;
    }
    activePlayerView = player;
    [player startAnimation];
    [self playAudio:audioData];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAudioForURL:(NSURL *)audioURL atIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewAudioCellIncoming *incomingAudioCell = (JSQMessagesCollectionViewAudioCellIncoming *)[collectionView cellForItemAtIndexPath:indexPath];
    HEREAudioPlayerView *player = (HEREAudioPlayerView *)incomingAudioCell.playerView;
    if ([player isAnimating]) {
        [player stopAnimation];
    }
    else {
        [player startAnimation];
    }
}

#pragma mark - AVAudioPlayer Delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [activePlayerView stopAnimation];
    activePlayerView = nil;
}

@end
