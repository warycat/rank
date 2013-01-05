//
//  Download.h
//  rank
//
//  Created by Larry on 1/5/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Download : NSManagedObject

@property (nonatomic, retain) NSString * file;
@property (nonatomic, retain) NSString * md5;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * key;

@end
