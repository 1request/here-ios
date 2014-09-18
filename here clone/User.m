//
//  User.m
//  here clone
//
//  Created by Harry Ng on 2/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "User.h"
#import "APIManager.h"

@implementation User

+ (NSString *)username
{
    return @"harry";
}

+ (void)currentInstallation
{
    [APIManager updateUser:nil username:nil];
}

+ (void)setUser:(NSString *)name
{
    [APIManager updateUser:nil username:name];
}

+ (void)setDeviceTokenFromData:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [APIManager updateUser:token username:nil];
}

@end
