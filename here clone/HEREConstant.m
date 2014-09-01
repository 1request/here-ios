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
#pragma mark - Location API
NSString *const kHEREAPILocationsUrl            = @"http://here.zuohaisu.cn/api/locations";
NSString *const kHEREAPILocationIdGETKey        = @"id";
NSString *const kHEREAPILocationIdPOSTKey       = @"locId";
NSString *const kHEREAPILocationAccessIdKey     = @"accessId";
NSString *const kHEREAPILocationLatitudeKey     = @"lat";
NSString *const kHEREAPILocationLongitudeKey    = @"lng";
NSString *const kHEREAPILocationMacAddressKey   = @"macAddr";
NSString *const kHEREAPILocationNameKey         = @"name";
NSString *const kHEREAPILocationUUIDKey         = @"uuid";
NSString *const kHEREAPILocationMajorKey        = @"major";
NSString *const kHEREAPILocationMinorKey        = @"minor";

#pragma mark - User API

#pragma mark - Message API
NSString *const kHEREAPIMessagesUrl         = @"http://here.zuohaisu.cn/api/messages";
NSString *const kHEREAPIAudioFileKey        = @"audio";
NSString *const kHEREAPIDeviceIdKey         = @"deviceId";
NSString *const kHEREAPIDeviceTypeKey       = @"deviceType";
NSString *const kHEREAPIBoundaryKey         = @"testboundaryblablabla";

#pragma mark - Core Data Classes
NSString *const kHERELocationClassKey       = @"Location";
NSString *const kHEREMessageClassKey        = @"Message";

@end
