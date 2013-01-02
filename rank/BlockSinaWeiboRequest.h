//
//  BlockSinaWeiboRequest.h
//  BlockSinaWeibo
//
//  Created by Larry on 12/31/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlockSinaWeibo.h"
#import "SinaWeiboRequest.h"

@interface BlockSinaWeiboRequest : NSObject <SinaWeiboRequestDelegate>

+ (BlockSinaWeiboRequest *)GETrequestAPI:(NSString *)API withParams:(NSDictionary *)params withHandler:(void(^)(id))handler;

+ (BlockSinaWeiboRequest *)POSTrequestAPI:(NSString *)API withParams:(NSDictionary *)params withHandler:(void(^)(id))handler;

@end
