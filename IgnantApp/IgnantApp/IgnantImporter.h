//
//  IgnantImporter.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MWFeedParser.h"
#import "IgnantImporterDelegate.h"

extern NSString *const kLastImportedBlogEntryDateKey;
extern NSString *const kUserDefaultsLastImportDateForMainPageArticle;


@interface IgnantImporter : NSObject <MWFeedParserDelegate>

@property(nonatomic,assign) id<IgnantImporterDelegate> delegate;

@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectContext *insertionContext;

-(void)startImportingDataFromIgnant;
-(void)finishImportingDataFromIgnantWithError:(NSError*)error;


-(void)importJSONString:(NSString*)jsonString;

-(void)importJSONStringWithMorePosts:(NSString*)jsonStringWithPosts;

-(void)importJSONStringForSingleArticle:(NSString*)jsonStringWithSingleArticle;


@end
