//
//  EditDateViewController.m
//  rank
//
//  Created by Larry on 10/24/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "EditDateViewController.h"
#import "HomeViewController.h"
#import "RankClient.h"

@interface EditDateViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSNumber *time;
@end

@implementation EditDateViewController

- (void)setTime:(NSNumber *)time
{
    _time = time;
    self.date = [NSDate dateWithTimeIntervalSince1970:time.integerValue];
    self.datePicker.date = self.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    self.textView.text = [dateFormatter stringFromDate:self.date];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [self.item objectForKey:@"K"];
    self.time = [self.item objectForKey:@"N"];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTextView:nil];
    [self setDatePicker:nil];
    [super viewDidUnload];
}
- (IBAction)dismissEditDate:(id)sender {
    [self.navigationController.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)confirmEditDate:(id)sender {
    NSLog(@"class %@",self.item.class);
    [self.item setObject:self.time forKey:@"N"];
    UINavigationController *nvc = (UINavigationController *) self.navigationController.presentingViewController;
    HomeViewController *hvc = (HomeViewController *) nvc.topViewController;
    [hvc dismissViewControllerAnimated:YES completion:^{
        [hvc.tableView reloadData];
    }];
    NSNumber *n = [self.item objectForKey:@"N"];
    [RankClient updateItem:[self.item objectForKey:@"K"] withString:n.stringValue withHandler:^() {
    }];
}

- (IBAction)dateChanged:(id)sender {
    self.time = [NSNumber numberWithInteger:self.datePicker.date.timeIntervalSince1970];
}

@end
