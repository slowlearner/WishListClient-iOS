//
//  WLPMembershipLevelsViewController.m
//  WishListClient-iOS
//
//  Created by Peter Indiola on 4/13/14.
//  Copyright (c) 2014 Peter Indiola. All rights reserved.
//

#import "WLPMembershipLevelsViewController.h"
#import <RestKit/RestKit.h>
#import "WLPMembershipLevel.h"
#import "SVProgressHUD.h"
#import "WLPMappingProvider.h"
#import <CommonCrypto/CommonDigest.h>

@interface WLPMembershipLevelsViewController ()

@property (nonatomic, strong) NSArray *levels;
@property (nonatomic, strong) NSString *lock;
@property (nonatomic, strong) NSString *key;

@end

@implementation WLPMembershipLevelsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    BOOL isAuthenticated = [self authenticated];
    if (isAuthenticated) {
        [SVProgressHUD show];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [self loadMemberShipLevels];
        });
        
    }
}

- (void)setCookie
{
    NSURL *apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?/wlmapi/2.0/json/levels", WISHLIST_API_URL]];
    
    NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStore cookiesForURL:apiUrl];
    NSDictionary *cookieHeaders;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiUrl
                                                           cachePolicy:NSURLCacheStorageAllowed
                                                       timeoutInterval:60];
    cookieHeaders = [ NSHTTPCookie requestHeaderFieldsWithCookies: cookies ];
    [request setValue: [ cookieHeaders objectForKey: @"Cookie" ]
   forHTTPHeaderField: @"Cookie" ];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
}

- (BOOL) authenticated {
    BOOL authenticated = NO;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?/wlmapi/2.0/json/auth", WISHLIST_API_URL]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url
                                                       cachePolicy:NSURLCacheStorageAllowed
                                                   timeoutInterval:60];
    
    [req setValue:@"12345=12345" forHTTPHeaderField:@"Cookie"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&urlResponse error:&requestError];
    NSError *jsonParsingError = nil;
    NSArray *response = [NSJSONSerialization JSONObjectWithData:data
                                                        options:0
                                                          error:&jsonParsingError];
    NSString *hash = [NSString stringWithFormat:@"%@%@", [response valueForKey:@"lock"], WISHLIST_API_KEY];
    const char *cStr = [hash UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    //POST Auth
    NSString *postData = [NSString stringWithFormat:@"key=%@", output];
    NSMutableURLRequest *postReq = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLCacheStorageAllowed
                                                       timeoutInterval:60];
    self.lock = [response valueForKey:@"lock"];
    [postReq setHTTPMethod:@"POST"];
    [postReq setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *authKey = [NSString stringWithFormat:@"lock=%@", self.lock];
    [postReq setValue:authKey forHTTPHeaderField:@"Cookie"];
    
    data = [NSURLConnection sendSynchronousRequest:postReq returningResponse:&urlResponse error:&requestError];
    response = [NSJSONSerialization JSONObjectWithData:data
                                               options:0
                                                 error:&jsonParsingError];
    if([response valueForKey:@"success"]) {
        authenticated = YES;
        self.key = [response valueForKey:@"key"];
        [self setCookie];
    }
    return authenticated;
}

- (void)loadMemberShipLevels
{
    RKMapping *mapping = [WLPMappingProvider levelMapping];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:@"levels.level"
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?/wlmapi/2.0/json/levels", WISHLIST_API_URL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        _levels = result.array;
        [self.tableView reloadData];
         [SVProgressHUD dismiss];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        [SVProgressHUD showErrorWithStatus:@"Request failed"];
    }];
    [operation start];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _levels.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    WLPMembershipLevel *level = _levels[indexPath.row];
    cell.textLabel.text = level.name;
    return cell;
}

@end
