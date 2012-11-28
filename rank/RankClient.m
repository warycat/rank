//
//  RankClient.m
//  rank
//
//  Created by Larry on 10/17/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "RankClient.h"
#import "NSString+Base64.h"
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonHMAC.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"

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
#define PHOTO_URL @"http://s3-us-west-1.amazonaws.com/california.com.warycat.rank.photo/"


static SystemSoundID Basso;
static SystemSoundID Blow;
static SystemSoundID Bottle;
static SystemSoundID Frog;
static SystemSoundID Funk;
static SystemSoundID Glass;
static SystemSoundID Hero;
static SystemSoundID Morse;
static SystemSoundID Ping;
static SystemSoundID Pop;
static SystemSoundID Purr;
static SystemSoundID Sosumi;
static SystemSoundID Submarine;
static SystemSoundID Tink;

@interface RankClient ()
{
    NSInteger network;
}

@end

@implementation RankClient

- (NSString *)authToken{
    if (_authToken) {
        return _authToken;
    }
    return @"";
}

+ (void)playSound:(NSString *)sound
{
    if ([sound isEqualToString:@"Basso"]) AudioServicesPlaySystemSound(Basso);
    if ([sound isEqualToString:@"Blow"]) AudioServicesPlaySystemSound(Blow);
    if ([sound isEqualToString:@"Bottle"]) AudioServicesPlaySystemSound(Bottle);
    if ([sound isEqualToString:@"Frog"]) AudioServicesPlaySystemSound(Frog);
    if ([sound isEqualToString:@"Funk"]) AudioServicesPlaySystemSound(Funk);
    if ([sound isEqualToString:@"Glass"]) AudioServicesPlaySystemSound(Glass);
    if ([sound isEqualToString:@"Hero"]) AudioServicesPlaySystemSound(Hero);
    if ([sound isEqualToString:@"Morse"]) AudioServicesPlaySystemSound(Morse);
    if ([sound isEqualToString:@"Ping"]) AudioServicesPlaySystemSound(Ping);
    if ([sound isEqualToString:@"Pop"]) AudioServicesPlaySystemSound(Pop);
    if ([sound isEqualToString:@"Purr"]) AudioServicesPlaySystemSound(Purr);
    if ([sound isEqualToString:@"Sosumi"]) AudioServicesPlaySystemSound(Sosumi);
    if ([sound isEqualToString:@"Submarine"]) AudioServicesPlaySystemSound(Submarine);
    if ([sound isEqualToString:@"Tink"]) AudioServicesPlaySystemSound(Tink);
}

- (void)networkUp
{
    network++;
    if (network) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

- (void)networkDown
{
    network--;
    if (!network) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

+ (RankClient *)sharedClient
{
    static RankClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RankClient alloc] init];
        // Do any other initialisation stuff here
        sharedInstance.locationManager = [[CLLocationManager alloc]init];
        sharedInstance.locationManager.delegate = sharedInstance;
        [sharedInstance.locationManager startMonitoringSignificantLocationChanges];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"Basso" withExtension:@"aiff"], &Basso);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"Blow" withExtension:@"aiff"], &Blow);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"Bottle" withExtension:@"aiff"], &Bottle);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"Frog" withExtension:@"aiff"], &Frog);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"Funk" withExtension:@"aiff"], &Funk);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"Glass" withExtension:@"aiff"], &Glass);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"Hero" withExtension:@"aiff"], &Hero);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"Morse" withExtension:@"aiff"], &Morse);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"Ping" withExtension:@"aiff"], &Ping);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"Pop" withExtension:@"aiff"], &Pop);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"Purr" withExtension:@"aiff"], &Purr);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"Sosumi" withExtension:@"aiff"], &Sosumi);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"Submarine" withExtension:@"aiff"], &Submarine);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"Tink" withExtension:@"aiff"], &Tink);
    });
    return sharedInstance;
}

