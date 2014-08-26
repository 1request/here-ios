//
//  HEREUploadHelper.m
//  here clone
//
//  Created by Joseph Cheung on 25/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREUploadHelper.h"

@interface HEREUploadHelper ()
@end

@implementation HEREUploadHelper

+ (void)uploadAudio:(NSData *)data Beacon:(HEREBeacon *)beacon
{
    NSDictionary *parameters = @{ kHEREAPIUUIDKey: [beacon.uuid UUIDString], kHEREAPIMajorKey: [NSString stringWithFormat:@"%tu", beacon.major], kHEREAPIMinorKey: [NSString stringWithFormat:@"%tu", beacon.minor], kHEREAPIDeviceIdKey: [[[UIDevice currentDevice] identifierForVendor] UUIDString], kHEREAPIDeviceTypeKey: @"iOS" };
    
    NSString *url = kHEREAPIUploadLink;
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
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", returnString);
}

@end