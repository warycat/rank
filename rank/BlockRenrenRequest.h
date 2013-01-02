//
//  BlockRenrenRequest.h
//  BlockSinaWeibo
//
//  Created by Larry on 1/1/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlockRenren.h"
#import "Renren.h"

@interface BlockRenrenRequest : NSObject <RenrenDelegate>

+ (void)getUsersInfoWithUid:(NSString *)uid withHandler:(void(^)(id))handler;
+ (void)publishPhoto:(UIImage *)photo withCaption:(NSString *)caption withHandler:(void(^)(id))handler;
@end
