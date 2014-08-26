//
//  HEREUploadHelper.h
//  here clone
//
//  Created by Joseph Cheung on 25/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEREBeacon.h"

@protocol uploaderDelegate <NSObject>

- (void)didUploadAudio;

@end


@interface HEREUploadHelper : NSObject

@property (weak, nonatomic) id <uploaderDelegate> delegate;
- (void)uploadAudio:(NSData *)data Beacon:(HEREBeacon *)beacon;

@end
