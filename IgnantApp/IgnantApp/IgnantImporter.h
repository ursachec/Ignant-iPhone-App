//
//  IgnantImporter.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MWFeedParser.h"


extern NSString *const kLastImportedBlogEntryDateKey;
extern NSString *const kUserDefaultsLastImportDateForMainPageArticle;

@class IgnantImporter;

@protocol IgnantImporterDelegate <NSObject>

@optional
-(void)didStartImportingData;
-(void)didFailImportingData;
-(void)didFinishImportingData;

-(void)importerDidStartParsingSingleArticle:(IgnantImporter*)importer;
-(void)importer:(IgnantImporter*)importer didFinishParsingSingleArticleWithDictionary:(NSDictionary*)articleDictionary;
-(void)importer:(IgnantImporter*)importer didFailParsingSingleArticleWithDictionary:(NSDictionary*)articleDictionary;

@end

@interface IgnantImporter : NSObject <MWFeedParserDelegate>

@property(nonatomic,assign) id<IgnantImporterDelegate> delegate;

@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectContext *insertionContext;


-(void)importJSONString:(NSString*)jsonString;

-(void)importJSONStringWithMorePosts:(NSString*)jsonStringWithPosts;

-(void)importJSONStringForSingleArticle:(NSString*)jsonStringWithSingleArticle;

-(void)importJSONStringForTumblrPosts:(NSString*)jsonString;

@end
