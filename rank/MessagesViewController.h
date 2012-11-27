//
//  MessagesViewController.h
//  rank
//
//  Created by Larry on 10/29/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface MessagesViewController : CoreDataTableViewController
@property (nonatomic, strong) NSString *peer;
- (void)loadMessages;
@end
