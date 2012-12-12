//
//  StatesViewController.m
//  rank
//
//  Created by Larry on 12/11/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "StatesViewController.h"
#import "RankViewController.h"

@interface StatesViewController ()

@property NSArray *states;
@property (strong, nonatomic)NSDictionary *index;
@property (strong, nonatomic)NSDictionary *ranks;
@property (strong, nonatomic)NSArray *colleges;
@end

@implementation StatesViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *ranksURL = [[NSBundle mainBundle] URLForResource:@"list" withExtension:@"json"];
    NSData *ranksData = [NSData dataWithContentsOfURL:ranksURL];
    self.ranks = [NSJSONSerialization JSONObjectWithData:ranksData
                                                 options:NSJSONReadingMutableLeaves error:nil];
    
    self.colleges = [self.ranks.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSURL *statesURL = [[NSBundle mainBundle] URLForResource:@"states" withExtension:@"json"];
    NSData *statesData = [NSData dataWithContentsOfURL:statesURL];
    self.states = [NSJSONSerialization JSONObjectWithData:statesData
                                                  options:NSJSONReadingMutableLeaves error:nil];
    self.index = [self generateIndexForColleges:self.colleges];
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
    return self.states.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StateCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = [[self.states objectAtIndex:indexPath.row] objectAtIndex:0];
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"RankSegue" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"RankSegue"]) {
        NSLog(@"%@",segue.identifier);
        RankViewController *rvc = segue.destinationViewController;
        NSIndexPath *indexPath = sender;
        NSString *state = [[self.states objectAtIndex:indexPath.row] objectAtIndex:0];
        rvc.colleges = [self.index objectForKey:state];
        rvc.ranks = self.ranks;
        return;
    }
    if ([segue.identifier isEqualToString:@"SearchSegue"]) {
        NSLog(@"%@",segue.identifier);
        RankViewController *rvc = segue.destinationViewController;
        rvc.colleges = self.colleges;
        rvc.ranks = self.ranks;
        rvc.searching = YES;
        return;
    }
    if ([segue.identifier isEqualToString:@"HistorySegue"]) {
        NSLog(@"%@",segue.identifier);
        RankViewController *rvc = segue.destinationViewController;
        NSMutableDictionary *history = [[NSUserDefaults standardUserDefaults]objectForKey:@"VisitedColleges"];
        rvc.colleges = [[[history keysSortedByValueUsingSelector:@selector(compare:)]reverseObjectEnumerator]allObjects];
        rvc.ranks = self.ranks;
        return;
    }
}

- (NSMutableDictionary *)generateIndexForColleges:(NSArray *)colleges
{
    NSMutableDictionary *index = [NSMutableDictionary dictionary];
    NSMutableSet *set = [NSMutableSet set];
    for (NSString *college in colleges) {
        NSArray *details = [self.ranks objectForKey:college];
        NSString *state = [details objectAtIndex:0];
        [set addObject:state];
    }
    for (NSString *state in set) {
        [index setObject:[NSMutableArray array] forKey:state];
    }
    for (NSString *college in colleges) {
        NSArray *details = [self.ranks objectForKey:college];
        NSString *state = [details objectAtIndex:0];
        NSMutableArray *stateColleges = [index objectForKey:state];
        [stateColleges addObject:college];
    }
    return index;
}

@end
