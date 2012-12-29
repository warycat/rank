//
//  NSFileMD5Hash.m
//  iVirusU
//
//  Created by jack xia on 3/20/12.
//  Copyright (c) 2012 hsefz. All rights reserved.
//

#import "NSFileMD5Hash.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NSFileMD5Hash

+ (NSData *)hashAtPath:(NSString *)path
{
    NSFileHandle *input = [NSFileHandle fileHandleForReadingAtPath:path];
    if (!input) {
        return nil;
    }
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Feed the data to the hash object
    while (true) {
        NSData *data = [input readDataOfLength:FileHashDefaultChunkSizeForReadingData];
        if (data.length == 0) {
            break;
        }
        CC_MD5_Update(&hashObject, data.bytes, data.length);
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    return [NSData dataWithBytes:&digest length:CC_MD5_DIGEST_LENGTH];
}

+ (NSString *)md5AtPath:(NSString *)path
{
    NSFileHandle *input = [NSFileHandle fileHandleForReadingAtPath:path];
    if (!input) {
        return nil;
    }
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Feed the data to the hash object
    while (true) {
        NSData *data = [input readDataOfLength:FileHashDefaultChunkSizeForReadingData];
        if (data.length == 0) {
            break;
        }
        CC_MD5_Update(&hashObject, data.bytes, data.length);
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    NSData *data = [NSData dataWithBytes:&digest length:CC_MD5_DIGEST_LENGTH];
    NSString* dataString = [data description];
    dataString = [dataString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    dataString = [dataString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return dataString;
}

@end
