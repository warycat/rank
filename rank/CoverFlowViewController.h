//
//  CoverFlowViewController.h
//  rank
//
//  Created by Larry on 10/26/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface CoverFlowViewController : UIViewController <iCarouselDataSource, iCarouselDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSString *peer;
@property (nonatomic) BOOL editing;
@end
