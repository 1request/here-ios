//
//  APIManager.m
//  here clone
//
//  Created by Joseph Cheung on 25/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "APIManager.h"
#import "Location+API.h"
#import "Message+API.h"
#import <ISO8601DateFormatter.h>
#import "CoreDataStore.h"

@interface APIManager ()
@end

@implementation APIManager

+ (void)updateUser:(NSString *)token username:(NSString *)name CompletionHandler:(HERECompletionBlock)completionHandler
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{ kHEREAPIMessagesDeviceIdKey: [[[UIDevice currentDevice] identifierForVendor] UUIDString], kHEREAPIMessagesDeviceTypeKey: @"iOS" }];
    if (token != nil) {
        [parameters setObject:token forKey:kHEREAPIUserDeviceTokenKey];
    }
    if (name != nil) {
        [parameters setObject:name forKey:kHEREAPIUserNameKey];
    }
    
    NSURLRequest *urlRequest = [self urlPostRequestWithParams:parameters Url:[NSURL URLWithString:kHEREAPIUserPOSTUrl]];
    
    [self serverRequest:urlRequest withCallback:^(BOOL success, NSDictionary *response, NSError *error) {
        if (success) {
            NSLog(@"updated user successfully, response: %@", response);
        }
        if (completionHandler) completionHandler(success, response, error);
    }];
}

+ (void)pushAudioMessageToServer:(NSData *)data Location:(Location *)location
{
    NSDictionary *parameters = @{ kHEREAPIMessagesLocationIdKey: location.locationId, kHEREAPIMessagesDeviceIdKey: [[[UIDevice currentDevice] identifierForVendor] UUIDString], kHEREAPIMessagesDeviceTypeKey: @"iOS", kHEREAPIMessagesUsernameKey: [User username] };
    
    NSString *url = kHEREAPIMessagesPOSTUrl;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];

    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kHEREAPIMessagesBoundaryKey];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", kHEREAPIMessagesBoundaryKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", kHEREAPIMessagesBoundaryKey] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"test.m4a\"\r\n", kHEREAPIMessagesAudioFileKey] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: audio/m4a\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:data];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", kHEREAPIMessagesBoundaryKey] dataUsingEncoding:NSUTF8StringEncoding]];

    [request setHTTPBody:body];
    
    NSString *postLength = [NSString stringWithFormat:@"%tu", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [self serverRequest:request withCallback:^(BOOL success, NSDictionary *response, NSError *error) {
        NSLog(@"server response for upload audio: %@", response);
//        [self saveMessageToCoreData:response[@"message"] Location:location];
        [Message createMessageWithInfo:response[@"message"] ofLocation:location inManagedObjectContext:[CoreDataStore privateQueueContext]];
    }];
}

+ (void)pushTextMessageToServer:(NSString *)text Location:(Location *)location
{
    NSDictionary *parameters = @{ kHEREAPIMessagesLocationIdKey: location.locationId, kHEREAPIMessagesDeviceIdKey: [[[UIDevice currentDevice] identifierForVendor] UUIDString], kHEREAPIMessagesDeviceTypeKey: @"iOS", kHEREAPIMessagesTextKey: text, kHEREAPIMessagesUsernameKey: [User username] };
    
    NSURLRequest *urlRequest = [self.class urlPostRequestWithParams:parameters Url:[NSURL URLWithString:kHEREAPIMessagesPOSTUrl]];
    
    [self serverRequest:urlRequest withCallback:^(BOOL success, NSDictionary *response, NSError *error) {
        if (success) {
            NSLog(@"successfully posted text message to server");
            //            save message to core data
            [Message createMessageWithInfo:response[@"message"] ofLocation:location inManagedObjectContext:[CoreDataStore privateQueueContext]];
        }
    }];
}

+ (void)fetchLocationsWithManagedObjectContext:(NSManagedObjectContext *)context CompletionHandler:(HERECompletionBlock)completionHandler
{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kHEREAPILocationsUrl]];
    
    [urlRequest setHTTPMethod:@"GET"];
    
    [self serverRequest:urlRequest withCallback:^(BOOL success, NSDictionary *response, NSError *error) {
        if (success) {
            [Location loadLocationsFromAPIArray:response[@"data"] intoManagedObjectContext:context];
        }
        else {
            NSLog(@"error when fetch locations: %@", error);
        }
        if (completionHandler) {
            completionHandler(success, response, error);
        }
    }];
}

