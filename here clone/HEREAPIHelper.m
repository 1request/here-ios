//
//  HEREAPIHelper.m
//  here clone
//
//  Created by Joseph Cheung on 25/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREAPIHelper.h"
#import "Location.h"
#import "HERECoreDataHelper.h"


@interface HEREAPIHelper ()
@end

@implementation HEREAPIHelper

+ (void)updateUser:(NSString *)token username:(NSString *)name
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{ kHEREAPIMessagesDeviceIdKey: [[[UIDevice currentDevice] identifierForVendor] UUIDString], kHEREAPIMessagesDeviceTypeKey: @"iOS" }];
    if (token != nil) {
        [parameters setObject:token forKey:kHEREAPIUserDeviceTokenKey];
    }
    if (name != nil) {
        [parameters setObject:name forKey:kHEREAPIUserNameKey];
    }
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLRequest *urlRequest = [self urlPostRequestWithParams:parameters Url:[NSURL URLWithString:kHEREAPIUserPOSTUrl]];
    
    [self serverRequest:session urlRequest:urlRequest withCallback:^(BOOL success, NSDictionary *response, NSError *error) {
        if (success) {
            NSLog(@"successfully posted user update to server");
        }
    }];
}

- (void)pushAudioMessageToServer:(NSData *)data Location:(Location *)location
{
    NSDictionary *parameters = @{ kHEREAPIMessagesLocationIdKey: location.locationId, kHEREAPIMessagesDeviceIdKey: [[[UIDevice currentDevice] identifierForVendor] UUIDString], kHEREAPIMessagesDeviceTypeKey: @"iOS" };
    
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
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        
        [self.delegate didUploadAudio];
    }];
}

- (void)pushTextMessageToServer:(NSString *)text Location:(Location *)location
{
    NSDictionary *parameters = @{ kHEREAPIMessagesLocationIdKey: location.locationId, kHEREAPIMessagesDeviceIdKey: [[[UIDevice currentDevice] identifierForVendor] UUIDString], kHEREAPIMessagesDeviceTypeKey: @"iOS", kHEREAPIMessagesTextKey: text };
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLRequest *urlRequest = [self.class urlPostRequestWithParams:parameters Url:[NSURL URLWithString:kHEREAPIMessagesPOSTUrl]];
    
    [self.class serverRequest:session urlRequest:urlRequest withCallback:^(BOOL success, NSDictionary *response, NSError *error) {
        if (success) {
            NSLog(@"successfully posted text message to server");
        }
    }];
}

//
//- (void)updateLocation:(NSDictionary *)data
//{
//    if (data[kHEREBeaconUUIDKey]) {
//        NSLog(@"upload beacon location");
//        
//        NSData *postData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
//        
//        NSString *postLength = [NSString stringWithFormat:@"%tu", [postData length]];
//        
//        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kHEREAPILocationsUrl, data[kHEREAPILocationIdGETKey]]]];
//        
//        [urlRequest setHTTPMethod:@"PUT"];
//        
//        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//        [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
//        [urlRequest setHTTPBody:postData];
//        
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//        
//        NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//            NSLog(@"Dictionary: %@", parsedObject);
//            if ([parsedObject[@"ok"] boolValue]) [self.delegate didUpdateLocation];
//            [session invalidateAndCancel];
//        }];
//        
//        [task resume];
//    }
//}

- (void)fetchLocations
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kHEREAPILocationsUrl]];
    
    [urlRequest setHTTPMethod:@"GET"];
    
    [self.class serverRequest:session urlRequest:urlRequest withCallback:^(BOOL success, NSDictionary *response, NSError *error) {
        if (success) {
            NSLog(@"fetched location successfully, response: %@", response);
            [self saveLocationsToCoreData:response[@"data"]];
        }
    }];
}

- (void)saveLocationsToCoreData:(NSDictionary *)locations
{
    for (NSDictionary *data in locations) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:kHERELocationClassKey];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"locationId", data[kHEREAPILocationIdGETKey]];
        
        fetchRequest.predicate = predicate;
        
        NSError *fetchError = nil;
        
        NSArray *result = [[HERECoreDataHelper managedObjectContext] executeFetchRequest:fetchRequest error:&fetchError];
        
        if (!fetchError) {
            if ([result count] == 0) {
                [self createLocationWithData:data];
            }
            else {
                Location *location = [result firstObject];
                [self updateCoreData:location data:data];
            }
        }
    }
    [self.delegate didFetchLocations];
}

- (void)fetchMessagesForLocation:(Location *)location
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString *urlString = [NSString stringWithFormat:@"%@?locId=%@", kHEREAPIMessagesGETUrl, location.locationId];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [urlRequest setHTTPMethod:@"GET"];
    
    [self.class serverRequest:session urlRequest:urlRequest withCallback:^(BOOL success, NSDictionary *response, NSError *error) {
        if (success) {
            NSLog(@"fetched messages for location %@ successfully", location.name);
            NSLog(@"response: %@", response);
        }
    }];
}


- (void)createLocationWithData:(NSDictionary *)data
{
    NSManagedObjectContext *context = [HERECoreDataHelper managedObjectContext];
    
    Location *location = [NSEntityDescription insertNewObjectForEntityForName:kHERELocationClassKey inManagedObjectContext:context];

    location = [self updateLocationAttributes:location data:data];
    
    location.createdAt = [NSDate date];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"error in createLocationWithData: %@", error);
    }
}

- (void)updateCoreData:(Location *)location data:(NSDictionary *)data
{
    location = [self updateLocationAttributes:location data:data];
    
    NSError *error = nil;
    if (![location.managedObjectContext save:&error]) {
        NSLog(@"updateCoreDataLocation error: %@", error);
    }
}

- (Location *)updateLocationAttributes:(Location *)location data:(NSDictionary *)data
{
    location.locationId = data[kHEREAPILocationIdGETKey];
    
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

- (void)createLocationInServer:(NSDictionary *)data
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLRequest *urlRequest = [self.class urlPostRequestWithParams:data Url:[NSURL URLWithString:kHEREAPILocationsUrl]];
    
    [self.class serverRequest:session urlRequest:urlRequest withCallback:^(BOOL success, NSDictionary *response, NSError *error) {
        if (success) {
            NSLog(@"successfully posted location to server");
            [self.delegate didUpdateLocation];
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

+ (void)serverRequest:(NSURLSession *)session urlRequest:(NSURLRequest *)urlRequest withCallback:(HERECompletionBlock)callback
{
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        BOOL success;
        if (parsedObject[@"ok"]) {
            success = YES;
        }
        else {
            NSLog(@"cannot post to server.");
            success = NO;
        }
        [session invalidateAndCancel];
        callback(success, parsedObject, error);
    }];
    [task resume];
}

@end