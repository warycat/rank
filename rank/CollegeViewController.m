//
//  CollegeViewController.m
//  rank
//
//  Created by Larry on 10/22/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "CollegeViewController.h"
#import "RankClient.h"

@interface CollegeViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation CollegeViewController

- (IBAction)dismissCollege:(id)sender {
    [self.navigationController.presentingViewController dismissModalViewControllerAnimated:YES];
}

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
    self.title = self.college;
    NSMutableString *text = [NSMutableString string];
    for (NSString *detail in self.details) {
        [text appendFormat:@"%@\n",detail];
    }
    self.textView.text = text;
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
