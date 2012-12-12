//
//  NewMessageViewController.m
//  rank
//
//  Created by Larry on 10/22/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "NewMessageViewController.h"
#import "RankClient.h"

@interface NewMessageViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation NewMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.textView becomeFirstResponder];
	// Do any additional setup after loading the view.
}

- (IBAction)sendMessage:(id)sender {
    NSString *message = self.textView.text;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [RankClient sendMessage:message toPeer:self.peer withHandler:^() {
        [self.navigationController popViewControllerAnimated:YES];
        [RankClient processRemoteNotification:@{@"refresh":@"DismissNewMessage"}];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return (orientation == UIInterfaceOrientationPortrait );
    }else{
        return YES;
    }
}

@end