+ (void)processRemoteNotification:(NSDictionary *)userInfo
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    NSLog(@"notification %@",userInfo);
    if ([userInfo objectForKey:@"authToken"]) {
        [RankClient sharedClient].authToken = [userInfo objectForKey:@"authToken"];
        [RankClient playSound:@"Glass"];
    }
    if ([userInfo objectForKey:@"message"]) {
        [RankClient playSound:@"Submarine"];
        [[NSNotificationCenter defaultCenter] postNotificationName:RANK_NOTIFICATION
                                                            object:nil
                                                          userInfo:@{@"key":@"message",@"value":[userInfo objectForKey:@"message"]}];
    }
    if ([userInfo objectForKey:@"receipt"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RANK_NOTIFICATION
                                                            object:nil
                                                          userInfo:@{@"key":@"receipt",@"value":[userInfo objectForKey:@"receipt"]}];
    }
    if ([userInfo objectForKey:@"url"]) {
        [RankClient playSound:@"Sosumi"];
        [[NSNotificationCenter defaultCenter] postNotificationName:RANK_NOTIFICATION
                                                            object:nil
                                                          userInfo:@{@"key":@"url",@"value":[userInfo objectForKey:@"url"]}];
    }
    if ([userInfo objectForKey:@"refresh"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RANK_NOTIFICATION
                                                            object:nil
                                                          userInfo:@{@"key":@"refresh",@"value":[userInfo objectForKey:@"refresh"]}];
    }
}


+ (NSString *)peer
{
    NSString* tokenString = [[RankClient sharedClient].deviceToken description];
    tokenString = [tokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return tokenString;
}

+ (NSURL *)URLwithPHP:(NSString *)php andDictionary:(NSDictionary *)dict
{
    NSMutableDictionary *GET = [NSMutableDictionary dictionaryWithDictionary:dict];
    [GET setObject:[RankClient peer] forKey:@"deviceToken"];
    [GET setObject:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
    if (dict) {
        NSMutableString *raw = [NSMutableString string];
        for (NSString *key in [GET.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
            [raw appendFormat:@"%@%@",key,[GET objectForKey:key]];
        }
        NSData *data = hmacForKeyAndData([RankClient sharedClient].authToken, [raw base64EncodedString]);
        NSString *signiture = [[data description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        signiture = [signiture stringByReplacingOccurrencesOfString:@" " withString:@""];
        [GET setObject:signiture forKey:@"signiture"];
    }
    NSMutableString *string = [NSMutableString stringWithFormat:@"%@%@%@?",BASE_URL,APP_URL,php];
    for (NSString *key in GET) {
        NSString *sourceString = [GET objectForKey:key];
        NSString *urlEncoded = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(__bridge CFStringRef)sourceString,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8);
        [string appendFormat:@"%@=%@&",key,urlEncoded];
    }
    NSLog(@"%@",string);
    [RankClient playSound:@"Pop"];
    return [NSURL URLWithString:string];
}

+ (id)processResponse:(NSURLResponse *)response withData:(NSData *)data withError:(NSError *)error
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (error) {
        NSLog(@"%@",error);
        return nil;
    }
    id object = [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingMutableContainers
                                                  error:&error];
    if (error) {
        error = [NSError errorWithDomain:@"RANK_JSON_DECODE_ERROR" code:httpResponse.statusCode userInfo:nil];
        NSLog(@"%@",error);
        return nil;
    }
    
    if (httpResponse.statusCode != 200){
        error = [NSError errorWithDomain:@"RANK_STATUS_CODE_ERROR" code:httpResponse.statusCode userInfo:nil];
        NSLog(@"%@",object);
        [RankClient playSound:@"Sosumi"];
        return nil;
    }
    [RankClient playSound:@"Tink"];
    return object;
}

+ (void)registerPeerWithToken:(NSData *)token withHandler:(void(^)())handler
{
    NSLog(@"register %@",token);
    [RankClient sharedClient].deviceToken = token;
    NSURL *URL = [RankClient URLwithPHP:REGISTER_PHP andDictionary:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [[RankClient sharedClient] networkUp];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[RankClient sharedClient] networkDown];
        NSDictionary *result = [RankClient processResponse:response withData:data withError:error];
        if (result) {
            NSLog(@"register ok %@",result);
            handler();
        }
    }];
}

+ (void)updateItem:(NSString *)item withString:(NSString *)value withHandler:(void (^)())handler
{
    NSURL *URL = [self URLwithPHP:UPDATE_PEER_PHP andDictionary:@{@"item":item,@"value":value}];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [[RankClient sharedClient] networkUp];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[RankClient sharedClient] networkDown];
        NSDictionary *result = [RankClient processResponse:response withData:data withError:error];
        if (result) {
            NSLog(@"update item ok %@",result);
            handler();
        }
    }];
}


