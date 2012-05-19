//
//  TumblrEntry.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 19.05.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TumblrEntry : NSManagedObject

@property (nonatomic, retain) NSDate * publishingDate;
@property (nonatomic, retain) NSString * imageUrl;

@end
