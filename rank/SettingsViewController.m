//
//  SettingsViewController.m
//  rank
//
//  Created by Larry on 12/11/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "SettingsViewController.h"
#import "BlockAlertView.h"
#import "RankClient.h"
#import "Appirater.h"
#import "WebViewController.h"
#import "BlockRenren.h"
#import "BlockSinaWeibo.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *sinaWeiboLabel;
@property (weak, nonatomic) IBOutlet UILabel *renrenLabel;
@property (nonatomic, strong) ZBarSymbol *symbol;
@end

@implementation SettingsViewController

- (void)updateAuth
{
    if ([BlockSinaWeibo sharedClient].sinaWeibo.isAuthValid) {
        self.sinaWeiboLabel.text = [BlockSinaWeibo sharedClient].sinaWeibo.userID;
    }else{
        self.sinaWeiboLabel.text = NSLocalizedString(@"UNAUTHORIZED", nil);
    }
    if ([Renren sharedRenren].isSessionValid) {
        self.renrenLabel.text = [BlockRenren sharedClient].uid;
    }else{
        self.renrenLabel.text = NSLocalizedString(@"UNAUTHORIZED", nil);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateAuth];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:0]]) {
        [RankClient registerPeerWithToken:[RankClient sharedClient].deviceToken withHandler:^(){
            [RankClient processRemoteNotification:@{@"url":@"http://aws.warycat.com/rank/index.html"}];
        }];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:1 inSection:0]]) {
        ZBarReaderViewController *reader = [ZBarReaderViewController new];
        reader.readerDelegate = self;
        reader.supportedOrientationsMask = ZBarOrientationMaskAll;
        reader.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        [reader.scanner setSymbology: ZBAR_I25
                       config: ZBAR_CFG_ENABLE
                           to: 0];
        [self presentViewController:reader animated:YES completion:^{}];
        return;
    }
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:1]]) {
        if ([[BlockSinaWeibo sharedClient].sinaWeibo isAuthValid]) {
            [[BlockSinaWeibo sharedClient].sinaWeibo logOut];
            [self updateAuth];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }else{
            [BlockSinaWeibo loginWithHandler:^{
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [RankClient updateItem:@"SINAWEIBO"
                            withString:[BlockSinaWeibo sharedClient].sinaWeibo.userID
                           withHandler:^{
                           }];
                [self updateAuth];
            }];
        }
        return;
    }
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:1 inSection:1]]) {
        if ([Renren sharedRenren].isSessionValid) {
            [BlockRenren logout];
            [self updateAuth];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }else{
            [BlockRenren loginWithHandler:^{
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [RankClient updateItem:@"RENREN"
                            withString:[BlockRenren sharedClient].uid
                           withHandler:^{
                           }];
                [self updateAuth];
            }];
        }
        return;
    }
    
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:2]]) {
        [Appirater rateApp];
        return;
    }
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:1 inSection:2]]) {
        WebViewController *wvc = [sb instantiateViewControllerWithIdentifier:@"WebViewController"];
        wvc.URLString = @"http://aws.warycat.com/rank/index.html";
        [self presentModalViewController:wvc animated:NO];
        return;
    }
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:2 inSection:2]]) {
        NSURL *URL = [NSURL URLWithString:@"mailto://larry@warycat.com?subject=Review"];
        [[UIApplication sharedApplication]openURL:URL];
        return;
    }
    
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:3]]) {
        NSURL *URL = [NSURL URLWithString:@"https://itunes.apple.com/us/app/da-xue-wei-bo-wei-xin/id570966012?ls=1&mt=8"];
        [[UIApplication sharedApplication]openURL:URL];
        return;
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    self.symbol = symbol;
    
    [self dismissViewControllerAnimated:YES completion:^{
        UIApplication *app = [UIApplication sharedApplication];
        NSURL *URL = [NSURL URLWithString:symbol.data];
        if ([[URL path]isEqualToString:@"/rank/qrcode.php"]) {
            NSString *query = [URL query];
            query = [query substringFromIndex:5];
            URL = [NSURL URLWithString:[NSString stringWithFormat:@"rank://?%@",query]];
            [app openURL:URL];
            return ;
        }
        BlockAlertView *alertView = [BlockAlertView alertWithTitle:symbol.typeName message:symbol.data];
        [alertView setCancelButtonWithTitle:NSLocalizedString(@"CANCEL", nil) block:^{}];
        if ([app canOpenURL:URL]) {
            [alertView addButtonWithTitle:NSLocalizedString(@"OPEN",nil) block:^{
                [app openURL:URL];
            }];
        }
        [alertView show];
    }];
}


- (void)viewDidUnload {
    [self setSinaWeiboLabel:nil];
    [self setRenrenLabel:nil];
    [super viewDidUnload];
}
@end
