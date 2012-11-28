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

@interface PhotoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *URL = [RankClient urlWithPhoto:self.photo];
    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:nil error:nil];
    UIImage *image = [UIImage imageWithData:data];
    self.imageView.image = image;
    UIImage *thumbnail = [self imageWithImage:image ByScalingAndCroppingForSize:[self thumbnailsize]];
    NSData *thumbnailData = UIImageJPEGRepresentation(thumbnail, 1.0f);
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    NSURL *fileURL = [[app applicationDocumentsDirectory] URLByAppendingPathComponent:self.peer];
    [thumbnailData writeToURL:fileURL atomically:YES];
//    [[NSUserDefaults standardUserDefaults]setObject:thumbnailData forKey:self.peer];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissPhotoView:(id)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
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
