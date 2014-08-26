//
//  HEREUploadHelper.h
//  here clone
//
//  Created by Joseph Cheung on 25/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEREBeacon.h"

@interface HEREUploadHelper : NSObject

+ (void)uploadAudio:(NSData *)data Beacon:(HEREBeacon *)beacon;

@end
