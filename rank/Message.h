//
//  Message.h
//  rank
//
//  Created by Larry on 12/6/12.
//  Copyright (c) 2012 warycat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * data;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * from;

@end
