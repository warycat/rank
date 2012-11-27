//
//  FriendsViewController.m
//  rank
//
//  Created by Larry on 10/20/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "PeersViewController.h"
#import "RankClient.h"
#import "PeerViewController.h"
#import "MessagesViewController.h"
#import "TDBadgedCell.h"

@interface PeersViewController ()
@property (strong, nonatomic) NSArray *peers;
@end

@implementation PeersViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MessagesSegue"]) {
        NSLog(@"%@",segue.identifier);
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        MessagesViewController *mvc = segue.destinationViewController;
        NSDictionary *dict = [self.peers objectAtIndex:indexPath.row];
        mvc.peer = [dict objectForKey:@"P"];
        return;
    }
    if ([segue.identifier isEqualToString:@"PeerSegue"]) {
        NSLog(@"%@",segue.identifier);
        UINavigationController *nvc = segue.destinationViewController;
        PeerViewController *pvc = (PeerViewController *) nvc.topViewController;
        NSIndexPath *indexPath = sender;
        NSDictionary *dict = [self.peers objectAtIndex:indexPath.row];
        pvc.peer = [dict objectForKey:@"P"];
        pvc.tvc = self;
        pvc.indexPath = indexPath;
        return;
    }
    if ([segue.identifier isEqualToString:@"RelationsSegue"]) {
        NSLog(@"%@",segue.identifier);
        return;
    }
}

- (IBAction)dismissPeers:(id)sender {
    [self.navigationController.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (void)loadPeers
{
    [RankClient queryPeersWithPeer:[RankClient peer] WithHandler:^(NSArray *peers) {
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"T" ascending:NO];
        self.peers = [NSMutableArray arrayWithArray:[peers sortedArrayUsingDescriptors:@[descriptor]]];
        [self.tableView reloadData];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadPeers];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(observeNotification:) name:RANK_NOTIFICATION object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.peers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PeerCell";
    TDBadgedCell *cell;
    if ([tableView respondsToSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)]) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    NSDictionary *peer = [self.peers objectAtIndex:indexPath.row];
    cell.textLabel.text = [peer objectForKey:@"M"];
    NSNumber *date = [peer objectForKey:@"T"];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss"];
    NSString *dateString = [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:date.intValue]];
    NSNumber *I = [peer objectForKey:@"I"];
    NSNumber *O = [peer objectForKey:@"O"];
    if (I.integerValue || O.integerValue) {
        if (I.integerValue) {
            cell.badgeColor = [UIColor purpleColor];
            cell.badgeString = I.stringValue;
        }
        if (O.integerValue) {
            cell.badgeColor = [UIColor orangeColor];
            cell.badgeString = O.stringValue;
        }
    }else{
        cell.badgeColor = [UIColor lightGrayColor];
        cell.badgeString = @"R";
    }
    
    cell.detailTextLabel.text = dateString;
    cell.imageView.image = [RankClient imageWithPeer:[peer objectForKey:@"P"] orSex:nil];
    cell.imageView.gestureRecognizers = @[[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loadPeer:)]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return 128.0f;
    }else {
        return 64.0f;
    }
}


- (void)loadPeer:(UITapGestureRecognizer *)tap
{
    UITableViewCell *cell = (UITableViewCell *)tap.view.superview.superview;
    NSLog(@"%@ %@",tap.view.superview,tap.view);
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self performSegueWithIdentifier:@"PeerSegue" sender:indexPath];
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"PeerSegue" sender:indexPath];
}


- (void)observeNotification:(NSNotification *)notification
{
    NSString *key = [notification.userInfo objectForKey:@"key"];
    NSString *value = [notification.userInfo objectForKey:@"value"];
    if ([key isEqualToString:@"message"]||
        [key isEqualToString:@"receipt"]) {
        [self loadPeers];
    }
    if ([key isEqualToString:@"refresh"]) {
        if ([value isEqualToString:@"DismissNewMessage"]) {
            [self loadPeers];
        }
    }
}


@end
