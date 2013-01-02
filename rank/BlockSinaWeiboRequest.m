//
//  BlockSinaWeiboRequest.m
//  BlockSinaWeibo
//
//  Created by Larry on 12/31/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "BlockSinaWeiboRequest.h"
#import "SinaWeiboConstants.h"

@interface BlockSinaWeiboRequest ()

@property (nonatomic, copy) void (^simpleCompletionBlock)(id);
@property (nonatomic, strong) SinaWeiboRequest *request;

@end

@implementation BlockSinaWeiboRequest

+ (BlockSinaWeiboRequest *)GETrequestAPI:(NSString *)API withParams:(NSDictionary *)params withHandler:(void(^)(id))handler
{
    BlockSinaWeiboRequest *blockSinaWeiboRequest = [[BlockSinaWeiboRequest alloc]init];
    blockSinaWeiboRequest.simpleCompletionBlock = handler;
    if (params == nil) {
        params = [NSMutableDictionary dictionary];
    }
    SinaWeibo *sinaWeibo = [BlockSinaWeibo sharedClient].sinaWeibo;
    [[BlockSinaWeibo sharedClient].requests addObject:blockSinaWeiboRequest];
    if (sinaWeibo.isAuthValid) {
        NSLog(@"isAuthValid");
        NSString *fullURL = [kSinaWeiboSDKAPIDomain stringByAppendingString:API];
        blockSinaWeiboRequest.request = [SinaWeiboRequest requestWithAccessToken:sinaWeibo.accessToken
                                              url:fullURL httpMethod:@"GET"
                                           params:params
                                         delegate:blockSinaWeiboRequest];
        [blockSinaWeiboRequest.request connect];
    }
    return blockSinaWeiboRequest;
}

+ (BlockSinaWeiboRequest *)POSTrequestAPI:(NSString *)API withParams:(NSDictionary *)params withHandler:(void(^)(id))handler
{
    BlockSinaWeiboRequest *blockSinaWeiboRequest = [[BlockSinaWeiboRequest alloc]init];
    blockSinaWeiboRequest.simpleCompletionBlock = handler;
    if (params == nil) {
        params = [NSMutableDictionary dictionary];
    }
    SinaWeibo *sinaWeibo = [BlockSinaWeibo sharedClient].sinaWeibo;
    [[BlockSinaWeibo sharedClient].requests addObject:blockSinaWeiboRequest];
    if (sinaWeibo.isAuthValid) {
        NSLog(@"isAuthValid");
        NSString *fullURL = [kSinaWeiboSDKAPIDomain stringByAppendingString:API];
        blockSinaWeiboRequest.request = [SinaWeiboRequest requestWithAccessToken:sinaWeibo.accessToken
                                                                             url:fullURL httpMethod:@"POST"
                                                                          params:params
                                                                        delegate:blockSinaWeiboRequest];
        [blockSinaWeiboRequest.request connect];
    }
    return blockSinaWeiboRequest;
}


#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%s", (char *)_cmd);
    NSLog(@"%@",error);
    [[BlockSinaWeibo sharedClient].requests removeObject:self];
    //    [self resetButtons];
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    NSLog(@"%s", (char *)_cmd);

     //    [self resetButtons];
    self.simpleCompletionBlock(result);
    [[BlockSinaWeibo sharedClient].requests removeObject:self];

}

- (void)request:(SinaWeiboRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%s", (char *)_cmd);

}
- (void)request:(SinaWeiboRequest *)request didReceiveRawData:(NSData *)data
{
    NSLog(@"%s", (char *)_cmd);

}

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
