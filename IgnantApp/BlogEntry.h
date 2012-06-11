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

@property (nonatomic, strong) NSString * articleId;
@property (nonatomic, strong) NSString * categoryId;
@property (nonatomic, strong) NSString * categoryName;
@property (nonatomic, strong) NSString * descriptionText;
@property (nonatomic, strong) NSNumber * numberOfViews;
@property (nonatomic, strong) NSDate * publishingDate;
@property (nonatomic, strong) id relatedArticles;
@property (nonatomic, strong) id remoteImages;
@property (nonatomic, strong) NSNumber * showInHomeCategory;
@property (nonatomic, strong) NSString * thumbIdentifier;
@property (nonatomic, strong) NSString * thumbImageFilename;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * webLink;
@property (nonatomic, strong) Category *category;
@property (nonatomic, strong) NSSet *images;
@end

@interface BlogEntry (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
