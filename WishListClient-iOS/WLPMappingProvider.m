//
//  WLPMappingProvider.m
//  WishListClient-iOS
//
//  Created by Peter Indiola on 4/13/14.
//  Copyright (c) 2014 Peter Indiola. All rights reserved.
//

#import "WLPMappingProvider.h"
#import "WLPMembershipLevel.h"
@implementation WLPMappingProvider

+ (RKMapping *)levelMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[WLPMembershipLevel class]];
    
//    [mapping addAttributeMappingsFromArray:@[@"name"]];
    [mapping addAttributeMappingsFromDictionary:@{
        @"level.id":@"levelId",
        @"level.name":@"name"
    }];
    return mapping;
}
@end