+ (void)submitPhoto:(NSData *)data withHandler:(void (^)(NSString *filename))handler
{
    NSString *md5 = [RankClient md5WithData:data];
    NSNumber *size = [NSNumber numberWithInteger:data.length];
    NSURL *URL = [self URLwithPHP:UPLOAD_PHOTO_PHP
                    andDictionary:@{@"size":size.stringValue,@"md5":md5}];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = data;
    [[RankClient sharedClient] networkUp];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[RankClient sharedClient] networkDown];
        NSDictionary *result = [RankClient processResponse:response withData:data withError:error];
        if (result) {
            NSLog(@"submit photo ok %@",result);
            handler([result objectForKey:@"filename"]);
        }
    }];
}

+ (void)submitBlog:(NSString *)blog inCollege:(NSString *)college withHandler:(void (^)())handler
{
    CLLocation *location = [RankClient sharedClient].locationManager.location;
    NSString *latitude = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    NSLog(@"location %@",location);
    NSURL *URL = [self URLwithPHP:UPDATE_BLOG_PHP
                    andDictionary:@{
                  @"college":college,
                  @"blog":blog,
                  @"latitude":latitude,
                  @"longitude":longitude}];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [[RankClient sharedClient] networkUp];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[RankClient sharedClient] networkDown];
        NSDictionary *result = [RankClient processResponse:response withData:data withError:error];
        if (result) {
            NSLog(@"submit blog ok %@",result);
            handler();
        }
    }];
}

+ (void)deletePhoto:(NSString *)photo withHandler:(void(^)())handler
{
    NSURL *URL = [self URLwithPHP:DELETE_PHOTO_PHP
                    andDictionary:@{@"photo":photo}];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [[RankClient sharedClient] networkUp];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[RankClient sharedClient] networkDown];
        NSDictionary *result = [RankClient processResponse:response withData:data withError:error];
        if (result) {
            NSLog(@"delete photo ok %@",result);
            handler();
        }
    }];
}

+ (void)sendMessage:(NSString *)message toPeer:(NSString *)peer withHandler:(void (^)())handler
{
    NSURL *URL = [self URLwithPHP:SEND_MESSAGE_PHP
                    andDictionary:@{@"message":message,@"peer":peer}];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [[RankClient sharedClient] networkUp];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[RankClient sharedClient] networkDown];
        NSDictionary *result = [self processResponse:response withData:data withError:error];
        if (result) {
            NSLog(@"send message ok %@",result);
            handler();
        }
    }];
}

+ (void)getPeerWithPeer:(NSString *)peer withHandler:(void (^)(NSMutableArray *, NSMutableArray *))handler
{
    NSURL *URL = [self URLwithPHP:GET_PEER_PHP andDictionary:@{@"peer":peer}];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [[RankClient sharedClient] networkUp];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[RankClient sharedClient] networkDown];
        NSDictionary *result = [RankClient processResponse:response withData:data withError:error];
        if (result) {
            NSLog(@"get peer ok %@",result);
            NSMutableArray *items = [[result objectForKey:@"Items"] mutableCopy];
            NSMutableArray *photos = [[result objectForKey:@"Photos"] mutableCopy];
            handler(items,photos);
        }
    }];
    
}

