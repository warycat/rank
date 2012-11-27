//
//  WebViewController.m
//  rank
//
//  Created by Larry on 11/21/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "WebViewController.h"
#import "RankClient.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *URL = [NSURL URLWithString:self.URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
	// Do any additional setup after loading the view.
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[RankClient sharedClient] networkUp];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[RankClient sharedClient] networkDown];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[RankClient sharedClient] networkDown];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissWebView:(id)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)refreshWebView:(id)sender {
    [self.webView reload];
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}
@end
