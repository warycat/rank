//
//  BlockRenren.m
//  BlockSinaWeibo
//
//  Created by Larry on 1/1/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import "BlockRenren.h"

@interface BlockRenren ()

@property (nonatomic, copy) void (^loginBlock)();

@end

@implementation BlockRenren

- (NSString *)uid
{
    if (!_uid) {
        _uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_UserId"];
    }
    return _uid;
}

+ (BlockRenren *)sharedClient
{
    static BlockRenren *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BlockRenren alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        _requests = [NSMutableArray array];
    }
    return self;
}

+ (void)loginWithHandler:(void(^)())handler
{
    [[Renren sharedRenren] logout:[BlockRenren sharedClient]];
    [[Renren sharedRenren] authorizationWithPermisson:@[@"photo_upload"] andDelegate:[BlockRenren sharedClient]];
    [BlockRenren sharedClient].loginBlock = handler;
}


- (void)renrenDidLogin:(Renren *)renren
{
    NSLog(@"login %@ %@",[Renren sharedRenren].sessionKey,[Renren sharedRenren].secret);
}

- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse *)response
{
    NSDictionary *dict = response.rootObject;
    self.uid = [dict objectForKey:@"uid"];
    [BlockRenren sharedClient].loginBlock();
}


@end
