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
    return [[NSUserDefaults standardUserDefaults] valueForKey:kHEREAPIUserNameKey];
}

+ (void)currentInstallation
{
    [APIManager updateUser:nil username:nil CompletionHandler:NULL];
}

+ (void)setUser:(NSString *)name CompletionHandler:(void(^)(BOOL success, NSDictionary *response, NSError *error))completionHandler
{
    [APIManager updateUser:nil username:name CompletionHandler:^(BOOL success, NSDictionary *response, NSError *error) {
        completionHandler(success, response, error);
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:kHEREAPIUserNameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setDeviceTokenFromData:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [APIManager updateUser:token username:nil CompletionHandler:NULL];
}

@end
