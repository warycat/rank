//
//  EditStringViewController.m
//  rank
//
//  Created by Larry on 10/24/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "EditStringViewController.h"
#import "HomeViewController.h"
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
    self.textView.text = [self.item objectForKey:@"S"];
    self.title = NSLocalizedString([self.item objectForKey:@"K"],nil);
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
    [self.navigationController.presentingViewController dismissModalViewControllerAnimated:YES];
}
- (IBAction)confirmEditString:(id)sender {
    [self.item setObject:self.textView.text forKey:@"S"];
    UINavigationController *nvc = (UINavigationController *) self.navigationController.presentingViewController;
    HomeViewController *hvc = (HomeViewController *) nvc.topViewController;
    [hvc dismissViewControllerAnimated:YES completion:^{
        [hvc.tableView reloadData];
    }];
    [RankClient updateItem:[self.item objectForKey:@"K"] withString:[self.item objectForKey:@"S"] withHandler:^() {
    }];
}

- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}
@end
