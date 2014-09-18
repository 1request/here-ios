//
//  Message+API.h
//  here clone
//
//  Created by Joseph Cheung on 16/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "Message.h"
#import "Location.h"

@interface Message (API)

+ (NSNumber *)durationFromAudioFileURL:(NSURL *)url;

+ (Message *)createMessageWithInfo:(NSDictionary *)messageDictionary
                        ofLocation:(Location *)location
            inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)fetchMessagesFromAPIArray:(NSArray *)messages
                       ofLocation:(Location *)location
         intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
