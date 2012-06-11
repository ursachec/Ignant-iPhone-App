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

@property (nonatomic, strong) NSString * filename;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) id data;
@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, strong) NSString * caption;
@property (nonatomic, strong) BlogEntry *entry;

@end
