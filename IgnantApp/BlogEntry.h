//
//  BlogEntry.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 06.06.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Image;

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
@property (nonatomic, retain) NSString * thumbIdentifier;
@property (nonatomic, retain) NSString * thumbImageFilename;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * webLink;
@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) NSSet *images;
@end

@interface BlogEntry (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
