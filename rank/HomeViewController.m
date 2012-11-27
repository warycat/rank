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
{
    BOOL isShowingLandscapeView;
}

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSMutableDictionary *item;
@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsSelectionDuringEditing = YES;
    isShowingLandscapeView = NO;
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        NSLog(@"pad");
    }else {
        NSLog(@"phone");
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
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
    [RankClient getPeerWithPeer:[RankClient peer] withHandler:^(NSMutableArray *items, NSMutableArray *photos) {
        self.items = items;
        self.photos = photos;
        [self.tableView reloadData];
        self.navigationItem.rightBarButtonItem.enabled = YES;
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
        [self dismissViewControllerAnimated:YES completion:^{
        }];
        isShowingLandscapeView = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return (orientation == UIInterfaceOrientationPortrait );
}

- (IBAction)enterEditMode:(id)sender {
    if (self.tableView.isEditing) {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"EDIT", nil);
        NSInteger row = [self.items indexOfObjectIdenticalTo:self.item];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.items removeObjectIdenticalTo:self.item];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView setEditing:NO animated:YES];
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
    NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithObjects:@[@"",@"",@""]
                                                                      forKeys:@[@"K",@"S",@"N"]];;
    NSArray *newItemKeys = @[
        @"NICKNAME",
        @"SEX",
        @"BIRTHDAY",
        @"CITY",
        @"COLLEGE",
    
        @"COMPANY",
        @"PROFESSION",
        @"HOBBY",
        @"EMAIL",
        @"PHONE",
    
        @"QQ",
        @"FACETIME",
        @"SINAWEIBO",
        @"RENREN",
        @"DOUBAN",
    ];
    BOOL find;
    for (NSString *newItemKey in newItemKeys) {
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
            break;
        }
    }
    if ([newItem isEqual:@{@"K":@"",@"S":@"",@"N":@""}]) {
        return;
    }
    [self.items insertObject:newItem atIndex:indexPath.row];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.items exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (indexPath.section == 1) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                return;
            }
        }
        NSMutableDictionary *item = [self.items objectAtIndex:indexPath.row];
        if (item == self.item) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }else{
            NSString *key = [item objectForKey:@"K"];
            NSDictionary *identifiers = @{
            @"NICKNAME":@"EditStringSegue",
            @"SEX":@"EditSexSegue",
            @"BIRTHDAY":@"EditDateSegue",
            @"CITY":@"EditStringSegue",
            @"COLLEGE":@"EditStringSegue",
            @"COMPANY":@"EditStringSegue",
            @"PROFESSION":@"EditStringSegue",
            @"HOBBY":@"EditStringSegue",
            @"QQ":@"EditStringSegue",
            @"PHONE":@"EditStringSegue",
            @"EMAIL":@"EditStringSegue",
            @"FACETIME":@"EditStringSegue",
            @"SINAWEIBO":@"EditStringSegue",
            @"RENREN":@"EditStringSegue",
            @"DOUBAN":@"EditStringSegue",
            };
            NSString *identifier = [identifiers objectForKey:key];
            if (identifier) {
                [self performSegueWithIdentifier:identifier sender:indexPath];
            }else{
                [self performSegueWithIdentifier:@"EditPairSegue" sender:indexPath];
            }
        }
    }else{
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (indexPath.section == 1) {
                [self performSegueWithIdentifier:@"CoverFlowSegue" sender:self];
            }
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
