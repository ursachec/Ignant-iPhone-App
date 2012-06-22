//
//  UserDefaultsManager.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 31.05.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultsManager : NSObject

-(NSDate*)lastUpdateDateForCategoryId:(NSString*)categoryId;
-(void)setLastUpdateDate:(NSDate*)date forCategoryId:(NSString*)categoryId;
-(NSMutableArray*)currentUpdateDatesForCategories;

-(NSDate*)dateForLeastRecentArticleWithCategoryId:(NSString*)categoryId;
-(void)setDateForLeastRecentArticle:(NSDate*)date withCategoryId:(NSString*)categoryId;
-(NSMutableArray*)currentDatesForLeastRecentArticles;

-(NSDate*)lastUpdateForFirstRun;
-(void)setLastUpdateDateForFirstRun:(NSDate*)date;

@end
