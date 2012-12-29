//
//  NSFileMD5Hash.h
//  iVirusU
//
//  Created by jack xia on 3/20/12.
//  Copyright (c) 2012 hsefz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FileHashDefaultChunkSizeForReadingData 4096


@interface NSFileMD5Hash : NSObject

+ (NSData *)hashAtPath:(NSString *)path;
+ (NSString *)md5AtPath:(NSString *)path;

@end
