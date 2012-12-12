//
//  RankViewController.h
//  rank
//
//  Created by Larry on 10/16/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RankViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSDictionary *ranks;
@property (strong, nonatomic) NSArray *colleges;
@property (readwrite) BOOL searching;
@end
