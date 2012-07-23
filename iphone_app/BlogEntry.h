//
//  BlogEntry.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 19.07.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category;

@interface BlogEntry : NSManagedObject

@property (nonatomic, retain) NSString * articleId;
@property (nonatomic, retain) NSString * categoryId;
@property (nonatomic, retain) NSString * categoryName;
@property (nonatomic, retain) NSString * descriptionText;
@property (nonatomic, retain) NSNumber * numberOfViews;
@property (nonatomic, retain) NSDate * publishingDate;
@property (nonatomic, retain) id relatedArticles;
@property (nonatomic, retain) id remoteImages;
@property (nonatomic, retain) NSNumber * showInHomeCategory;
@property (nonatomic, retain) NSString * tempate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * webLink;
@property (nonatomic, retain) NSString * videoEmbedCode;
@property (nonatomic, retain) Category *category;

@end
