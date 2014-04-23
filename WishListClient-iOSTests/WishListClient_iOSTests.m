//
//  WishListClient_iOSTests.m
//  WishListClient-iOSTests
//
//  Created by Peter Indiola on 4/12/14.
//  Copyright (c) 2014 Peter Indiola. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WLMApiClient.h"

@interface WishListClient_iOSTests : XCTestCase {
    WLMApiClient* apiClient;
}

@property (retain) WLMApiClient* apiClient;

@end

@implementation WishListClient_iOSTests

@synthesize apiClient;

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSString* url = @"http://wordpress.loc";
    NSString* apiKey = @"GJPdnqt3FGVdno26";
    self.apiClient = [[WLMApiClient alloc] initWith:url apiKey:apiKey];
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    
}

- (void) testInit
{
    
    // A bit new to ios so let's see if we're actually doing ok
    XCTAssertTrue([[self.apiClient url] isEqualToString:@"http://wordpress.loc"]);
    XCTAssertTrue([[self.apiClient apiKey] isEqualToString:@"GJPdnqt3FGVdno26"]);
}
- (void) testRequest
{
    NSString* resp = [self.apiClient request:REQUEST_GET resource:@"/auth" data:Nil];
    XCTAssertNotNil(resp);
    XCTAssertTrue([resp rangeOfString:@"success"].location != NSNotFound);
}
- (void) testAuthenticate
{
    BOOL authed = [self.apiClient authenticate];
    XCTAssertTrue(authed);
    
}

- (void) testMd5
{

    //NSMutableString* yolo = @"2d664feb111ebc50c56165966d077f8e";
    //XCTAssertEqual(yolo, [WLMApiClient md5HexDigest:@"YOLO"]);
    NSString* expected = @"2d664feb111ebc50c56165966d077f8e";
    NSString* actual = [WLMApiClient md5HexDigest:@"YOLO"];    
    NSLog(@"expected: -%@-", expected);
    NSLog(@"actual: -%@-", actual);
    XCTAssertTrue([expected isEqualToString:actual]);
    
}

- (void) testGet
{
    [self.apiClient authenticate];
    NSString* response = [self.apiClient request:REQUEST_GET resource:@"/levels" data:Nil];
    NSLog(@"levels %@", response);
    XCTAssertNotNil(response);
    
    
    NSError* jsonparsingerr = nil;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonparsingerr];

    jsonDict = [jsonDict objectForKey:@"levels"];
    NSArray* jsonArray = [jsonDict objectForKey:@"level"];
    
    
}

@end
