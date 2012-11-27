//
//  MapViewController.h
//  rank
//
//  Created by Larry on 11/20/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>
@property (strong, nonatomic) CLLocation *location;
@end