+ (void)queryBlogsInCollege:(NSString *)college WithHandler:(void (^)(NSArray *blogs))handler
{
    NSURL *URL = [self URLwithPHP:QUERY_BLOGS_PHP andDictionary:@{@"college":college}];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [[RankClient sharedClient] networkUp];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[RankClient sharedClient] networkDown];
        NSDictionary *result = [RankClient processResponse:response withData:data withError:error];
        if (result) {
            NSLog(@"%@",result);
            NSMutableArray *blogs = [[result objectForKey:@"Blogs"] mutableCopy];
            handler(blogs);
        }
    }];
}

+ (void)queryPeersWithPeer:(NSString *)peer WithHandler:(void (^)(NSArray *peers))handler
{
    NSURL *URL = [self URLwithPHP:QUERY_PEERS_PHP andDictionary:@{@"peer":peer}];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [[RankClient sharedClient] networkUp];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[RankClient sharedClient] networkDown];
        NSDictionary *result = [RankClient processResponse:response withData:data withError:error];
        if (result) {
            NSLog(@"query peers ok %@",result);
            NSArray *peers = [result objectForKey:@"Peers"];
            handler(peers);
        }
    }];
}

+ (void)queryMessagesWithPeerA:(NSString *)pa andTimeA:(NSNumber *)ta andPeerB:(NSString *)pb andTimeB:(NSNumber *)tb withHandler:(void (^)(NSMutableArray *messages))handler;
{
    NSURL *URL = [self URLwithPHP:QUERY_MESSAGES_PHP andDictionary:@{
                  @"pa":pa,
                  @"ta":ta.stringValue,
                  @"pb":pb,
                  @"tb":tb.stringValue,
                  }];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [[RankClient sharedClient] networkUp];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[RankClient sharedClient] networkDown];
        NSDictionary *result = [RankClient processResponse:response withData:data withError:error];
        if (result) {
            NSLog(@"query messages ok %@",result);
            NSMutableArray *messages = [[result objectForKey:@"Messages"] mutableCopy];
            handler(messages);
        }
    }];
}

+ (void)withdrawFromCollege:(NSString *)peer withHandler:(void (^)())handler
{

}

+ (void)updateRelation:(NSNumber *)relation withPeer:(NSString *)peer withHandler:(void (^)())handler
{
    NSURL *URL = [self URLwithPHP:UPDATE_RELATION_PHP andDictionary:@{@"peer":peer,@"relation":relation.stringValue}];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [[RankClient sharedClient] networkUp];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[RankClient sharedClient] networkDown];
        NSDictionary *result = [RankClient processResponse:response withData:data withError:error];
        if (result) {
            NSLog(@"update relation ok %@",result);
            handler();
        }
    }];
}


+ (NSURL *)urlWithPhoto:(NSString *)filename
{
    NSURL *URL = [NSURL URLWithString:PHOTO_URL];
    URL = [NSURL URLWithString:filename relativeToURL:URL];
    return URL;
}

NSData *hmacForKeyAndData(NSString *key, NSString *data)
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}

+ (NSString*)md5WithData:(NSData *)data
{
 	// Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
	// Create 16 byte MD5 hash value, store in buffer
    CC_MD5(data.bytes, data.length, md5Buffer);
    
	// Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

+ (UIImage *)imageWithPeer:(NSString *)peer orSex:(NSString *)sex
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    NSURL *fileURL = [[app applicationDocumentsDirectory] URLByAppendingPathComponent:peer];
    NSData *imageData = [NSData dataWithContentsOfURL:fileURL];

    if (imageData) {
        return [UIImage imageWithData:imageData];
    }else{
        NSString *S = sex;
        if ([S isEqualToString:NSLocalizedString(@"MALE", nil)]) {
            return [UIImage imageNamed:@"Sex-Male-icon.png"];
        }
        if ([S isEqualToString:NSLocalizedString(@"FEMALE", nil)]) {
            return [UIImage imageNamed:@"Sex-Female-icon.png"];
        }
    }
    return [UIImage imageNamed:@"Sex-Male-Female-icon.png"];
}


@end
