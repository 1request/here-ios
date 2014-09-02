//
//  HEREAudioHelper.m
//  here clone
//
//  Created by Joseph Cheung on 29/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREAudioHelper.h"
#import <AVFoundation/AVFoundation.h>
@implementation HEREAudioHelper

+ (CGFloat)durationFromAudioFileURL:(NSURL *)url
{
    NSParameterAssert(url != nil);
    
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    CMTime audioDuration = audioAsset.duration;
    return CMTimeGetSeconds(audioDuration);
}

@end
