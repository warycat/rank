//
//  CoverFlowViewController.m
//  rank
//
//  Created by Larry on 10/26/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "CoverFlowViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "FXImageView.h"
#import "UIImage+FX.h"
#import "RankClient.h"
#import "PhotoViewController.h"

@interface CoverFlowViewController ()

@property (weak, nonatomic) IBOutlet iCarousel *iCarousel;
@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) UIPopoverController *popover;
@end

@implementation CoverFlowViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PhotoSegue"]) {
        NSLog(@"%@",segue.identifier);
        PhotoViewController *pvc = segue.destinationViewController;
        NSString *photo = [self.photos objectAtIndex:self.iCarousel.currentItemIndex];
        pvc.photo = photo;
        pvc.peer = self.peer;
        return;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.editing && (self.photos.count == 0)) {
        self.photos = [NSMutableArray array];
        [self.photos addObject:@""];
        [self.iCarousel reloadData];
    }
    self.iCarousel.type = iCarouselTypeCoverFlow2;
	// Do any additional setup after loading the view.
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [self.photos count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        FXImageView *imageView = [[FXImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)] ;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.processedImage = [UIImage imageNamed:@"AddPhoto.png"];
        imageView.asynchronous = YES;
        imageView.reflectionScale = 0.5f;
        imageView.reflectionAlpha = 0.25f;
        imageView.reflectionGap = 10.0f;
        imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
        imageView.shadowBlur = 5.0f;
        imageView.cornerRadius = 10.0f;
        view = imageView;
        if (self.editing) {
            UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(deletePhoto:)];
            swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
            [view addGestureRecognizer:swipeUp];
            UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(deletePhoto:)];
            swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
            [view addGestureRecognizer:swipeDown];
        }
    }
    NSString *photo = [self.photos objectAtIndex:index];
    if (![photo isEqualToString:@""]) {
        [((FXImageView *)view) setImageWithContentsOfURL:[RankClient urlWithPhoto:photo]];
    }

    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    if (carousel.currentItemIndex != index) {
        return;
    }
    if (self.editing) {
        [self addPhoto:nil];
    }else{
        [self performSegueWithIdentifier:@"PhotoSegue" sender:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

- (void)viewDidUnload {
    [self setICarousel:nil];
    [super viewDidUnload];
}

- (void)addPhoto:(UITapGestureRecognizer *)tap
{
    if (self.editing) {
        self.picker = [[UIImagePickerController alloc]init];
        self.picker.allowsEditing = YES;
        self.picker.mediaTypes = @[(NSString *)kUTTypeImage];
        self.picker.delegate = self;
        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            self.popover = [[UIPopoverController alloc] initWithContentViewController:self.picker];
            [self.popover presentPopoverFromRect:CGRectMake(512, 400, 100, 100) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }else {
            [self presentModalViewController:self.picker animated:YES];
        }
    }
}

- (void)deletePhoto:(UISwipeGestureRecognizer *)swipe
{
    NSString *photo = [self.photos objectAtIndex:self.iCarousel.currentItemIndex];
    [self.photos removeObjectAtIndex:self.iCarousel.currentItemIndex];
    [self.iCarousel removeItemAtIndex:self.iCarousel.currentItemIndex animated:YES];
    [RankClient deletePhoto:photo withHandler:^() {
        [RankClient processRemoteNotification:@{@"refresh":@"DismissCoverFlow"}];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *squareImage = [self imageWithImage:image ByScalingAndCroppingForSize:CGSizeMake(640.0f, 640.0f)];
    NSData *data = UIImageJPEGRepresentation(squareImage, 1.0f);
    [RankClient submitPhoto:data withHandler:^(NSString *photo) {
        [self.photos insertObject:photo atIndex:self.iCarousel.currentItemIndex];
        [self.iCarousel insertItemAtIndex:self.iCarousel.currentItemIndex animated:YES];
        [self.iCarousel reloadItemAtIndex:self.iCarousel.currentItemIndex animated:YES];
        [RankClient processRemoteNotification:@{@"refresh":@"DismissCoverFlow"}];
    }];
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [self.popover dismissPopoverAnimated:YES];
    }else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [self.popover dismissPopoverAnimated:YES];
    }else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)tap:(id)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
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

@end
