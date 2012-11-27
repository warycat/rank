//
//  NewMessageViewController.h
//  rank
//
//  Created by Larry on 10/22/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessagesViewController.h"

@interface NewMessageViewController : UIViewController
@property (nonatomic, strong)NSString *peer;
@property (nonatomic, weak) MessagesViewController *mvc;
@end
