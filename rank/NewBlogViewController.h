//
//  MyBlogViewController.h
//  rank
//
//  Created by Larry on 10/19/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollegeBlogsViewController.h"

@interface NewBlogViewController : UIViewController
@property (strong, nonatomic) NSString *college;
@property (weak, nonatomic) CollegeBlogsViewController *cbvc;
@end
