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

- (void)uploadAudio:(NSData *)data Beacon:(HEREBeacon *)beacon
{
    NSDictionary *parameters = @{ kHEREAPILocationUUIDKey: [beacon.uuid UUIDString], kHEREAPILocationMajorKey: [NSString stringWithFormat:@"%tu", beacon.major], kHEREAPILocationMinorKey: [NSString stringWithFormat:@"%tu", beacon.minor], kHEREAPIDeviceIdKey: [[[UIDevice currentDevice] identifierForVendor] UUIDString], kHEREAPIDeviceTypeKey: @"iOS" };
    
    NSString *url = kHEREAPIMessagesUrl;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];

    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kHEREAPIBoundaryKey];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", kHEREAPIBoundaryKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", kHEREAPIBoundaryKey] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"test.m4a\"\r\n", kHEREAPIAudioFileKey] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: audio/m4a\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:data];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", kHEREAPIBoundaryKey] dataUsingEncoding:NSUTF8StringEncoding]];

    [request setHTTPBody:body];
    
    NSString *postLength = [NSString stringWithFormat:@"%tu", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        
        [self.delegate didUploadAudio];
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

- (void)fetchLocation
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kHEREAPILocationsUrl]];
    
    [urlRequest setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSLog(@"fetchLocation result: %@", parsedObject);
        [self saveLocationsToCoreData:parsedObject[@"data"]];
        [session invalidateAndCancel];
    }];
    [task resume];
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
    NSData *postData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    
    NSString *postLength = [NSString stringWithFormat:@"%tu", [postData length]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kHEREAPILocationsUrl]];
    
    [urlRequest setHTTPMethod:@"POST"];
    
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:postData];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (parsedObject[@"ok"]) {
            NSLog(@"parsedObject: %@", parsedObject);
            NSLog(@"created location, location Id = %@", parsedObject[kHEREAPILocationIdPOSTKey]);
            [self.delegate didUpdateLocation];
        }
        else {
            NSLog(@"cannot create the location. perhaps someone has created it");
        }
        [session invalidateAndCancel];
    }];
    [task resume];
}

@end