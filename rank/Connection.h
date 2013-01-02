//
//  Connection.h
//  rank
//
//  Created by Larry on 12/27/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Download.h"
#import "Download+File.h"

@interface Connection : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, strong) Download *downloadObject;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSString *detail;

- (void)cacheFile;

@end
