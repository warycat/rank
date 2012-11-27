//
//  BlogViewController.h
//  rank
//
//  Created by Larry on 10/22/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface BlogViewController : UIViewController
@property (nonatomic, strong) NSString *blog;
@property (nonatomic, strong) CLLocation *location;
@end
