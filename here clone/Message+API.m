//
//  Message+API.m
//  here clone
//
//  Created by Joseph Cheung on 16/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "Message+API.h"
#import "APIManager.h"
#import "Location.h"
#import <ISO8601DateFormatter.h>
#import <AVFoundation/AVFoundation.h>

@implementation Message (API)

+ (NSDate *)dateFromISOString:(NSString *)isoDateString
{
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    NSDate *date = [formatter dateFromString:isoDateString];
    return date;
}

+ (Message *)createMessageWithInfo:(NSDictionary *)messageDictionary
                        ofLocation:(Location *)location
            inManagedObjectContext:(NSManagedObjectContext *)context
{
    Message *message = nil;
    
    NSString *messageId = messageDictionary[kHEREAPIIdKey];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kHEREMessageClassKey];
    request.predicate = [NSPredicate predicateWithFormat:@"messageId == %@", messageId];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        NSLog(@"error when fetching message in messageWithAPIInfo, %@", error.localizedDescription);
    }
    else if ([matches count]) {
        message = [matches firstObject];
    }
    else {
        message = [NSEntityDescription insertNewObjectForEntityForName:kHEREMessageClassKey inManagedObjectContext:context];
        message.messageId = messageId;
        message.location = location;
        
        if (messageDictionary[kHEREAPIMessagesAudioFileKey] != [NSNull null]) {
            message.audioFilePath = [messageDictionary valueForKeyPath:kHEREAPIMessagesAudioFileKey];
            NSData *audioData = [NSData dataWithContentsOfURL:[NSURL URLWithString:message.audioFilePath]];
            NSArray *documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
            NSURL *url = [[documentDirectories firstObject] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", message.messageId]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:[url absoluteString]]) {
                if ([audioData writeToURL:url atomically:YES]) {
                    message.localURL = [url absoluteString];
                    message.audioLength = [self durationFromAudioFileURL:url];
                    NSLog(@"finish downloading audio file for message %@; url: %@", message.messageId, url);
                }
            }
        }
        if (messageDictionary[kHEREAPIMessagesDeviceIdKey] != [NSNull null]) message.deviceId = [messageDictionary valueForKeyPath:kHEREAPIMessagesDeviceIdKey];
        if (messageDictionary[kHEREAPICreatedAtKey] != [NSNull null]) message.createdAt = [self dateFromISOString:[messageDictionary valueForKeyPath:kHEREAPICreatedAtKey]];
        if (messageDictionary[kHEREAPIMessagesTextKey] != [NSNull null]) message.text = [messageDictionary valueForKeyPath:kHEREAPIMessagesTextKey];
        if (messageDictionary[kHEREAPIMessagesUsernameKey] != [NSNull null]) message.username = [messageDictionary valueForKeyPath:kHEREAPIMessagesUsernameKey];
        NSLog(@"message: %@", message);
        [context save:NULL];
    }
    
    return message;
}

+ (NSNumber *)durationFromAudioFileURL:(NSURL *)url
{
    NSParameterAssert(url != nil);
    
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    CMTime audioDuration = audioAsset.duration;
    return [NSNumber numberWithInt:ceil(CMTimeGetSeconds(audioDuration))];
}

+ (void)fetchMessagesFromAPIArray:(NSArray *)messages
                      ofLocation:(Location *)location
        intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *message in messages) {
        [self createMessageWithInfo:message ofLocation:location inManagedObjectContext:context];
    }
}

@end
