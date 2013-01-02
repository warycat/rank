//
//  BlockSinaWeibo.m
//  BlockSinaWeibo
//
//  Created by Larry on 12/29/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "BlockSinaWeibo.h"

@interface BlockSinaWeibo ()

@property (nonatomic, copy) void (^simpleCompletionBlock)();

@end

@implementation BlockSinaWeibo

+ (BlockSinaWeibo *)sharedClient
{
    static BlockSinaWeibo *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BlockSinaWeibo alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        _requests = [NSMutableArray array];
        _sinaWeibo = [[SinaWeibo alloc]initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI ssoCallbackScheme:kCallbackScheme andDelegate:self];
        NSLog(@"init %@",_sinaWeibo);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
        if ([sinaweiboInfo objectForKey:@"AccessTokenKey"] && [sinaweiboInfo objectForKey:@"ExpirationDateKey"] && [sinaweiboInfo objectForKey:@"UserIDKey"])
        {
            _sinaWeibo.accessToken = [sinaweiboInfo objectForKey:@"AccessTokenKey"];
            _sinaWeibo.expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDateKey"];
            _sinaWeibo.userID = [sinaweiboInfo objectForKey:@"UserIDKey"];
        }    }
    return self;
}

- (void)removeAuthData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

- (void)storeAuthData
{
    SinaWeibo *sinaweibo = [BlockSinaWeibo sharedClient].sinaWeibo;
    
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaweibo.accessToken, @"AccessTokenKey",
                              sinaweibo.expirationDate, @"ExpirationDateKey",
                              sinaweibo.userID, @"UserIDKey",
                              sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)loginWithHandler:(void(^)())handler
{
    [BlockSinaWeibo sharedClient].simpleCompletionBlock = handler;
    [[BlockSinaWeibo sharedClient].sinaWeibo logIn];
}

#pragma mark - SinaWeibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogIn userID = %@ accesstoken = %@ expirationDate = %@ refresh_token = %@", sinaweibo.userID, sinaweibo.accessToken, sinaweibo.expirationDate,sinaweibo.refreshToken);
    [self storeAuthData];
    [BlockSinaWeibo sharedClient].simpleCompletionBlock();
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogOut");
    [self removeAuthData];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboLogInDidCancel");
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"sinaweiboAccessTokenInvalidOrExpired %@", error);
    [self removeAuthData];
}


@end
