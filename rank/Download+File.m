//
//  Download+File.m
//  rank
//
//  Created by Larry on 12/28/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "Download+File.h"

@implementation Download (File)
- (NSURL *)URL
{
    return [NSURL URLWithString:self.url];
}

- (NSURLRequest *)request
{
    return [NSURLRequest requestWithURL:[self URL]];
}

- (NSURL *)tempURL
{
    NSString *url = [NSTemporaryDirectory() stringByAppendingPathComponent:self.file];
    return [NSURL URLWithString:url];
}

- (NSURL *)cacheURL
{
    NSURL *URL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    return [NSURL URLWithString:self.file relativeToURL:URL];
}

- (BOOL)isReady
{
    return [[NSFileManager defaultManager]fileExistsAtPath:self.cacheURL.path];
}

@end
