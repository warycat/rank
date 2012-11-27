//
//  MyBlogViewController.m
//  rank
//
//  Created by Larry on 10/19/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "NewBlogViewController.h"
#import "RankClient.h"

@interface NewBlogViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation NewBlogViewController

- (IBAction)submitBlog:(id)sender {
    NSString *blog = self.textView.text;
    UIButton *button = sender;
    button.enabled = NO;
    if (blog) {
        [RankClient submitBlog:blog inCollege:self.college withHandler:^() {
            [self.navigationController popViewControllerAnimated:YES];
            [self.cbvc loadBlogs];
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@",self.college);
    [self.textView becomeFirstResponder];

	// Do any additional setup after loading the view.
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

@end
