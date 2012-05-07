//
//  IgnantImporterDelegate.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IgnantImporter;

@protocol IgnantImporterDelegate <NSObject>

@optional
-(void)didStartImportingRSSData;
-(void)didFinishImportingRSSData;

-(void)didStartParsingRSSData;
-(void)didFinishParsingRSSData;


-(void)importerDidStartParsingSingleArticle:(IgnantImporter*)importer;
-(void)importer:(IgnantImporter*)importer didFinishParsingSingleArticleWithDictionary:(NSDictionary*)articleDictionary;
-(void)importer:(IgnantImporter*)importer didFailParsingSingleArticleWithDictionary:(NSDictionary*)articleDictionary;


@end
