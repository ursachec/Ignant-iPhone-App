//
//  IgnantImporter.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const kLastImportedBlogEntryDateKey;
extern NSString *const kUserDefaultsLastImportDateForMainPageArticle;

@class IgnantImporter, BlogEntry;

@protocol IgnantImporterDelegate <NSObject>

@optional
-(void)didStartImportingData;
-(void)didFailImportingData;
-(void)didFinishImportingData;

-(void)importerDidStartParsingSingleArticle:(IgnantImporter*)importer;
-(void)importer:(IgnantImporter*)importer didFinishParsingSingleArticleWithDictionary:(NSDictionary*)articleDictionary;
-(void)importer:(IgnantImporter*)importer didFailParsingSingleArticleWithDictionary:(NSDictionary*)articleDictionary;

@end

@interface IgnantImporter : NSObject

@property(nonatomic, unsafe_unretained) id<IgnantImporterDelegate> delegate;

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectContext *insertionContext;


-(void)importJSONStringForFirstRun:(NSString*)jsonString;

-(void)importJSONWithMorePosts:(NSString*)jsonString forCategoryId:(NSString*)categoryId;

-(void)importJSONWithLatestPosts:(NSString*)jsonString forCategoryId:(NSString*)categoryId;

-(void)importJSONStringForSingleArticle:(NSString*)jsonStringWithSingleArticle;

-(void)importJSONStringForTumblrPosts:(NSString*)jsonString;


-(BlogEntry*)blogEntryWithId:(NSString*)blogEntryId;

@end
