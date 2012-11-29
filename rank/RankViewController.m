//
//  RankViewController.m
//  rank
//
//  Created by Larry on 10/16/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "RankViewController.h"
#import "CollegeViewController.h"
#import "CollegeBlogsViewController.h"
#import "WebViewController.h"
#import "RankClient.h"

@interface RankViewController ()

@property (strong, nonatomic)NSDictionary *ranks;
@property (strong, nonatomic)NSArray *states;
@property (strong, nonatomic)NSArray *colleges;
@property (strong, nonatomic)NSMutableArray *filteredColleges;
@property (strong, nonatomic)NSDictionary *index;
@property (strong, nonatomic)NSMutableDictionary *filteredIndex;

@end

@implementation RankViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *ranksURL = [[NSBundle mainBundle] URLForResource:@"list" withExtension:@"json"];
    NSData *ranksData = [NSData dataWithContentsOfURL:ranksURL];
    self.ranks = [NSJSONSerialization JSONObjectWithData:ranksData
                                                 options:NSJSONReadingMutableLeaves error:nil];
    NSURL *statesURL = [[NSBundle mainBundle] URLForResource:@"states" withExtension:@"json"];
    NSData *statesData = [NSData dataWithContentsOfURL:statesURL];
    self.states = [NSJSONSerialization JSONObjectWithData:statesData
                                                  options:NSJSONReadingMutableLeaves error:nil];
    self.colleges = self.ranks.allKeys;
    self.colleges = [self.colleges sortedArrayUsingSelector:@selector(compare:)];
    self.filteredColleges = [NSMutableArray array];
    self.index = [self generateIndexForColleges:self.colleges];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CollegeSegue"]) {
        NSLog(@"%@",segue.identifier);
        UINavigationController *nvc = segue.destinationViewController;
        CollegeViewController *cvc = (CollegeViewController *) nvc.topViewController;
        NSString *college = sender;
        cvc.college = college;
        cvc.details = [self.ranks objectForKey:college];
        return;
    }
    if ([segue.identifier isEqualToString:@"HomeSegue"]) {
        NSLog(@"%@",segue.identifier);
        return;
    }
    if ([segue.identifier isEqualToString:@"CollegeBlogsSegue"]) {
        NSLog(@"%@",segue.identifier);
        CollegeBlogsViewController *cbvc = segue.destinationViewController;
        NSString *college = sender;
        [[NSUserDefaults standardUserDefaults]setObject:college forKey:@"BookmarkedCollege"];
        cbvc.college = college;
        return;
    }
    if ([segue.identifier isEqualToString:@"PeersSegue"]) {
        NSLog(@"%@",segue.identifier);
        return;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return 1;
    }
	else
	{
        return self.states.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        count = self.filteredColleges.count;
        NSLog(@"filterd %d",count);
        return count;
    }
	else
	{
        NSString *state = [[self.states objectAtIndex:section] objectAtIndex:0];
        NSArray *stateColleges = [self.index objectForKey:state];
        return stateColleges.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return nil;
    }
	else
	{
        NSArray *state = [self.states objectAtIndex:section];
        NSString *s = [state objectAtIndex:0];
        return s;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    else
    {
        NSMutableArray *indexTitles = [NSMutableArray array];
        for (NSArray *state in self.states) {
            [indexTitles addObject:[state objectAtIndex:1]];
        }
        return indexTitles;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    }
    else
    {
        return index;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Rank Cell";
    UITableViewCell *cell;
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString *college = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        college = [self.filteredColleges objectAtIndex:indexPath.row];
    }
	else
	{
        NSArray *state = [self.states objectAtIndex:indexPath.section];
        NSArray *stateColleges = [[self.index objectForKey:[state objectAtIndex:0]] sortedArrayUsingSelector:@selector(compare:)];
        college = [stateColleges objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = college;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *college = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        college = [self.filteredColleges objectAtIndex:indexPath.row];
    }
	else
	{
        NSArray *state = [self.states objectAtIndex:indexPath.section];
        NSArray *stateColleges = [[self.index objectForKey:[state objectAtIndex:0]] sortedArrayUsingSelector:@selector(compare:)];
        college = [stateColleges objectAtIndex:indexPath.row];
    }
    [self performSegueWithIdentifier:@"CollegeBlogsSegue" sender:college];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSString *college = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        college = [self.filteredColleges objectAtIndex:indexPath.row];
    }
	else
	{
        NSArray *state = [self.states objectAtIndex:indexPath.section];
        NSArray *stateColleges = [[self.index objectForKey:[state objectAtIndex:0]] sortedArrayUsingSelector:@selector(compare:)];
        college = [stateColleges objectAtIndex:indexPath.row];
    }
    [self performSegueWithIdentifier:@"CollegeSegue" sender:college];
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredColleges removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
    NSArray *components = [searchText componentsSeparatedByString:@" "];
    NSMutableArray *keywords = [NSMutableArray array];
    for (NSString *component in components) {
        if (![component isEqualToString:@""]) {
            [keywords addObject:component];
        }
    }
    NSLog(@"%d",keywords.count);
    for (NSString *college in self.colleges) {
        NSInteger match = 0;
        for (NSString *keyword in keywords) {
            BOOL find = NO;
            NSRange range = [college rangeOfString:keyword];
            if (range.location != NSNotFound) {
                find = YES;
            }else{
                for (NSString *detail in [self.ranks objectForKey:college]) {
                    NSRange range = [detail rangeOfString:keyword];
                    if (range.location != NSNotFound) {
                        find = YES;
                        break;
                    }
                }
            }
            if (find) {
                match++;
            }else{
                break;
            }
        }
        if (match == keywords.count) {
            [self.filteredColleges addObject:college];
        }
    }
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
//    [self filterContentForSearchText:searchString scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    [self filterContentForSearchText:searchString scope:nil];
    NSLog(@"%@",searchString);
    return YES;
}


//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
//{
//    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
//    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
//    
//    // Return YES to cause the search result table view to be reloaded.
//    return YES;
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    NSString *college = [[NSUserDefaults standardUserDefaults]stringForKey:@"BookmarkedCollege"];
    if (college) {
        [self performSegueWithIdentifier:@"CollegeBlogsSegue" sender:college];
    }
}

@end
