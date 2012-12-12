//
//  CommentViewController.m
//  rank
//
//  Created by Larry on 10/17/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "CollegeBlogsViewController.h"
#import "RankClient.h"
#import "NewBlogViewController.h"
#import "BlogViewController.h"
#import "PeerViewController.h"
#import "TDBadgedCell.h"

@interface CollegeBlogsViewController ()
@property (strong, nonatomic) NSArray *blogs;
@end

@implementation CollegeBlogsViewController


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewBlogSegue"]) {
        NSLog(@"%@",segue.identifier);
        NewBlogViewController *nbvc = segue.destinationViewController;
        nbvc.cbvc = self;
        nbvc.college = self.college;
        return;
    }
    if ([segue.identifier isEqualToString:@"BlogSegue"]) {
        NSLog(@"%@",segue.identifier);
        UITableViewCell *cell = sender;
        BlogViewController *bvc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSDictionary *blog = [self.blogs objectAtIndex:indexPath.row];
        bvc.blog = [blog objectForKey:@"B"];
        NSNumber *latitude = [blog objectForKey:@"A"];
        NSNumber *longitude = [blog objectForKey:@"O"];
        if (latitude && longitude) {
            bvc.location = [[CLLocation alloc]initWithLatitude:latitude.doubleValue longitude:longitude.doubleValue];
        }
        
        return;
    }
    if ([segue.identifier isEqualToString:@"PeerSegue"]) {
        NSLog(@"%@",segue.identifier);
        UINavigationController *nvc = segue.destinationViewController;
        PeerViewController *pvc = (PeerViewController *)nvc.topViewController;
        NSIndexPath *indexPath = sender;
        NSDictionary *blog = [self.blogs objectAtIndex:indexPath.row];
        pvc.peer = [blog objectForKey:@"P"];
        pvc.indexPath = indexPath;
        pvc.tvc = self;
        NSLog(@"%@ %d",pvc.peer,indexPath.row);
        return;
    }
}

- (void)loadBlogs
{
    [RankClient queryBlogsInCollege:self.college WithHandler:^(NSArray *blogs) {
        NSLog(@"get blogs ok %@",blogs);
        if (blogs.count) {
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"T" ascending:NO];
            self.blogs = [blogs sortedArrayUsingDescriptors:@[descriptor]];
        }else{
            NSDictionary *firstBlog = @{@"P":[RankClient peer],@"T":[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]],@"B":NSLocalizedString(@"FIRSTBLOG", nil)};
            self.blogs = [NSArray arrayWithObject:firstBlog];
        }
        [self.tableView reloadData];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.college;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadBlogs];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    self.blogs = nil;
//    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.blogs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BlogCell";
    TDBadgedCell *cell;
    if ([tableView respondsToSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)]) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    NSDictionary *blog = [self.blogs objectAtIndex:indexPath.row];
    cell.textLabel.text = [blog objectForKey:@"B"];
    NSNumber *date = [blog objectForKey:@"T"];
    NSNumber *latitude = [blog objectForKey:@"A"];
    NSNumber *longitude = [blog objectForKey:@"O"];
    NSString *detailString = nil;
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss"];
    detailString = [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:date.intValue]];
    if (latitude && longitude) {
        CLLocation *location = [[CLLocation alloc]initWithLatitude:latitude.doubleValue longitude:longitude.doubleValue];
        CLLocationDistance distance = [location distanceFromLocation:[RankClient sharedClient].locationManager.location];
        detailString = [NSString stringWithFormat:@"%@",detailString];
        cell.badgeString = [NSString stringWithFormat:@"%.0f m",distance];
        cell.badgeColor = [UIColor orangeColor];
    }
    cell.detailTextLabel.text = detailString;
    cell.imageView.gestureRecognizers = @[[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loadPeer:)]];
    cell.imageView.image = [RankClient imageWithPeer:[blog objectForKey:@"P"] orSex:[blog objectForKey:@"S"]];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
      *detailViewController = [[ alloc] initWithNibName:@"   " bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
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
    NSLog(@"indexPath %@",indexPath);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return 128.0f;
    }else {
        return 64.0f;
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

@end
