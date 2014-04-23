//
//  WLMApiClient.m
//  WishListClient-iOS
//
//  Created by Erwin Atuli on 4/22/14.
//  Copyright (c) 2014 Peter Indiola. All rights reserved.
//

#import "WLMApiClient.h"
#import "AFNetworking.h"
#import <CommonCrypto/CommonDigest.h>


@implementation WLMApiClient

@synthesize url;
@synthesize apiKey;
@synthesize authenticated;
@synthesize returnFormat;



- (id) initWith:(NSString *)url apiKey:(NSString *)apiKey
{
    if(self = [super init]) {
        self.url = url;
        self.apiKey = apiKey;
        self.authenticated = false;
        self.returnFormat = @"json";
    }
    return self;
}
- (BOOL) authenticate
{
    if(self.authenticated) {
        return TRUE;
    }
    
    NSString* response = [self request:REQUEST_GET resource:@"/auth" data:Nil];
    NSLog(@"init auth response is %@", response);
    
    NSError* jsonparsingerr = nil;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonparsingerr];
    
    NSString* lock = [jsonDict objectForKey:@"lock"];
    NSString* hash = [WLMApiClient md5HexDigest:[lock stringByAppendingString:apiKey]];
    
    NSDictionary *params = @{@"key":hash};

    response = [self request:REQUEST_POST resource:@"/auth" data:params];

    jsonDict = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonparsingerr];
    
    NSLog(@"post auth response is %@", response);
    
    NSNumber* success = [jsonDict objectForKey:@"success"];
    if([success isEqual:[NSNumber numberWithInt:1]]) {
        return TRUE;
    }
    
    return FALSE;
}

- (NSString*) request:(int)method resource:(NSString *)resource data:(NSDictionary *)data
{
    
    NSString* gateway = [[NSArray arrayWithObjects:self.url, @"/?/wlmapi/2.0/", self.returnFormat ,resource,nil] componentsJoinedByString:@""];
    
    NSLog(@"gateway is %@", gateway);

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:gateway] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60];
    
    NSURLResponse* response = Nil;
    NSError* error = Nil;
    NSData* responseBody = Nil;
    
    
    // build the request body for post/
    NSMutableArray *pairs = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString *key in data) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, data[key]]];
    }
    NSString *requestParams = [pairs componentsJoinedByString:@"&"];
    NSData* requestBody = requestBody = [NSData dataWithBytes:[requestParams UTF8String] length:requestParams.length];
    
    switch (method) {
            case REQUEST_POST:
                [request setHTTPMethod:@"POST"];
                [request setHTTPBody:requestBody];
                responseBody = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                break;
            case REQUEST_PUT:
                [request setHTTPMethod:@"PUT"];
                [request setHTTPBody:requestBody];
                responseBody = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                break;
            case REQUEST_DELETE:
                [request setHTTPMethod:@"DELETE"];
                responseBody = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                break;
            case REQUEST_GET:
                responseBody = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                break;
    }
    
    return [[NSString alloc] initWithData:responseBody encoding:NSUTF8StringEncoding];
}

+ (NSString*) md5HexDigest:(NSString*)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    NSLog(@"hash %@", ret);
    return ret;
}
@end
