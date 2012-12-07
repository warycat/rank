//
//  RelationViewController.m
//  rank
//
//  Created by Larry on 11/24/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "RelationsViewController.h"
#import "TDBadgedCell.h"
#import "RankClient.h"

@interface RelationsViewController ()
@property (nonatomic, strong) NSMutableArray *peers;
@property (nonatomic, strong) NSString *selectedPeer;
@end

@implementation RelationsViewController

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
    NSNumber *X = [peer objectForKey:@"X"];
    if (X.intValue) {
        cell.badgeColor = [UIColor blackColor];
        cell.badgeString = @"X";
    }else{
        cell.badgeColor = [UIColor greenColor];
        cell.badgeString = @"√";
    }
    cell.detailTextLabel.text = dateString;
    cell.imageView.image = [RankClient imageWithPeer:[peer objectForKey:@"P"] orSex:nil];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *peer = [self.peers objectAtIndex:indexPath.row];
    self.selectedPeer = [peer objectForKey:@"P"];
    NSNumber *cross = [peer objectForKey:@"X"];
    UIBarButtonItem *button = nil;
    if (cross.intValue) {
        button = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"NOTICE", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(notice:)];
    }else{
        button = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"IGNORE", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(ignore:)];
    }
    self.navigationItem.rightBarButtonItem = button;
}

- (void)notice:(NSString *)peer
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [RankClient updateRelation:[NSNumber numberWithBool:NO] withPeer:self.selectedPeer withHandler:^{
        self.navigationItem.rightBarButtonItem = nil;
        [self loadPeers];
    }];
}

- (void)ignore:(NSString *)peer
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [RankClient updateRelation:[NSNumber numberWithBool:YES] withPeer:self.selectedPeer withHandler:^{
        self.navigationItem.rightBarButtonItem = nil;
        [self loadPeers];
    }];
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
