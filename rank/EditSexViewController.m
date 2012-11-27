//
//  EditSexViewController.m
//  rank
//
//  Created by Larry on 10/24/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "EditSexViewController.h"
#import "HomeViewController.h"
#import "RankClient.h"

@interface EditSexViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *maleCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *femaleCell;
@property (nonatomic, strong) NSString *sex;
@end

@implementation EditSexViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setSex:(NSString *)sex
{
    if ([sex isEqualToString:NSLocalizedString(@"MALE", nil)]) {
        self.maleCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.femaleCell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([sex isEqualToString:NSLocalizedString(@"FEMALE", nil)]) {
        self.maleCell.accessoryType = UITableViewCellAccessoryNone;
        self.femaleCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    _sex = sex;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [self.item objectForKey:@"K"];
    self.sex = [self.item objectForKey:@"S"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.maleCell) {
        self.sex = NSLocalizedString(@"MALE", nil);
    }
    if (cell == self.femaleCell) {
        self.sex = NSLocalizedString(@"FEMALE", nil);
    }
    NSLog(@"%@",self.sex);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)dismissEditSex:(id)sender {
    [self.navigationController.presentingViewController dismissModalViewControllerAnimated:YES];    
}

- (IBAction)confirmEditSex:(id)sender {
    [self.item setObject:self.sex forKey:@"S"];
    UINavigationController *nvc = (UINavigationController *) self.navigationController.presentingViewController;
    HomeViewController *hvc = (HomeViewController *) nvc.topViewController;
    [hvc dismissViewControllerAnimated:YES completion:^{
        [hvc.tableView reloadData];
    }];
    [RankClient updateItem:[self.item objectForKey:@"K"] withString:[self.item objectForKey:@"S"] withHandler:^() {
    }];
}


- (void)viewDidUnload {
    [self setMaleCell:nil];
    [self setFemaleCell:nil];
    [super viewDidUnload];
}
@end
