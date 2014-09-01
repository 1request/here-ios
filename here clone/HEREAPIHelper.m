//
//  HEREAPIHelper.m
//  here clone
//
//  Created by Joseph Cheung on 25/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREAPIHelper.h"

@interface HEREAPIHelper ()
@end

@implementation HEREAPIHelper

- (void)uploadAudio:(NSData *)data Beacon:(HEREBeacon *)beacon
{
    NSDictionary *parameters = @{ kHEREAPIUUIDKey: [beacon.uuid UUIDString], kHEREAPIMajorKey: [NSString stringWithFormat:@"%tu", beacon.major], kHEREAPIMinorKey: [NSString stringWithFormat:@"%tu", beacon.minor], kHEREAPIDeviceIdKey: [[[UIDevice currentDevice] identifierForVendor] UUIDString], kHEREAPIDeviceTypeKey: @"iOS" };
    
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
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        
        [self.delegate didUploadAudio];
    }];
}

- (void)updateLocation:(NSDictionary *)data
{
    if (data[kHEREBeaconUUIDKey]) {
        NSLog(@"upload beacon location");
        
        NSData *postData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
        
        NSString *postLength = [NSString stringWithFormat:@"%tu", [postData length]];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kHEREAPILocationsUrl, data[kHEREAPILocationIdKey]]]];
        
        [urlRequest setHTTPMethod:@"PUT"];
        
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [urlRequest setHTTPBody:postData];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSLog(@"Dictionary: %@", parsedObject);
            if ([parsedObject[@"ok"] boolValue]) [self.delegate didUpdateLocation];
        }];
        
        [task resume];
    }
}

@end