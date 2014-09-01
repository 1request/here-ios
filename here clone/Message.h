//
//  Message.h
//  here clone
//
//  Created by Joseph Cheung on 29/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * deviceId;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSManagedObject *location;

@end
