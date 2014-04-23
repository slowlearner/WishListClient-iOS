//
//  WLMApiClient.h
//  WishListClient-iOS
//
//  Created by Erwin Atuli on 4/22/14.
//  Copyright (c) 2014 Peter Indiola. All rights reserved.
//

#import <Foundation/Foundation.h>

static const int REQUEST_POST = 1;
static const int REQUEST_GET = 2;
static const int REQUEST_PUT = 3;
static const int REQUEST_DELETE = 4;

@interface WLMApiClient : NSObject {
    NSString* url;
    NSString* apiKey;
    NSString* returnFormat;
    BOOL authenticated;
}

@property (retain) NSString* url;
@property (retain) NSString* apiKey;
@property (retain) NSString* returnFormat;
@property BOOL authenticated;


//instance methods
- (id) initWith:(NSString*) url apiKey:(NSString*) apiKey;
- (NSString*) request:(int) method resource:(NSString*) resource data:(NSDictionary*) data;
- (BOOL) authenticate;

//utility method for md5 hash
+ (NSString*)md5HexDigest:(NSString*)input;

@end
