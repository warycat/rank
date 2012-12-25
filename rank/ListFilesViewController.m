//
//  ListFilesViewController.m
//  rank
//
//  Created by Larry on 12/25/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "ListFilesViewController.h"
#import "RankClient.h"
#import "BlockAlertView.h"

@interface ListFilesViewController ()

@property (nonatomic, strong) NSArray *files;
@property (nonatomic, strong) NSArray *folders;

@end

@implementation ListFilesViewController

- (NSString *)prefix
{
    if (!_prefix) {
        _prefix = @"";
    }
    return _prefix;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [RankClient listFilesWithPrefix:self.prefix withHandler:^(NSArray *folders, NSArray *files) {
        self.folders = folders;
        self.files = files;
        [self.tableView reloadData];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.folders.count;
        case 1:
            return self.files.count;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            if (self.folders.count) {
                return NSLocalizedString(@"FOLDER", nil);
            }
            return nil;
        }
        case 1:
        {
            if (self.files.count) {
                return NSLocalizedString(@"FILE", nil);
            }
            return nil;
        }
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            static NSString *CellIdentifier = @"FolderCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            NSDictionary *folder = [self.folders objectAtIndex:indexPath.row];
            cell.textLabel.text = [folder objectForKey:@"Prefix"];
            return cell;
        }
            break;
        case 1:
        {
            static NSString *CellIdentifier = @"FileCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            NSDictionary *file = [self.files objectAtIndex:indexPath.row];
            cell.textLabel.text = [file objectForKey:@"Key"];
            NSNumber *size = [file objectForKey:@"Size"];
            cell.detailTextLabel.text = [self unitStringFromBytes:size.doubleValue];
            return cell;
        }
            break;
            
        default:
            break;
    }
    return nil;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
            ListFilesViewController *lvc = [sb instantiateViewControllerWithIdentifier:@"ListFilesViewController"];
            NSDictionary *folder = [self.folders objectAtIndex:indexPath.row];
            lvc.title = [folder objectForKey:@"Prefix"];
            NSString *prefix = [self.prefix stringByAppendingString:[folder objectForKey:@"Prefix"]];
            lvc.prefix = prefix;
            [self.navigationController pushViewController:lvc animated:YES];
        }
            break;
        case 1:
        {
            NSDictionary *file = [self.files objectAtIndex:indexPath.row];
            NSNumber *size = [file objectForKey:@"Size"];
            NSString *key = [file objectForKey:@"Key"];
            BlockAlertView *alert = [[BlockAlertView alloc]initWithTitle:NSLocalizedString(@"DOWNLOAD", nil)
                                                               message:key];
            [alert setCancelButtonWithTitle:NSLocalizedString(@"CANCEL", nil) block:^{}];
            [alert addButtonWithTitle:[self unitStringFromBytes:size.doubleValue] block:^{
                ;
            }];
            [alert show];
        }
            break;
        default:
            break;
    }

}

- (NSString*) unitStringFromBytes:(double) bytes
{
    
    static const char units[] = { '\0', 'k', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y' };
    static int maxUnits = sizeof units - 1;
    
    int multiplier = 1000;
    int exponent = 0;
    
    while (bytes >= multiplier && exponent < maxUnits) {
        bytes /= multiplier;
        exponent++;
    }
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    // Beware of reusing this format string. -[NSString stringWithFormat] ignores \0, *printf does not.
    return [NSString stringWithFormat:@"%@ %cB", [formatter stringFromNumber: [NSNumber numberWithDouble: bytes]], units[exponent]];
}

@end
