//
//  PeerViewController.h
//  rank
//
//  Created by Larry on 10/20/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeerViewController : UITableViewController
@property (nonatomic, strong) NSString *peer;
@property (nonatomic, weak) UITableViewController *tvc;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end
