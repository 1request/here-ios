//
//  AudioPlayerView.m
//  Here
//
//  Created by Joseph Cheung on 13/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "AudioPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayerView ()

@property (strong, nonatomic) UILabel *durationLabel;
@property (strong, nonatomic) UIImageView *animationContainer;

@end

@implementation AudioPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.incomingMessage = YES;
        self.durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.durationLabel.textAlignment = NSTextAlignmentCenter;
        self.durationLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.durationLabel];
        
        self.animationContainer = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"audio_normal"] highlightedImage:[UIImage imageNamed:@"audio_press"]];
        self.animationContainer.frame = CGRectZero;
        self.animationContainer.userInteractionEnabled = YES;
        self.animationContainer.animationImages = @[[UIImage imageNamed:@"audio_play_0"],
                                                    [UIImage imageNamed:@"audio_play_1"],
                                                    [UIImage imageNamed:@"audio_play_2"],
                                                    [UIImage imageNamed:@"audio_normal"]];
        self.animationContainer.animationDuration = 1.f;
        [self addSubview:self.animationContainer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.incomingMessage) {
        self.durationLabel.frame = CGRectMake(30, (CGRectGetHeight(self.bounds) - CGRectGetHeight(self.durationLabel.bounds)) / 2, CGRectGetWidth(self.durationLabel.bounds), CGRectGetHeight(self.durationLabel.bounds));
        self.animationContainer.frame = CGRectMake(CGRectGetMaxX(self.durationLabel.frame), CGRectGetMinY(self.durationLabel.frame) - 10, 34, 34);
    }
    else {
        self.animationContainer.frame = CGRectMake(10, (CGRectGetHeight(self.bounds) - 34) / 2, 34, 34);
        self.durationLabel.frame = CGRectMake(CGRectGetMaxX(self.animationContainer.frame), (CGRectGetHeight(self.bounds) - CGRectGetHeight(self.durationLabel.bounds)) / 2, CGRectGetWidth(self.durationLabel.bounds), CGRectGetHeight(self.durationLabel.bounds));
    }
}

- (void)setMessage:(ViewMessage *)message
{
    self.durationLabel.text = [NSString stringWithFormat:@"%@", message.audioLength];
    [self.durationLabel sizeToFit];
    
    _message = message;
}

- (void)setIncomingMessage:(BOOL)incomingMessage
{
    if (_incomingMessage != incomingMessage) {
        
        self.animationContainer.transform = incomingMessage ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
        
        _incomingMessage = incomingMessage;
    }
}

- (void)startAnimation
{
    [self.animationContainer startAnimating];
}

- (void)stopAnimation
{
    [self.animationContainer stopAnimating];
}

- (BOOL)isAnimating
{
    return [self.animationContainer isAnimating];
}

@end
