//
//  User.h
//  here clone
//
//  Created by Harry Ng on 2/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

+ (NSString *)username;
+ (void)currentInstallation;
+ (void)setUser:(NSString *)name CompletionHandler:(void(^)(BOOL success, NSDictionary *response, NSError *error))completionHandler;
+ (void)setDeviceTokenFromData:(NSData *)deviceToken;

@end
