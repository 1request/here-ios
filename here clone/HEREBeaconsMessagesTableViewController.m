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

@interface HEREBeaconsMessagesTableViewController () {
    NSMutableArray *beacons;
    HEREFactory *factory;
}
@property (nonatomic) BOOL isRecording;
@property (strong, nonatomic) JSQMessagesComposerTextView *textView;
@property (strong, nonatomic) UIButton *recordButton;
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    factory = [[HEREFactory alloc] init];
    beacons = [factory returnBeacons];

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
}

- (void)holdDownButtonTouchUpOutside:(UIButton *)button
{
    NSLog(@"didTouchUpOutside");
    [button setTitle:@"Hold and speak" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
}

- (void)holdDownButtonTouchUpInside:(UIButton *)button
{
    NSLog(@"didTouchUpInside");
    [button setTitle:@"Hold and speak" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    
}

- (void)holdDownDragOutside:(UIButton *)button
{
    button.backgroundColor = [UIColor lightGrayColor];
    [button setTitle:@"Release and cancel" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    NSLog(@"did drag outside, pause recording");
}

- (void)holdDownDragInside:(UIButton *)button
{
    button.backgroundColor = [UIColor lightGrayColor];
    NSLog(@"did drag inside, resume recording");
    
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

- (void)didPressAccessoryButton:(UIButton *)sender
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
    
    if ([msg.sender isEqualToString:self.sender]) {
        cell.textView.textColor = [UIColor blackColor];
    }
    else {
        cell.textView.textColor = [UIColor whiteColor];
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    
    return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

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

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

@end
