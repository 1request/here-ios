//
//  User.m
//  here clone
//
//  Created by Harry Ng on 2/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "User.h"
#import "HEREAPIHelper.h"

@implementation User

+ (NSString *)username
{
    return @"harry";
}

+ (void)currentInstallation
{
    [HEREAPIHelper updateUser:nil username:nil];
}

+ (void)setUser:(NSString *)name
{
    [HEREAPIHelper updateUser:nil username:name];
}

+ (void)setDeviceTokenFromData:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [HEREAPIHelper updateUser:token username:nil];
}

@end
