//
//  HEREAudioPlayerView.h
//  here clone
//
//  Created by Joseph Cheung on 28/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

@class JSQMessage;

@interface HEREAudioPlayerView : UIView

@property (strong, nonatomic) JSQMessage *message;
@property (assign, nonatomic) BOOL incomingMessage;

- (void)startAnimation;
- (void)stopAnimation;
- (BOOL)isAnimating;

@end
