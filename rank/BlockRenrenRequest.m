//
//  BlockRenrenRequest.m
//  BlockSinaWeibo
//
//  Created by Larry on 1/1/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import "BlockRenrenRequest.h"

@interface BlockRenrenRequest ()

@property (nonatomic, copy) void (^simpleCompletionBlock)(id);

@end

@implementation BlockRenrenRequest

+ (void)getUsersInfoWithUid:(NSString *)uid withHandler:(void(^)(id))handler
{
    ROUserInfoRequestParam *param = [[ROUserInfoRequestParam alloc]init];
    param.userIDs = uid;
    BlockRenrenRequest *blockRenrenRequest = [[BlockRenrenRequest alloc]init];
    blockRenrenRequest.simpleCompletionBlock = handler;
    [[BlockRenren sharedClient].requests addObject:blockRenrenRequest];
    [[Renren sharedRenren] getUsersInfo:param andDelegate:blockRenrenRequest];
}

+ (void)publishPhoto:(UIImage *)photo withCaption:(NSString *)caption withHandler:(void(^)(id))handler
{
    ROPublishPhotoRequestParam *param = [[ROPublishPhotoRequestParam alloc]init];
    param.imageFile = photo;
    param.caption = caption;
    BlockRenrenRequest *blockRenrenRequest = [[BlockRenrenRequest alloc]init];
    blockRenrenRequest.simpleCompletionBlock = handler;
    [[BlockRenren sharedClient].requests addObject:blockRenrenRequest];
    [[Renren sharedRenren] publishPhoto:param andDelegate:blockRenrenRequest];
}

- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse *)response
{
    self.simpleCompletionBlock(response.rootObject);
    [[BlockRenren sharedClient].requests removeObject:self];
}


@end