+ (void)fetchMessagesForLocation:(Location *)location CompletionHandler:(HERECompletionBlock)completionHandler
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kHEREMessageClassKey];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:kHEREAPICreatedAtKey ascending:NO]];
    request.fetchLimit = 1;
    
    NSArray *messages = [[CoreDataStore privateQueueContext] executeFetchRequest:request error:NULL];
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:kHEREAppInstallationDateKey];
    
    double milliseconds = [messages count] ? [[(Message *)[messages firstObject] createdAt] timeIntervalSince1970] * 1000.0 : [date timeIntervalSince1970] * 1000.0;
    
    NSString *urlString = [NSString stringWithFormat:@"%@?locId=%@&timestamp=%.0f", kHEREAPIMessagesGETUrl, location.locationId, milliseconds];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [urlRequest setHTTPMethod:@"GET"];
    
    [self serverRequest:urlRequest withCallback:^(BOOL success, NSDictionary *response, NSError *error) {
        if (success) {
            NSLog(@"fetched messages for location %@ successfully", location.name);
            NSArray *messages = response[kHEREAPIDataKey];

            for (NSDictionary *message in messages) {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:kHEREMessageClassKey];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"messageId", message[kHEREAPIIdKey]];
                
                fetchRequest.predicate = predicate;
                
                NSError *fetchError = nil;
                
                NSArray *result = [[CoreDataStore privateQueueContext] executeFetchRequest:fetchRequest error:&fetchError];
                
                if (!fetchError && [result count] == 0) [Message createMessageWithInfo:message ofLocation:location inManagedObjectContext:[CoreDataStore privateQueueContext]];
            }
        } else {
            if (error) {
                NSLog(@"error while fetch messages for location %@, error: %@", location.name, error.localizedDescription);
            }
        }
        
        if (completionHandler) {
            completionHandler(success, response, error);
        }
    }];
}

+ (Location *)updateLocationAttributes:(Location *)location data:(NSDictionary *)data
{
    location.locationId = data[kHEREAPIIdKey];
    
    if (![data[kHEREAPILocationNameKey] isKindOfClass:[NSNull class]]) location.name = data[kHEREAPILocationNameKey];
    if (![data[kHEREAPILocationAccessIdKey] isKindOfClass:[NSNull class]]) location.accessId = data[kHEREAPILocationAccessIdKey];
    if (![data[kHEREAPILocationLatitudeKey] isKindOfClass:[NSNull class]]) location.latitude = data[kHEREAPILocationLatitudeKey];
    if (![data[kHEREAPILocationLongitudeKey] isKindOfClass:[NSNull class]]) location.longitude = data[kHEREAPILocationLongitudeKey];
    if (![data[kHEREAPILocationMacAddressKey] isKindOfClass:[NSNull class]]) location.macAddress = data[kHEREAPILocationMacAddressKey];
    if (![data[kHEREAPILocationMajorKey] isKindOfClass:[NSNull class]]) location.major = data[kHEREAPILocationMajorKey];
    if (![data[kHEREAPILocationMinorKey] isKindOfClass:[NSNull class]]) location.minor = data[kHEREAPILocationMinorKey];
    if (![data[kHEREAPILocationUUIDKey] isKindOfClass:[NSNull class]]) location.uuid = data[kHEREAPILocationUUIDKey];
    
    return location;
}

+ (void)createLocationInServer:(NSDictionary *)data CompletionHandler:(HERECompletionBlock)completionHandler
{
    NSURLRequest *urlRequest = [self.class urlPostRequestWithParams:data Url:[NSURL URLWithString:kHEREAPILocationsUrl]];
    
    [self serverRequest:urlRequest withCallback:^(BOOL success, NSDictionary *response, NSError *error) {
        if (success) {
            NSLog(@"successfully posted location to server");
            completionHandler(success, response, error);
        }
    }];
}

+ (NSURLRequest *)urlPostRequestWithParams:(NSDictionary *)data Url:(NSURL *)url
{
    NSData *postData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    
    NSString *postLength = [NSString stringWithFormat:@"%tu", [postData length]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"POST"];
    
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:postData];
    
    return urlRequest;
}

+ (void)serverRequest:(NSURLRequest *)urlRequest withCallback:(HERECompletionBlock)callback
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        BOOL success;
        if (parsedObject[@"ok"]) {
            success = YES;
        }
        else {
            NSLog(@"cannot post to server.");
            NSLog(@"response: %@", parsedObject);
            success = NO;
        }
        [session invalidateAndCancel];
        callback(success, parsedObject, error);
    }];
    [task resume];
}

+ (NSDate *)dateFromISOString:(NSString *)isoDateString
{
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    NSDate *date = [formatter dateFromString:isoDateString];
    return date;
}

+ (void)downloadFileFromURL:(NSURL *)url ToPath:(NSString *)path CompletionHandler:(void(^)(void))completionHandler
{
    [[[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            if ([data writeToURL:[NSURL URLWithString:path] atomically:YES]) {
                NSLog(@"finish downloading file at path %@", path);
                if (completionHandler) {
                    completionHandler();
                }
            }
        }
    }] resume];
}

@end