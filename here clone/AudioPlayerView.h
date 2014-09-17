//
//  AudioPlayerView.h
//  Here
//
//  Created by Joseph Cheung on 13/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewMessage.h"

@interface AudioPlayerView : UIView

@property (strong, nonatomic) ViewMessage *message;
@property (assign, nonatomic) BOOL incomingMessage;

- (void)startAnimation;
- (void)stopAnimation;
- (BOOL)isAnimating;

@end
