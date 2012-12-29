//
//  PlayerViewController.m
//  rank
//
//  Created by Larry on 12/28/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface PlayerViewController ()

@property (nonatomic, strong) AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *exitButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *playButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *pauseButtonItem;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@interface PlayerViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation PlayerViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.audio) {
        self.toolbar.items = @[self.exitButtonItem];
    }else{
        NSMutableArray *items = [self.toolbar.items mutableCopy];
        [items removeObject:self.pauseButtonItem];
        self.toolbar.items = items;
        self.player = [[AVAudioPlayer alloc]initWithData:self.audio error:nil];
        self.slider.maximumValue = self.player.duration;
        self.slider.value = 0.0f;
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];

    }
    [self.webView loadData:self.data MIMEType:self.type textEncodingName:nil baseURL:nil];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateTime:(NSTimer *)timer {
    self.slider.value = self.player.currentTime;
}
- (IBAction)slide:(id)sender {
    self.player.currentTime = self.slider.value;
}

- (IBAction)play:(id)sender {
    [self.player play];
    NSMutableArray *items = [self.toolbar.items mutableCopy];
    [items removeObject:self.playButtonItem];
    [items addObject:self.pauseButtonItem];
    self.toolbar.items = items;
    self.slider.userInteractionEnabled = NO;
}

- (IBAction)pause:(id)sender {
    [self.player pause];
    NSMutableArray *items = [self.toolbar.items mutableCopy];
    [items removeObject:self.pauseButtonItem];
    [items addObject:self.playButtonItem];
    self.toolbar.items = items;
    self.slider.userInteractionEnabled = YES;
}

- (IBAction)dismissPlayer:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setToolbar:nil];
    [self setExitButtonItem:nil];
    [self setPlayButtonItem:nil];
    [self setPauseButtonItem:nil];
    [self setSlider:nil];
    [super viewDidUnload];
}
@end
