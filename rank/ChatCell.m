//
//  ChatCell.m
//  rank
//
//  Created by Larry on 1/3/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import "ChatCell.h"


const CGFloat kTMPhotoQuiltViewMargin = 0;

@implementation ChatCell

@synthesize photoView = _photoView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (FXImageView *)photoView {
    if (!_photoView) {
        _photoView = [[FXImageView alloc] init];
        _photoView.asynchronous = YES;
        _photoView.backgroundColor = [UIColor blackColor];
        _photoView.contentMode = UIViewContentModeCenter;
        _photoView.clipsToBounds = YES;
        [self addSubview:_photoView];
    }
    return _photoView;
}


- (void)layoutSubviews {
    self.photoView.frame = CGRectInset(self.bounds, kTMPhotoQuiltViewMargin, kTMPhotoQuiltViewMargin);
}

@end

