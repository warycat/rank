//
//  BlockShare.h
//  rank
//
//  Created by Larry on 1/5/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlockShare : NSObject

+ (BOOL)isAuthValid;

+ (void)shareImage:(UIImage *)image withQRcode:(NSString *)code withText:(NSString *)text;

@end
