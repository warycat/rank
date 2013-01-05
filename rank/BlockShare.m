//
//  BlockShare.m
//  rank
//
//  Created by Larry on 1/5/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import "BlockShare.h"
#import "BlockRenren.h"
#import "BlockSinaWeibo.h"
#import "BlockRenrenRequest.h"
#import "BlockSinaWeiboRequest.h"
#import "Barcode.h"

@implementation BlockShare

+ (BOOL)isAuthValid
{
    return [BlockSinaWeibo sharedClient].sinaWeibo.isAuthValid || [Renren sharedRenren].isSessionValid;
}

+ (void)shareImage:(UIImage *)image withQRcode:(NSString *)code withText:(NSString *)text
{
    Barcode *barcode = [[Barcode alloc] init];
    [barcode setupQRCode:code];
    CGSize sinaWeiboSize = CGSizeMake(image.size.width, image.size.height * 2);
    UIGraphicsBeginImageContext( sinaWeiboSize );
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    [barcode.qRBarcode drawInRect:CGRectMake(0,image.size.height,image.size.width,image.size.height)];
    UIImage *sinaWeiboImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGSize renrenSize = CGSizeMake(image.size.width * 2, image.size.height);
    UIGraphicsBeginImageContext( renrenSize );
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    [barcode.qRBarcode drawInRect:CGRectMake(image.size.width,0,image.size.width,image.size.height)];
    UIImage *renrenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if ([Renren sharedRenren].isSessionValid) {
        [BlockRenrenRequest publishPhoto:renrenImage withCaption:text
                             withHandler:^(id result){
                                 NSLog(@"%@",result);
                             }];
    }
    if ([BlockSinaWeibo sharedClient].sinaWeibo.isAuthValid) {
        [BlockSinaWeiboRequest POSTrequestAPI:@"statuses/upload.json"
                                   withParams:@{@"status":text,@"pic":sinaWeiboImage}
                                  withHandler:^(id result){
                                      NSLog(@"%@",result);
                                  }];
    }
}


@end
