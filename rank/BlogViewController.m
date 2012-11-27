//
//  BlogViewController.m
//  rank
//
//  Created by Larry on 10/22/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "BlogViewController.h"
#import "MapViewController.h"

@interface BlogViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation BlogViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MapSegue"]) {
        NSLog(@"%@",segue.identifier);
        MapViewController *mvc = segue.destinationViewController;
        mvc.location = self.location;
        return;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.text = self.blog;
    if (!self.location) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
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
