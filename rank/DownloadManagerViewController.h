//
//  DownloadManagerViewController.h
//  rank
//
//  Created by Larry on 12/25/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

#define DOWNLOAD_NOTIFICATION @"DownloadNotification"
#define CONNECTION_NOTIFICATION @"ConnectionNotification"

@interface DownloadManagerViewController : CoreDataTableViewController <NSURLConnectionDataDelegate>


@end
