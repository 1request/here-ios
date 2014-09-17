//
//  Message.h
//  here clone
//
//  Created by Joseph Cheung on 17/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * audioFilePath;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * deviceId;
@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * audioLength;
@property (nonatomic, retain) NSString * localURL;
@property (nonatomic, retain) Location *location;

@end
