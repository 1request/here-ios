//
//  HEREConstant.h
//  here clone
//
//  Created by Joseph Cheung on 11/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEREConstant : NSObject

#pragma mark - Beacon Class
extern NSString *const kHEREBeaconClassKey;
extern NSString *const kHEREBeaconUserKey;
extern NSString *const kHEREBeaconUUIDKey;
extern NSString *const kHEREBeaconMajorKey;
extern NSString *const kHEREBeaconMinorKey;
extern NSString *const kHEREBeaconNameKey;
extern NSString *const kHEREBeaconParseIdKey;
extern NSString *const kHEREBeaconTriggeredKey;

#pragma mark - Audio Class
extern NSString *const kHEREAudioClassKey;
extern NSString *const kHEREAudioUserKey;
extern NSString *const kHEREAudioBeaconKey;
extern NSString *const kHEREAudioFileKey;
extern NSString *const kHEREAudioIsReadKey;

#pragma mark - API
extern NSString *const kHEREAPIMessagesUrl;
extern NSString *const kHEREAPILocationsUrl;
extern NSString *const kHEREAPILocationIdKey;
extern NSString *const kHEREAPIAudioFileKey;
extern NSString *const kHEREAPIUUIDKey;
extern NSString *const kHEREAPIMajorKey;
extern NSString *const kHEREAPIMinorKey;
extern NSString *const kHEREAPIDeviceIdKey;
extern NSString *const kHEREAPIDeviceTypeKey;
extern NSString *const kHEREAPIBoundaryKey;

#pragma mark - Core Data Classes
extern NSString *const kHERELocationClassKey;
extern NSString *const kHEREMessageClassKey;

@end
