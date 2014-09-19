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
#import "AudioPlayerView.h"
#import "ViewMessage.h"
#import "MBProgressHUD.h"
#import "Message+API.h"
#import "HERECoreDataHelper.h"
#import <SVPullToRefresh.h>
#import "APIManager.h"

@interface HEREBeaconsMessagesTableViewController () <MBProgressHUDDelegate, NSFetchedResultsControllerDelegate>
{
    NSTimer *timer;
    NSTimeInterval timeInterval;
    NSDate *startDate;
}
@property (strong, nonatomic) AudioPlayerView *activePlayerView;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (nonatomic) BOOL isRecording;
@property (strong, nonatomic) JSQMessagesComposerTextView *textView;
@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) NSData *audioData;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSUInteger totalPages;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;

@end

@implementation HEREBeaconsMessagesTableViewController
static const NSUInteger kItemPerView = 6;

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

-(void)setLocation:(Location *)location
{
    _location = location;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kHEREMessageClassKey];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"location == %@", location];
    request.predicate = predicate;
    request.fetchBatchSize = 10;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:kHEREAPICreatedAtKey
                                                              ascending:NO]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:location.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    [self.fetchedResultsController performFetch:NULL];
}

- (NSUInteger)index
{
    if (!_index) {
        _index = 0;
    }
    return _index;
}

- (NSUInteger)totalPages
{
    if (!_totalPages) {
        _totalPages = ([[self.fetchedResultsController fetchedObjects] count] / kItemPerView) + 1;
    }
    return _totalPages;
}

- (AVAudioRecorder *)audioRecorder
{
    if (!_audioRecorder) {
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
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        [_audioRecorder prepareToRecord];
    }
    return _audioRecorder;
}

