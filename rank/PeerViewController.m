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
{
    BOOL isShowingLandscapeView;
}
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
    isShowingLandscapeView = NO;
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        NSLog(@"pad");
    }else {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
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
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if (self.items) {
            return 2;
        }else{
            return 1;
        }
    }else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if (section == 0) {
            return self.items.count;
        }
        if (section == 1) {
            return 1;
        }
        return 0;
    }else {
        return self.items.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return nil;
    }else {
        if (self.items) {
            return [NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"ROTATE DEVICE FOR PHOTOS", nil),self.photos.count];
        }
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if (indexPath.section == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"PHOTOS", nil),self.photos.count];
            return cell;
        }
    }
    static NSString *CellIdentifier = @"ProfileCell";
    UITableViewCell *cell;
    if ([tableView respondsToSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)]) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    NSDictionary *dict = [self.items objectAtIndex:indexPath.row];
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


- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
        !isShowingLandscapeView)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self performSegueWithIdentifier:@"CoverFlowSegue" sender:self];
        isShowingLandscapeView = YES;
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
             isShowingLandscapeView)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self dismissViewControllerAnimated:YES completion:nil];
        isShowingLandscapeView = NO;
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (indexPath.section == 1) {
            [self performSegueWithIdentifier:@"CoverFlowSegue" sender:self];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)goBack:(id)sender {
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self.tvc.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

@end
