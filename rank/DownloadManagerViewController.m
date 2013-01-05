//
//  DownloadManagerViewController.m
//  rank
//
//  Created by Larry on 12/25/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "DownloadManagerViewController.h"
#import "AppDelegate.h"
#import "RankClient.h"
#import "Download.h"
#import "Download+File.h"
#import "Connection.h"
#import "BlockAlertView.h"
#import "PlayerViewController.h"
#import "BlockShare.h"

@interface DownloadManagerViewController ()

@property (strong, nonatomic) NSMutableDictionary *connections;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSData *audioData;

@end

@implementation DownloadManagerViewController

- (void)observeDownloadNotification:(NSNotification *)notification
{
    NSLog(@"download %@",notification.userInfo);
    NSDictionary *info = notification.userInfo;
    Download *downloadObject = [NSEntityDescription insertNewObjectForEntityForName:@"Download" inManagedObjectContext:self.managedObjectContext];
    downloadObject.name = [info objectForKey:@"name"];
    downloadObject.size = [info objectForKey:@"size"];
    downloadObject.url = [info objectForKey:@"url"];
    downloadObject.type = [info objectForKey:@"type"];
    downloadObject.md5 = [info objectForKey:@"md5"];
    downloadObject.key = [info objectForKey:@"key"];
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    downloadObject.file = uuidStr;
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    [app saveContext];
}

- (void)observeConnectionNotification:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    Download *downloadObject = [info objectForKey:@"object"];
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:downloadObject];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    if ([downloadObject isReady]) {
        [self.connections removeObjectForKey:downloadObject.objectID];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = app.managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Download"];
    NSSortDescriptor *type = [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES];
    NSSortDescriptor *name = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
    fetchRequest.sortDescriptors = @[type,name];
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"type" cacheName:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(observeDownloadNotification:)
                                                name:DOWNLOAD_NOTIFICATION
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(observeConnectionNotification:)
                                                name:CONNECTION_NOTIFICATION
                                              object:nil];
    self.connections = [NSMutableDictionary dictionary];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DownloadCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Download *downloadObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = downloadObject.name;
    if ([downloadObject isReady]) {
        if ([downloadObject.type isEqualToString:@"application/pdf"]) {
            cell.detailTextLabel.text = @"Ready to Read";
        }
        if ([downloadObject.type isEqualToString:@"audio/mpeg"]) {
            cell.detailTextLabel.text = @"Ready to Listen";
        }
    }else{
        Connection *connection = [self.connections objectForKey:downloadObject.objectID];
        if (connection) {
            cell.detailTextLabel.text = connection.detail;
        }else{
            cell.detailTextLabel.text = @"Ready to Download";
        }
    }
    
    
    // Configure the cell...
    
    return cell;
}


// Override to support conditional editing of the table view.

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    Download *downloadObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Connection *connection = [self.connections objectForKey:downloadObject.objectID];
    if (connection) {
        return NO;
    }
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Download *downloadObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[NSFileManager defaultManager] removeItemAtPath:downloadObject.tempURL.path error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:downloadObject.cacheURL.path error:nil];
        [self.managedObjectContext deleteObject:downloadObject];
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        [app saveContext];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Download *downloadObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    BlockAlertView *alert = [[BlockAlertView alloc]initWithTitle:NSLocalizedString(@"ACTION", nil)
                                                         message:downloadObject.key];
    [alert setCancelButtonWithTitle:NSLocalizedString(@"CANCEL", nil) block:^{}];
    if ([downloadObject isReady]) {
        if ([BlockShare isAuthValid]) {
            NSString *url = [@"http://aws.warycat.com/rank/qrcode.php?peer=" stringByAppendingString:[RankClient peer]];
            [BlockShare shareImage:[UIImage imageNamed:@"iTunesArtwork.png"] withQRcode:url withText:downloadObject.key];
            if ([downloadObject.type isEqualToString:@"application/pdf"]) {
                [alert addButtonWithTitle:NSLocalizedString(@"READ", nil) block:^{
                    [self performSegueWithIdentifier:@"PlayerSegue" sender:downloadObject];
                }];
            }else if([downloadObject.type isEqualToString:@"audio/mpeg"]){
                NSData *data = [NSData dataWithContentsOfFile:downloadObject.cacheURL.path];
                if ([self.audioData isEqualToData:data]) {
                    [alert addButtonWithTitle:NSLocalizedString(@"UNLOAD", nil) block:^{
                        self.audioData = nil;
                    }];
                }else{
                    [alert addButtonWithTitle:NSLocalizedString(@"LOAD", nil) block:^{
                        self.audioData = data;
                    }];
                }
            }
            [alert show];
        }else{
            BlockAlertView *alert = [[BlockAlertView alloc]initWithTitle:NSLocalizedString(@"AUTHORIZATION", nil) message:nil];
            [alert setCancelButtonWithTitle:NSLocalizedString(@"OK", nil) block:^{}];
            [alert show];
        }
    }else{
        Connection *connection = [self.connections objectForKey:downloadObject.objectID];
        if (connection) {
            [alert setDestructiveButtonWithTitle:NSLocalizedString(@"STOP", nil) block:^{
                [connection.connection cancel];
                [self.connections removeObjectForKey:downloadObject.objectID];
            }];
        }else{
            [alert addButtonWithTitle:NSLocalizedString(@"DOWNLOAD", nil) block:^{
                Connection *connection = [[Connection alloc]init];
                connection.downloadObject = downloadObject;
                [self.connections setObject:connection forKey:downloadObject.objectID];
                [connection cacheFile];
            }];
        }
        [alert show];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PlayerSegue"]) {
        NSLog(@"%@",segue.identifier);
        PlayerViewController *pvc = segue.destinationViewController;
        Download *downloadObject = sender;
        pvc.data = [NSData dataWithContentsOfFile: downloadObject.cacheURL.path];
        pvc.type = downloadObject.type;
        pvc.audio = self.audioData;
        return;
    }
}

@end
