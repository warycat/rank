//
//  Download+File.h
//  rank
//
//  Created by Larry on 12/28/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "Download.h"

@interface Download (File)
- (NSURL *)URL;
- (NSURLRequest *)request;
- (NSURL *)tempURL;
- (NSURL *)cacheURL;
- (BOOL)isReady;
@end
