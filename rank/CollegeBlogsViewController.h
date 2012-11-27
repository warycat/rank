//
//  CommentViewController.h
//  rank
//
//  Created by Larry on 10/17/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollegeBlogsViewController : UITableViewController <UIAlertViewDelegate>
@property (strong, nonatomic) NSString *college;
- (void)loadBlogs;
@end
