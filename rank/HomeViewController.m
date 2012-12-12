//
//  HomeViewController.m
//  rank
//
//  Created by Larry on 10/22/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "RankClient.h"
#import "EditStringViewController.h"
#import "EditSexViewController.h"
#import "EditDateViewController.h"
#import "CoverFlowViewController.h"

@interface HomeViewController ()

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSMutableDictionary *item;
@property (strong, nonatomic) NSArray *itemKeys;
@property (strong, nonatomic) NSDictionary *identifiers;
@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.itemKeys = @[
        @"NICKNAME",
        @"SEX",
        @"BIRTHDAY",
        @"PHONE",
        @"FACETIME",
        @"EMAIL",
        @"ALIPAY",
    
        @"CITY",
        @"COLLEGE",
        @"COMPANY",
        @"PROFESSION",
        @"HOBBY",
    
        @"QQ",
        @"SINAWEIBO",
        @"RENREN",
        @"DOUBAN",
    ];
    self.identifiers = @{
        @"NICKNAME":@"EditStringSegue",
        @"SEX":@"EditSexSegue",
        @"BIRTHDAY":@"EditDateSegue",
        @"PHONE":@"EditStringSegue",
        @"EMAIL":@"EditStringSegue",
        @"FACETIME":@"EditStringSegue",
        @"ALIPAY":@"EditStringSegue",
    
        @"CITY":@"EditStringSegue",
        @"COLLEGE":@"EditStringSegue",
        @"COMPANY":@"EditStringSegue",
        @"PROFESSION":@"EditStringSegue",
        @"HOBBY":@"EditStringSegue",
    
        @"QQ":@"EditStringSegue",
        @"SINAWEIBO":@"EditStringSegue",
        @"RENREN":@"EditStringSegue",
        @"DOUBAN":@"EditStringSegue",
    };

    self.tableView.allowsSelectionDuringEditing = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(observeNotification:) name:RANK_NOTIFICATION object:nil];
    [self loadPeer];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)loadPeer
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.editing = NO;
    [RankClient getPeerWithPeer:[RankClient peer] withHandler:^(NSMutableArray *items, NSMutableArray *photos) {
        self.items = items;
        self.photos = photos;
        [self.tableView reloadData];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if (!self.items.count) {
            [self enterEditMode:nil];
        }
    }];
}

- (void)observeNotification:(NSNotification *)notification
{
    if (self.tableView.isEditing) {
        return;
    }
    NSString *key = [notification.userInfo objectForKey:@"key"];
    NSString *value = [notification.userInfo objectForKey:@"value"];
    if ([key isEqualToString:@"refresh"]) {
        if ([value isEqualToString:@"DismissCoverFlow"]) {
            [self loadPeer];
        }
    }
    if ([key isEqualToString:@"authToken"]) {
        [self loadPeer];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return (orientation == UIInterfaceOrientationPortrait );
    }else{
        return YES;
    }
}

- (IBAction)enterEditMode:(id)sender {
    if (self.tableView.isEditing) {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"EDIT", nil);
        NSInteger row = [self.items indexOfObjectIdenticalTo:self.item];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.items removeObjectIdenticalTo:self.item];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView setEditing:NO animated:YES];
        [self loadPeer];
    }else{
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"DONE", nil);
        self.item = [NSMutableDictionary dictionaryWithDictionary:@{
            @"K":@"ADD",
            @"S":NSLocalizedString(@"MYINFO", nil),
            @"N":@0}];
        [self.items addObject:self.item];
        NSInteger row = [self.items indexOfObjectIdenticalTo:self.item];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView setEditing:YES animated:YES];
    }
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


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [self.items objectAtIndex:indexPath.row];
    if (item == self.item) {
        return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"ADD_AND_DELETE_PHOTOS", nil)];
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PHOTOS", nil),self.photos.count];
        return cell;
    }
    static NSString *CellIdentifier = @"ProfileCell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSLog(@"delete %@",indexPath);
        NSDictionary *item = [self.items objectAtIndex:indexPath.row];
        [self.items removeObjectIdenticalTo:item];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [RankClient updateItem:[item objectForKey:@"K"] withString:@"" withHandler:^() {            
        }];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        NSLog(@"insert %@",indexPath);
        [self insertNewItemAtIndexPath:indexPath];
    }   
}

- (void)insertNewItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *cIndexPath = [indexPath copy];
    NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithObjects:@[@"",@"",@""]
                                                                      forKeys:@[@"K",@"S",@"N"]];;

    BOOL find;
    for (NSString *newItemKey in self.itemKeys) {
        find = NO;
        for (NSMutableDictionary *item in self.items) {
            NSString *itemKey = [item objectForKey:@"K"];
            if ([itemKey isEqualToString:newItemKey]) {
                find = YES;
                break;
            }
        }
        if (!find) {
            newItem = [NSMutableDictionary dictionaryWithObjects:@[newItemKey,@"",@""]
                                               forKeys:@[@"K",@"S",@"N"]];
            if ([newItem isEqual:@{@"K":@"",@"S":@"",@"N":@""}]) {
                continue;
            }
            [self.items insertObject:newItem atIndex:cIndexPath.row];
            [self.tableView insertRowsAtIndexPaths:@[cIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            cIndexPath = [NSIndexPath indexPathForRow:cIndexPath.row+1 inSection:cIndexPath.section];
        }
    }
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing) {
        if (indexPath.section == 1) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        NSMutableDictionary *item = [self.items objectAtIndex:indexPath.row];
        if (item == self.item) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self insertNewItemAtIndexPath:indexPath];
        }else{
            NSString *key = [item objectForKey:@"K"];
            NSString *identifier = [self.identifiers objectForKey:key];
            if (identifier) {
                [self performSegueWithIdentifier:identifier sender:indexPath];
            }else{
                [self performSegueWithIdentifier:@"EditPairSegue" sender:indexPath];
            }
        }
    }else{
        if (indexPath.section == 1) {
            [self performSegueWithIdentifier:@"CoverFlowSegue" sender:self];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditStringSegue"]) {
        NSLog(@"%@",segue.identifier);
        UINavigationController *nvc = segue.destinationViewController;
        EditStringViewController *esvc = (EditStringViewController *) nvc.topViewController;
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        esvc.item = [self.items objectAtIndex:indexPath.row];
    }
    if ([segue.identifier isEqualToString:@"EditSexSegue"]) {
        NSLog(@"%@",segue.identifier);
        UINavigationController *nvc = segue.destinationViewController;
        EditSexViewController *esvc = (EditSexViewController *) nvc.topViewController;
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        esvc.item = [self.items objectAtIndex:indexPath.row];
    }
    if ([segue.identifier isEqualToString:@"EditDateSegue"]) {
        NSLog(@"%@",segue.identifier);
        UINavigationController *nvc = segue.destinationViewController;
        EditDateViewController *esvc = (EditDateViewController *) nvc.topViewController;
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        esvc.item = [self.items objectAtIndex:indexPath.row];
    }
    if ([segue.identifier isEqualToString:@"CoverFlowSegue"]) {
        NSLog(@"%@",segue.identifier);
        CoverFlowViewController *cfvc = segue.destinationViewController;
        cfvc.editing = YES;
        cfvc.photos = self.photos;
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
