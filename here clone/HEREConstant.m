//
//  HEREConstant.m
//  here clone
//
//  Created by Joseph Cheung on 11/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREConstant.h"

@implementation HEREConstant

#pragma mark - Beacon Class
NSString *const kHEREBeaconClassKey         = @"Beacon";
NSString *const kHEREBeaconUserKey          = @"user";
NSString *const kHEREBeaconUUIDKey          = @"uuid";
NSString *const kHEREBeaconMajorKey         = @"major";
NSString *const kHEREBeaconMinorKey         = @"minor";
NSString *const kHEREBeaconNameKey          = @"name";
NSString *const kHEREBeaconParseIdKey       = @"parseId";
NSString *const kHEREBeaconTriggeredKey     = @"beaconTriggered";

#pragma mark - Audio Class
NSString *const kHEREAudioClassKey          = @"Audio";
NSString *const kHEREAudioUserKey           = @"user";
NSString *const kHEREAudioBeaconKey     	= @"beacon";
NSString *const kHEREAudioFileKey       	= @"audioFile";
NSString *const kHEREAudioIsReadKey     	= @"isRead";

#pragma mark - API
NSString *const kHEREAPIMessagesUrl         = @"http://here.zuohaisu.cn/api/messages";
NSString *const kHEREAPILocationsUrl        = @"http://here.zuohaisu.cn/api/locations";
NSString *const kHEREAPILocationIdKey       = @"locId";
NSString *const kHEREAPIAudioFileKey        = @"audio";
NSString *const kHEREAPIUUIDKey             = @"uuid";
NSString *const kHEREAPIMajorKey            = @"major";
NSString *const kHEREAPIMinorKey            = @"minor";
NSString *const kHEREAPIDeviceIdKey         = @"deviceId";
NSString *const kHEREAPIDeviceTypeKey       = @"deviceType";
NSString *const kHEREAPIBoundaryKey         = @"testboundaryblablabla";

#pragma mark - Core Data Classes
NSString *const kHERELocationClassKey       = @"Location";
NSString *const kHEREMessageClassKey        = @"Message";

@end
