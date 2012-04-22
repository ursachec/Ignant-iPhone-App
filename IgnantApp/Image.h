//
//  Image.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 06.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BlogEntry;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) id data;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) BlogEntry *entry;

@end
