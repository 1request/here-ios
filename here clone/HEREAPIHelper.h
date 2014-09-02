//
//  HEREAPIHelper.h
//  here clone
//
//  Created by Joseph Cheung on 25/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEREBeacon.h"
#import "Location.h"

@protocol apiDelegate <NSObject>
@optional
- (void)didUploadAudio;
- (void)didUpdateLocation;
- (void)didFetchLocations;
@end

@interface HEREAPIHelper : NSObject

typedef void (^HERECompletionBlock)(BOOL success, NSDictionary *response, NSError *error);

@property (weak, nonatomic) id <apiDelegate> delegate;
- (void)pushAudioMessageToServer:(NSData *)data Location:(Location *)location;
- (void)pushTextMessageToServer:(NSString *)text Location:(Location *)location;
- (void)fetchLocations;
- (void)fetchMessagesForLocation:(Location *)location;
- (void)createLocationInServer:(NSDictionary *)data;
@end
