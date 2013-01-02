//
//  Connection.m
//  rank
//
//  Created by Larry on 12/27/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "Connection.h"
#import "RankClient.h"
#import "DownloadManagerViewController.h"
#import "NSFileMD5Hash.h"

@interface Connection ()

@property (nonatomic, strong) NSFileHandle *fileHandle;

@end

@implementation Connection

- (void)cacheFile
{
    NSLog(@"%@",self.downloadObject.tempURL.path);
    if ([[NSFileManager defaultManager]createFileAtPath:self.downloadObject.tempURL.path
                                               contents:nil attributes:nil]) {
        Download *downloadObject = self.downloadObject;
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:downloadObject.tempURL.path];
        
        self.connection = [NSURLConnection connectionWithRequest:downloadObject.request
                                                                    delegate:self];
        [self.connection start];
        [[RankClient sharedClient] networkUp];
    }else{
        NSLog(@"Error was code: %d - message: %s", errno, strerror(errno));
    }
}

#pragma mark - connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog( @"%s" , (char *) _cmd );
    [self.fileHandle writeData:data];
    double progress = self.fileHandle.offsetInFile * 100.0 / self.downloadObject.size.integerValue;
    NSLog(@"%f",progress);
    self.detail = [NSString stringWithFormat:@"%.1f%%",progress];
    NSDictionary *userInfo = @{@"object":self.downloadObject,@"state":@"receive"};
    [[NSNotificationCenter defaultCenter]postNotificationName:CONNECTION_NOTIFICATION
                                                       object:nil
                                                     userInfo:userInfo];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog( @"%s" , (char *) _cmd );
    [self.fileHandle closeFile];
    NSString *md5 = [NSFileMD5Hash md5AtPath:self.downloadObject.tempURL.path];
    if ([md5 isEqualToString:self.downloadObject.md5]) {
        [[NSFileManager defaultManager] moveItemAtPath:self.downloadObject.tempURL.path
                                                toPath:self.downloadObject.cacheURL.path
                                                 error:nil];
        self.detail = @"Ready to open";
    }else{
        NSLog(@"%@ %@",md5,self.downloadObject.md5);
        [[NSFileManager defaultManager] removeItemAtPath:self.downloadObject.tempURL.path
                                                   error:nil];
        self.detail = @"Authorization Expire";
    }
    [[RankClient sharedClient] networkDown];
    NSDictionary *userInfo = @{@"object":self.downloadObject,@"state":@"finish"};
    [[NSNotificationCenter defaultCenter]postNotificationName:CONNECTION_NOTIFICATION
                                                       object:nil
                                                     userInfo:userInfo];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog( @"%s" , (char *) _cmd );
    [self.fileHandle closeFile];
    [[RankClient sharedClient] networkDown];
    self.detail = @"Connection Error";
    NSDictionary *userInfo = @{@"object":self.downloadObject,@"state":@"fail"};
    [[NSNotificationCenter defaultCenter]postNotificationName:CONNECTION_NOTIFICATION
                                                       object:nil
                                                     userInfo:userInfo];
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
