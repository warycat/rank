//
//  EditStringViewController.m
//  rank
//
//  Created by Larry on 10/24/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "EditStringViewController.h"
#import "RankClient.h"

@interface EditStringViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation EditStringViewController

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
    self.title = NSLocalizedString([self.item objectForKey:@"K"],nil);
    self.textView.text = [self.item objectForKey:@"S"];
    NSDictionary *keyboardsTypes = @{
        @"NICKNAME":[NSNumber numberWithInt:UIKeyboardTypeDefault],
        @"CITY":[NSNumber numberWithInt:UIKeyboardTypeDefault],
        @"COLLEGE":[NSNumber numberWithInt:UIKeyboardTypeDefault],
        @"COMPANY":[NSNumber numberWithInt:UIKeyboardTypeDefault],
        @"PROFESSION":[NSNumber numberWithInt:UIKeyboardTypeDefault],
        @"HOBBY":[NSNumber numberWithInt:UIKeyboardTypeDefault],
        @"QQ":[NSNumber numberWithInt:UIKeyboardTypeNumberPad],
        @"PHONE":[NSNumber numberWithInt:UIKeyboardTypePhonePad],
        @"EMAIL":[NSNumber numberWithInt:UIKeyboardTypeEmailAddress],
        @"FACETIME":[NSNumber numberWithInt:UIKeyboardTypeEmailAddress],
        @"SINAWEIBO":[NSNumber numberWithInt:UIKeyboardTypeDefault],
        @"RENREN":[NSNumber numberWithInt:UIKeyboardTypeDefault],
        @"DOUBAN":[NSNumber numberWithInt:UIKeyboardTypeEmailAddress]};
    NSNumber *keyboard = [keyboardsTypes objectForKey:[self.item objectForKey:@"K"]];
    self.textView.keyboardType = keyboard.intValue;
    [self.textView becomeFirstResponder];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissEditString:(id)sender {
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)confirmEditString:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.item setObject:self.textView.text forKey:@"S"];
    [RankClient updateItem:[self.item objectForKey:@"K"] withString:[self.item objectForKey:@"S"] withHandler:^() {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
    }];
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
