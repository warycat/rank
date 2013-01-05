//
//  BlockRenren.h
//  BlockSinaWeibo
//
//  Created by Larry on 1/1/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Renren.h"

@interface BlockRenren : NSObject <RenrenDelegate>

@property (nonatomic, strong) NSString *uid;

@property (nonatomic, strong) NSMutableArray *requests;

+ (BlockRenren *)sharedClient;

+ (void)loginWithHandler:(void(^)())handler;

+ (void)logout;

@end
