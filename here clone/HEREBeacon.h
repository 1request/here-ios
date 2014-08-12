//
//  HEREBeacon.h
//  here clone
//
//  Created by Joseph Cheung on 12/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEREBeacon : NSObject

@property (strong, nonatomic) NSUUID *uuid;
@property (nonatomic) int major;
@property (nonatomic) int minor;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *parseId;

- (id)initWithData:(NSDictionary *)data;

@end
