//
//  BlockSinaWeibo.h
//  BlockSinaWeibo
//
//  Created by Larry on 12/29/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SinaWeibo.h"

#define kAppKey             @"2825629998"
#define kAppSecret          @"513efff2e9d8cd60d2bb2d568ae8cda3"
#define kAppRedirectURI     @"http://aws.warycat.com/rank/"
#define kCallbackScheme     @"blocksinaweibo"

@interface BlockSinaWeibo : NSObject <SinaWeiboDelegate,SinaWeiboRequestDelegate>

@property (nonatomic, strong) SinaWeibo *sinaWeibo;
@property (nonatomic, strong) NSMutableArray *requests;

+ (BlockSinaWeibo *)sharedClient;

+ (void)loginWithHandler:(void(^)())handler;

@end