- (MBProgressHUD *)HUD
{
    if (!_HUD) {
        _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _HUD.delegate = self;
        [self.navigationController.view addSubview:_HUD];
    }
    return _HUD;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.location.name;
    
    self.sender = [User username];
    
    self.outgoingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    self.incomingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingVideoOverlayViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingVideoOverlayViewSize = CGSizeZero;
    
    self.isRecording = NO;
    self.inputToolbar.contentView.leftBarButtonItem = [self accessoryButtonItem];
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCollectionTapRecognizer:)];
    [self.collectionView addGestureRecognizer:tapRecognizer];
    self.textView = self.inputToolbar.contentView.textView;
    
    [self loadMessages];
    
    [APIManager fetchMessagesForLocation:self.location];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.recordButton addTarget:self action:@selector(holdDownButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(holdDownButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [self.recordButton addTarget:self action:@selector(holdDownButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(holdDownDragOutside:) forControlEvents:UIControlEventTouchDragExit];
    [self.recordButton addTarget:self action:@selector(holdDownDragInside:) forControlEvents:UIControlEventTouchDragEnter];

}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    if (self.collectionView.pullToRefreshView == nil) {
        [self.collectionView addPullToRefreshWithActionHandler:^{
            [self insertMessagesOnTop];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)viewDidUnload
//{
//    self.fetchedResultsController = nil;
//}

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
    
    self.HUD.mode = MBProgressHUDModeCustomView;
    self.HUD.square = YES;
    [self.HUD show:YES];
    
    [self normalHUD];
    
    [self recordAudio];
}

- (void)holdDownButtonTouchUpOutside:(UIButton *)button
{
    [self resetRecordButton];
    [self cancelRecordAudio];
    [self.HUD hide:YES];
}

- (void)holdDownButtonTouchUpInside:(UIButton *)button
{
    [self resetRecordButton];
    [self finishRecordAudio];
    [self.HUD hide:YES];
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
    self.HUD.labelText = @"Slide up to cancel";
    self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RecordingBkg"]];
    self.HUD.labelColor = [UIColor whiteColor];
}

- (void)cancelHUD
{
    self.HUD.labelText = @"Release and cancel";
    self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RecordCancel"]];
    self.HUD.labelColor = [UIColor redColor];
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
    [self cancelRecordAudio];
    
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
    [self.audioRecorder stop];
    [timer invalidate];
    timer = nil;
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
    ViewMessage *audioMessage = [[ViewMessage alloc] initWithAudio:self.audioData sender:[User username] date:currentDate];
    audioMessage.audioLength = [Message durationFromAudioFileURL:documentsURL];
    [self.messages addObject:audioMessage];
    [APIManager fetchMessagesForLocation:self.location];
    [self finishSendingMessage];
}

- (void)uploadAudio
{
    [APIManager pushAudioMessageToServer:self.audioData Location:self.location];
}

- (void)playAudio:(NSData *)data
{
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    self.audioPlayer.delegate = self;
    [self.audioPlayer play];
}

- (void)playAudioWithUrl:(NSURL *)url
{
    NSError *error = nil;
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    self.audioPlayer.delegate = self;
    [self.audioPlayer play];
}

- (JSQMessage *)jsqMessageFromCoreData:(Message *)coreDataMessage
{
    JSQMessage *message = nil;
    if (coreDataMessage.text) {
        message = [[JSQMessage alloc] initWithText:coreDataMessage.text sender:coreDataMessage.username date:coreDataMessage.createdAt];
    }
    else if (coreDataMessage.audioFilePath) {
        message = [[JSQMessage alloc] initWithAudioURL:[NSURL URLWithString:coreDataMessage.audioFilePath] sender:coreDataMessage.username date:coreDataMessage.createdAt];
    }
    return message;
}

- (void)loadMessages
{
    NSUInteger startIndex = self.index * kItemPerView;
    
    NSArray *faultedMessages = [self.fetchedResultsController fetchedObjects];
    NSUInteger count = MIN([faultedMessages count] - startIndex, kItemPerView);
    
    NSArray *messagesForView = [faultedMessages subarrayWithRange:NSMakeRange(startIndex, count)];
    
    for (Message *coreDataMessage in messagesForView) {
        ViewMessage *message = [[ViewMessage alloc] initWithCoreDataMessage:coreDataMessage];
        [self.messages insertObject:message atIndex:0];
    }
    
    self.index++;
}

- (void)insertMessagesOnTop
{
    if (self.index != self.totalPages) {
        [self loadMessages];
        [self.collectionView reloadData];
    }
    [self.collectionView.pullToRefreshView stopAnimating];
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
    if ([User username]) {
        
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
        
        JSQMessage *message = [[JSQMessage alloc] initWithText:text sender:sender date:date];
        [self.messages addObject:message];
        
        [self finishSendingMessage];
        
        [APIManager pushTextMessageToServer:text Location:self.location];
    }
    else {
        [self performSegueWithIdentifier:@"MessagesToSetUsername" sender:self];
    }
}

- (void)didPressAccessoryButton:(UIButton *)sensder
{
    NSLog(@"AccessoryButton pressed!");
    
    if ([User username]) {
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
    else {
        [self performSegueWithIdentifier:@"MessagesToSetUsername" sender:self];
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
    return nil;
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
    return nil;
}

- (UIView *)collectionView:(JSQMessagesCollectionView *)collectionView outgoingVideoOverlayViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (UIView *)collectionView:(JSQMessagesCollectionView *)collectionView viewForAudioPlayerViewAtIndexPath:(NSIndexPath *)indexPath
{
    ViewMessage *message = self.messages[indexPath.item];
    AudioPlayerView *player = [AudioPlayerView new];
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
    ViewMessage *message = [self.messages objectAtIndex:indexPath.item];
    CGFloat width = ([message.audioLength floatValue] / 60.0) * 100.0;
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
    AudioPlayerView *player = (AudioPlayerView *)incomingAudioCell.playerView;
    
    if (self.activePlayerView == player && [self.audioPlayer isPlaying]) {
        [self.activePlayerView stopAnimation];
        [self.audioPlayer stop];
        self.audioPlayer = nil;
        return;
    }
    self.activePlayerView = player;
    [player startAnimation];
    [self playAudio:audioData];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAudioForURL:(NSURL *)audioURL atIndexPath:(NSIndexPath *)indexPath
{
    AudioPlayerView *previousPlayerView = self.activePlayerView;
    [previousPlayerView stopAnimation];
    
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    self.activePlayerView = nil;
    
    JSQMessagesCollectionViewAudioCellIncoming *incomingAudioCell = (JSQMessagesCollectionViewAudioCellIncoming *)[collectionView cellForItemAtIndexPath:indexPath];
    AudioPlayerView *player = (AudioPlayerView *)incomingAudioCell.playerView;
    ViewMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if (!previousPlayerView || previousPlayerView != player) {
        self.activePlayerView = player;
        [player startAnimation];
        [self playAudioWithUrl:message.sourceURL];
    }
}

#pragma mark - AVAudioPlayer Delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.activePlayerView stopAnimation];
    self.activePlayerView = nil;
}

#pragma mark - NSFetchedResultsController Delegate
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert) {
        NSLog(@"didAddObject, object: %@", anObject);
        Message *coreDataMessage = anObject;
        if (coreDataMessage.username && ![coreDataMessage.username isEqualToString:[User username]]) {
            if (coreDataMessage.text || coreDataMessage.localURL) {
                ViewMessage *message = [[ViewMessage alloc] initWithCoreDataMessage:coreDataMessage];
                [self.messages addObject:message];
                [self finishReceivingMessage];
            }
        }
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"NSFetchedResultsController will change content");

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSArray *sections = [controller sections];
    id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:0];
    
    NSLog(@"NSFetchedResultsController did change content");
    NSLog(@"NSFetchedResultsController object count: %tu", [sectionInfo numberOfObjects]);
}


#pragma mark - unwind segue

- (IBAction)doSetUsername:(UIStoryboardSegue *)segue
{
    self.sender = [User username];
}

@end
