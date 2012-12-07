//
//  PeerViewController.m
//  rank
//
//  Created by Larry on 10/20/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "PeerViewController.h"
#import "RankClient.h"
#import "CoverFlowViewController.h"
#import "NewMessageViewController.h"

@interface PeerViewController ()
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableArray *photos;
@end

@implementation PeerViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewMessageSegue"]) {
        NSLog(@"%@",segue.identifier);
        NewMessageViewController *nmvc = segue.destinationViewController;
        nmvc.peer = self.peer;
        return;
    }
    if ([segue.identifier isEqualToString:@"CoverFlowSegue"]) {
        NSLog(@"%@",segue.identifier);
        CoverFlowViewController *cfvc = segue.destinationViewController;
        cfvc.photos = self.photos;
        cfvc.peer = self.peer;
        cfvc.editing = NO;
        return;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadData];
}

- (void)reloadData
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [RankClient getPeerWithPeer:self.peer withHandler:^(NSMutableArray *items, NSMutableArray *photos) {
        self.items = items;
        self.photos = photos;
        [self.tableView reloadData];
        if (![self.peer isEqualToString:[RankClient peer]]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.items) {
        return 2;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.items.count;
    }
    if (section == 1) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"SET_ICON_PHOTO", nil)];
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PHOTOS", nil),self.photos.count];
        return cell;
    }
    static NSString *CellIdentifier = @"ProfileCell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary *dict = [self.items objectAtIndex:indexPath.row];
    if ([self hasActionWithKey:[dict objectForKey:@"K"]]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = NSLocalizedString([dict objectForKey:@"K"],nil);
    NSString *S = [dict objectForKey:@"S"];
    if (S) {
        cell.detailTextLabel.text = S;
        return cell;
    }
    NSString *N = [dict objectForKey:@"N"];
    if (N) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        cell.detailTextLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:N.integerValue]];
    }
    return cell;
}

- (BOOL)hasActionWithKey:(NSString *)key
{
    if ([key isEqualToString:@"EMAIL"]) {
        return YES;
    }
    if ([key isEqualToString:@"PHONE"]) {
        return YES;
    }
    if ([key isEqualToString:@"FACETIME"]) {
        return YES;
    }
    return NO;
}

- (void)performActionWithKey:(NSString *)key andValue:(NSString *)value
{
    NSURL *URL = nil;
    if ([key isEqualToString:@"EMAIL"]) {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@",value]];
    }
    if ([key isEqualToString:@"PHONE"]) {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",value]];
    }
    if ([key isEqualToString:@"FACETIME"]) {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"facetime://%@",value]];
    }
    if (URL) {
        [[UIApplication sharedApplication]openURL:URL];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return NO;
    }else {
        return (orientation == UIInterfaceOrientationPortrait );
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        [self performSegueWithIdentifier:@"CoverFlowSegue" sender:self];
    }
    NSDictionary *dict = [self.items objectAtIndex:indexPath.row];
    if ([self hasActionWithKey:[dict objectForKey:@"K"]]) {
        [self performActionWithKey:[dict objectForKey:@"K"] andValue:[dict objectForKey:@"S"]];
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (IBAction)goBack:(id)sender {
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self.tvc.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

@end
