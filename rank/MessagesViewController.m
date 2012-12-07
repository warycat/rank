//
//  MessagesViewController.m
//  rank
//
//  Created by Larry on 10/29/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "MessagesViewController.h"
#import "NewMessageViewController.h"
#import "RankClient.h"
#import "AppDelegate.h"
#import "Message.h"

@interface MessagesViewController ()
@property (strong, nonatomic) NSString *pa;
@property (strong, nonatomic) NSString *pb;
@property (readwrite, nonatomic) NSInteger ta;
@property (readwrite, nonatomic) NSInteger tb;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@implementation MessagesViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewMessageSegue"]) {
        NSLog(@"%@",segue.identifier);
        NewMessageViewController *nmvc = segue.destinationViewController;
        nmvc.peer = self.peer;
        nmvc.mvc = self;
        return;
    }
}

- (void)loadMessages
{
    NSArray *messageObjects = self.fetchedResultsController.fetchedObjects;
    for (Message *messageObject in messageObjects) {
        NSDate *time = messageObject.time;
        if ([messageObject.from isEqualToString:self.pa]) {
            self.ta = ((self.ta > time.timeIntervalSince1970 )? self.ta : time.timeIntervalSince1970);
        }
        if ([messageObject.from isEqualToString:self.pb]) {
            self.tb = ((self.tb > time.timeIntervalSince1970 )? self.tb : time.timeIntervalSince1970);
        }
    }
    [RankClient queryMessagesWithPeerA:self.pa
                              andTimeA:[NSNumber numberWithInteger:self.ta]
                              andPeerB:self.pb
                              andTimeB:[NSNumber numberWithInteger:self.tb]
                           withHandler:^(NSMutableArray *messages) {
        for (NSDictionary *message in messages) {
            NSString *peer = [message objectForKey:@"P"];
            NSString *data = [message objectForKey:@"D"];
            NSNumber *time = [message objectForKey:@"T"];
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
            request.predicate = [NSPredicate predicateWithFormat:@"(time == %@) && (data == %@)",[NSDate dateWithTimeIntervalSince1970:time.integerValue],data];
            NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
            if ([results lastObject]) {
                continue;
            }
            Message *messageObject = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
            messageObject.data = data;
            messageObject.time = [NSDate dateWithTimeIntervalSince1970:time.integerValue];
            if ([peer isEqualToString:self.pa]) {
                messageObject.from = self.pa;
                messageObject.to = self.pb;
            }else{
                messageObject.from = self.pb;
                messageObject.to = self.pa;
            }
        }
        [self.managedObjectContext save:nil];
    }];
}

- (void)observeNotification:(NSNotification *)notification
{
    NSString *key = [notification.userInfo objectForKey:@"key"];
    NSString *value = [notification.userInfo objectForKey:@"value"];
    if ([key isEqualToString:@"message"]) {
        if ([value isEqualToString:self.peer]) {
            [self loadMessages];
        }
    }
    if ([key isEqualToString:@"refresh"]) {
        if ([value isEqualToString:@"DismissNewMessage"]) {
            [self loadMessages];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pa = [RankClient peer];
    self.pb = self.peer;
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = app.managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"((to == %@) && (from == %@)) || ((to == %@) && (from == %@))",self.pa,self.pb,self.pb,self.pa];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(observeNotification:) name:RANK_NOTIFICATION object:nil];
    [self loadMessages];
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

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessageCell";
    UITableViewCell *cell;
    if ([tableView respondsToSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)]) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    Message *messageObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = messageObject.data;
    NSString *peer = messageObject.from;
    if ([peer isEqualToString:self.pa]) {
        cell.textLabel.textColor = [UIColor grayColor];
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
    }
    NSDate *time = messageObject.time;
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss"];
    cell.detailTextLabel.text = [df stringFromDate:time];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *messageObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *textString = messageObject.data;
    UIFont *textFont = [UIFont systemFontOfSize:18.0f];
    CGSize textSize = [textString sizeWithFont:textFont constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)];
    CGFloat height = textSize.height + 18.0f + 6.0f;
    return ((height > 44.0)? height : 44.0);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
