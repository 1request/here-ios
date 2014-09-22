//
//  ViewMessage.h
//  Here
//
//  Created by Joseph Cheung on 14/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JSQMessageData.h"
#import "Message.h"

@interface ViewMessage : NSObject <JSQMessageData, NSCoding, NSCopying>

@property (nonatomic) JSQMessageType type;

@property (copy, nonatomic) NSString *sender;

@property (copy, nonatomic) NSDate *date;

@property (copy, nonatomic) NSString *text;

@property (strong, nonatomic) NSData *audio;

@property (strong, nonatomic) UIImage *sourceImage;

@property (strong, nonatomic) UIImage *thumbnailImage;

@property (strong, nonatomic) UIImage *videoThumbnail;

@property (strong, nonatomic) UIImage *videoThumbnailPlaceholder;

@property (strong, nonatomic) NSURL *sourceURL;

@property (strong, nonatomic) NSNumber *audioLength;

@property (nonatomic) BOOL isRead;

#pragma mark - Initialization

- (instancetype)initWithText:(NSString *)text
                      sender:(NSString *)sender
                        date:(NSDate *)date;

- (instancetype)initWithAudio:(NSData *)audio
                       sender:(NSString *)sender
                         date:(NSDate *)date;

- (instancetype)initWithCoreDataMessage:(Message *)message;

- (BOOL)isEqualToMessage:(ViewMessage *)aMessage;

@end
