//
//  MapViewController.m
//  rank
//
//  Created by Larry on 11/20/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import "MapViewController.h"
#import "RankClient.h"

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

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
    MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
    point.coordinate = self.location.coordinate;
    [self.mapView addAnnotation:point];
    self.mapView.delegate = self;
	// Do any additional setup after loading the view.
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKMapPoint point1 = MKMapPointForCoordinate(self.location.coordinate);
    MKMapPoint point2 = MKMapPointForCoordinate(userLocation.location.coordinate);
    MKMapRect rect1 = MKMapRectMake(point1.x, point1.y, 0, 0);
    MKMapRect rect2 = MKMapRectMake(point2.x, point2.y, 0, 0);
    MKMapRect rect = MKMapRectUnion(rect1, rect2);
    [self.mapView setVisibleMapRect:rect animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
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
