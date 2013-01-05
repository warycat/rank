//
//  ChatsViewController.m
//  rank
//
//  Created by Larry on 1/3/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import "ChatsViewController.h"
#import "ChatCell.h"
#import "BlockSinaWeibo.h"
#import "BlockRenren.h"
#import "BlockAlertView.h"
#import "PeerViewController.h"

const NSInteger kNumberOfCells = 1000;

@interface ChatsViewController ()

@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, retain) NSNumber *count;

@end

@implementation ChatsViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PeerSegue"]) {
        NSLog(@"%@",segue.identifier);
        UINavigationController *nvc = segue.destinationViewController;
        PeerViewController *pvc = (PeerViewController *) nvc.topViewController;
        NSIndexPath *indexPath = sender;
        NSDictionary *dict = [self.photos objectAtIndex:indexPath.row];
        pvc.peer = [dict objectForKey:@"P"];
        pvc.indexPath = indexPath;
        return;
    }
}


#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *URL = [NSURL URLWithString:@"http://aws.warycat.com/rank/scan_photos.php"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        self.photos = [dict objectForKey:@"Photos"];
        self.count = [dict objectForKey:@"Count"];
        [self.quiltView reloadData];
    }];
    self.quiltView.backgroundColor = [UIColor blackColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - QuiltViewControllerDataSource

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return self.count.integerValue;
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    ChatCell *cell = (ChatCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"];
    if (!cell) {
        cell = [[ChatCell alloc] initWithReuseIdentifier:@"PhotoCell"];
    }
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    NSString *url = [NSString stringWithFormat:@"http://s3-us-west-1.amazonaws.com/california.com.warycat.rank.photo/%@_",[photo objectForKey:@"F"]];
    [cell.photoView setImageWithContentsOfURL:[NSURL URLWithString:url]];
    return cell;
}

#pragma mark - TMQuiltViewDelegate

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
        || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            return 6;
        }else{
            return 13;
        }
    } else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            return 4;
        }else{
            return 10;
        }
    }
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d",indexPath.row);
    if ([Renren sharedRenren].isSessionValid || [BlockSinaWeibo sharedClient].sinaWeibo.isAuthValid) {
        [self performSegueWithIdentifier:@"PeerSegue" sender:indexPath];
    }else{
        BlockAlertView *alert = [[BlockAlertView alloc]initWithTitle:NSLocalizedString(@"AUTHORIZATION", nil) message:nil];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"OK",nil) block:^{}];
        [alert show];
    }
}


@end

