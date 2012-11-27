//
//  WebViewController.h
//  rank
//
//  Created by Larry on 11/21/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSString *URLString;

@end
