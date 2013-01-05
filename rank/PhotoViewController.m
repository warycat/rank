//
//  PhotoViewController.m
//  rank
//
//  Created by Larry on 10/30/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "PhotoViewController.h"
#import "RankClient.h"
#import "AppDelegate.h"
#import "BlockShare.h"
#import "BlockAlertView.h"
#import "BlockTextPromptAlertView.h"
#import "FXImageView.h"
#import "Barcode.h"

@interface PhotoViewController ()
@property (weak, nonatomic) IBOutlet FXImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *sinaWeiboImage;
@property (strong, nonatomic) UIImage *renrenImage;

@end

@implementation PhotoViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *URL = [RankClient urlWithPhoto:self.photo];
    self.imageView.asynchronous = NO;
    [self.imageView setImageWithContentsOfURL:URL];
    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:nil error:nil];
    UIImage *image = [UIImage imageWithData:data];
//    NSString *url = [@"http://aws.warycat.com/rank/qrcode.php?peer=" stringByAppendingString:self.peer];
//    Barcode *barcode = [[Barcode alloc] init];
//    [barcode setupQRCode:url];
    self.image = image;
    
//    CGSize sinaWeiboSize = CGSizeMake(image.size.width, image.size.height * 2);
//    UIGraphicsBeginImageContext( sinaWeiboSize );
//    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
//    [barcode.qRBarcode drawInRect:CGRectMake(0,image.size.height,image.size.width,image.size.height)];
//    self.sinaWeiboImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    CGSize renrenSize = CGSizeMake(image.size.width * 2, image.size.height);
//    UIGraphicsBeginImageContext( renrenSize );
//    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
//    [barcode.qRBarcode drawInRect:CGRectMake(image.size.width,0,image.size.width,image.size.height)];
//    self.renrenImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    UIImage *thumbnail = [self imageWithImage:image ByScalingAndCroppingForSize:[self thumbnailsize]];
    NSData *thumbnailData = UIImageJPEGRepresentation(thumbnail, 1.0f);
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    NSURL *fileURL = [[app applicationDocumentsDirectory] URLByAppendingPathComponent:self.peer];
    [thumbnailData writeToURL:fileURL atomically:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissPhotoView:(id)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)sharePeer:(id)sender {
    if ([BlockShare isAuthValid]) {
        BlockTextPromptAlertView *alert = [[BlockTextPromptAlertView alloc]initWithTitle:NSLocalizedString(@"SHARE", nil)
                                                                                 message:nil
                                                                             defaultText:nil];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"CANCEL", nil) block:^{}];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", nil) block:^{
            NSString *url = [@"http://aws.warycat.com/rank/qrcode.php?peer=" stringByAppendingString:self.peer];
            [BlockShare shareImage:self.image withQRcode:url withText:alert.textField.text];
//            if ([Renren sharedRenren].isSessionValid) {
//                [BlockRenrenRequest publishPhoto:self.renrenImage withCaption:alert.textField.text
//                                     withHandler:^(id result){
//                                         NSLog(@"%@",result);
//                                     }];
//            }
//            if ([BlockSinaWeibo sharedClient].sinaWeibo.isAuthValid) {
//                [BlockSinaWeiboRequest POSTrequestAPI:@"statuses/upload.json"
//                                           withParams:@{@"status":alert.textField.text,@"pic":self.sinaWeiboImage}
//                                          withHandler:^(id result){
//                                              NSLog(@"%@",result);
//                                          }];
//            }
        }];
        [alert show];
    }else{
        BlockAlertView *alert = [[BlockAlertView alloc]initWithTitle:NSLocalizedString(@"AUTHORIZATION", nil) message:nil];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"OK", nil) block:^{}];
        [alert show];
    }
    NSLog(@"%@ %@",self.peer,self.photo);
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (UIImage *)imageWithImage:(UIImage *)sourceImage ByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (CGSize)thumbnailsize
{
    CGFloat size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        size = 128.0f;
    }else{
        size = 64.0f;
    }
    size = size *[UIScreen mainScreen].scale;
    return CGSizeMake(size, size);
}



@end
