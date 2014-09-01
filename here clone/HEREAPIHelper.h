//
//  HEREAPIHelper.h
//  here clone
//
//  Created by Joseph Cheung on 25/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEREBeacon.h"

@protocol apiDelegate <NSObject>
@optional
- (void)didUploadAudio;
- (void)didUpdateLocation;
@end


@interface HEREAPIHelper : NSObject

@property (weak, nonatomic) id <apiDelegate> delegate;
- (void)uploadAudio:(NSData *)data Beacon:(HEREBeacon *)beacon;
- (void)updateLocation:(NSDictionary *)data;
@end
