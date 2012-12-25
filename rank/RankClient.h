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

#ifdef DEBUG
#define BASE_URL @"http://dev.warycat.com"
#else
#define BASE_URL @"http://aws.warycat.com"
#endif

#define APP_URL @"/rank"
#define COMMENT_URL @"/comment.php"
#define REGISTER_PHP @"/register.php"
#define SUBMIT_BLOG_PHP @"/submit_blog.php"
#define QUERY_BLOGS_PHP @"/query_blogs.php"
#define UPDATE_BLOG_PHP @"/update_blog.php"
#define GET_PEER_PHP @"/get_peer.php"
#define QUERY_PEERS_PHP @"/query_peers.php"
#define QUERY_MESSAGES_PHP @"/query_messages.php"
#define UPDATE_PEER_PHP @"/update_peer.php"
#define UPLOAD_PHOTO_PHP @"/upload_photo.php"
#define SEND_MESSAGE_PHP @"/send_message.php"
#define DELETE_PHOTO_PHP @"/delete_photo.php"
#define UPDATE_RELATION_PHP @"/update_relation.php"
#define LIST_FILES_PHP @"/list_files.php"
#define PHOTO_URL @"http://s3-us-west-1.amazonaws.com/california.com.warycat.rank.photo/"

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

+ (void)listFilesWithPrefix:(NSString *)prefix withHandler:(void (^)(NSArray *folders, NSArray *files))handler;

+ (NSURL *)urlWithPhoto:(NSString *)filename;

+ (UIImage *)imageWithPeer:(NSString *)peer orSex:(NSString *)sex;

- (void)networkUp;

- (void)networkDown;

@end
