//
//  RankClient.h
//  rank
//
//  Created by Larry on 10/17/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define RANK_NOTIFICATION @"RankNotification"

@interface RankClient : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) NSData *deviceToken;
@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) CLLocationManager *locationManager;

+ (RankClient *)sharedClient;

+ (NSString *)peer;

+ (void)processRemoteNotification:(NSDictionary *)userInfo;

///////////////////////////////////////////////
+ (void)registerPeerWithToken:(NSData *)token withHandler:(void(^)())handler;

+ (void)updateItem:(NSString *)item withString:(NSString *)value withHandler:(void (^)())handler;

+ (void)submitPhoto:(NSData *)data withHandler:(void (^)(NSString *filename))handler;

+ (void)deletePhoto:(NSString *)photo withHandler:(void(^)())handler;

+ (void)submitBlog:(NSString *)blog inCollege:(NSString *)college withHandler:(void (^)())handler;

+ (void)sendMessage:(NSString *)message toPeer:(NSString *)peer withHandler:(void (^)())handler;

+ (void)getPeerWithPeer:(NSString *)peer withHandler:(void (^)(NSMutableArray *items, NSMutableArray *photos))handler;

+ (void)queryBlogsInCollege:(NSString *)college WithHandler:(void (^)(NSArray *blogs))handler;

+ (void)queryPeersWithPeer:(NSString *)peer WithHandler:(void (^)(NSArray *peers))handler;

+ (void)queryMessagesWithPeerA:(NSString *)pa
                      andTimeA:(NSNumber *)ta
                      andPeerB:(NSString *)pb
                      andTimeB:(NSNumber *)tb
                   withHandler:(void (^)(NSMutableArray *messages))handler;

+ (void)withdrawFromCollege:(NSString *)peer withHandler:(void (^)())handler;

+ (void)updateRelation:(NSNumber *)relation withPeer:(NSString *)peer withHandler:(void (^)())handler;

+ (NSURL *)urlWithPhoto:(NSString *)filename;

+ (UIImage *)imageWithPeer:(NSString *)peer orSex:(NSString *)sex;

- (void)networkUp;

- (void)networkDown;

@end
