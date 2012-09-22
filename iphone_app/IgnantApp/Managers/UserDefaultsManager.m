//
//  UserDefaultsManager.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 31.05.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "UserDefaultsManager.h"

@implementation UserDefaultsManager

#pragma mark -

-(NSDate*)lastUpdateForFirstRun {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLastStoreUpdateKey];
}

-(void)setLastUpdateDateForFirstRun:(NSDate*)date {
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:kLastStoreUpdateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -

-(NSDate*)lastUpdateDateForCategoryId:(NSString*)categoryId {
    NSMutableArray* currentUpdateDates = [self currentUpdateDatesForCategories];
    NSString* currentCategoryId = categoryId;
    NSDate* updateDateForCategoryId = nil;
    for (NSDictionary* anUpdateDateDictionary in currentUpdateDates) {
        NSString*  aCategoryId = [anUpdateDateDictionary objectForKey:kUpdateDatesForCategoriesKeyCategoryIdValue];
        if ([aCategoryId compare:currentCategoryId]==NSOrderedSame) {
            updateDateForCategoryId = (NSDate*)[anUpdateDateDictionary objectForKey:kUpdateDatesForCategoriesKeyDateValue];
            break;
        }
    }
    return updateDateForCategoryId;
}

-(void)setLastUpdateDate:(NSDate*)date forCategoryId:(NSString*)categoryId {
    if (categoryId==nil) {
        DBLog(@"WARNING: setLastUpdateDate for a nil categoryId");
        return;
    }
    NSMutableArray* currentUpdateDates = [self currentUpdateDatesForCategories];
    NSString* currentCategoryId = categoryId;
    NSDictionary* dictionaryToRemove = nil;
    for (NSDictionary* anUpdateDateDictionary in currentUpdateDates) {
        NSString*  aCategoryId = [anUpdateDateDictionary objectForKey:kUpdateDatesForCategoriesKeyCategoryIdValue];
        if ([aCategoryId compare:currentCategoryId]==NSOrderedSame) {
            dictionaryToRemove = anUpdateDateDictionary;
			break;
        }
    }
    if (dictionaryToRemove!=nil) {
        [currentUpdateDates removeObject:dictionaryToRemove];
    }
    NSDictionary* newEntryDictionary = [NSDictionary dictionaryWithObjectsAndKeys:date,kUpdateDatesForCategoriesKeyDateValue,categoryId,kUpdateDatesForCategoriesKeyCategoryIdValue, nil];
    [currentUpdateDates addObject:newEntryDictionary];
    
    [[NSUserDefaults standardUserDefaults] setObject:currentUpdateDates forKey:kUpdateDatesForCategoriesKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSMutableArray*)currentUpdateDatesForCategories {
    NSArray *updateDates = (NSArray*)[[NSUserDefaults standardUserDefaults] objectForKey:kUpdateDatesForCategoriesKey];
    if (updateDates==nil) {
        return [[NSMutableArray alloc] initWithCapacity:1];
    }
    return [updateDates mutableCopy];
}

#pragma mark -

-(NSDate*)dateForLeastRecentArticleWithCategoryId:(NSString*)categoryId {    
    NSMutableArray* currentUpdateDates = [self currentDatesForLeastRecentArticles];
    NSString* currentCategoryId = categoryId;
    NSDate* updateDateForCategoryId = nil;
    for (NSDictionary* anUpdateDateDictionary in currentUpdateDates) {
        NSString*  aCategoryId = [anUpdateDateDictionary objectForKey:kDatesForLeastRecentArticleKeyCategoryIdValue];
        if ([aCategoryId compare:currentCategoryId]==NSOrderedSame) {
            updateDateForCategoryId = (NSDate*)[anUpdateDateDictionary objectForKey:kDatesForLeastRecentArticleKeyDateValue];
            break;
        }
    }
    return updateDateForCategoryId;
}

-(void)setDateForLeastRecentArticle:(NSDate*)date withCategoryId:(NSString*)categoryId {
    if (categoryId==nil || date==nil) {
        DBLog(@"WARNING: setDateForLeastRecentArticle for a nil categoryId or date");
        return;
    }
    NSMutableArray* currentUpdateDates = [self currentDatesForLeastRecentArticles];
    NSString* currentCategoryId = categoryId;
    NSDictionary* dictionaryToRemove = nil;
    for (NSDictionary* anUpdateDateDictionary in currentUpdateDates) {
        NSString*  aCategoryId = [anUpdateDateDictionary objectForKey:kDatesForLeastRecentArticleKeyCategoryIdValue];
        if ([aCategoryId compare:currentCategoryId]==NSOrderedSame) {
            dictionaryToRemove = anUpdateDateDictionary;
			break;
        }
    }
    if (dictionaryToRemove!=nil) {
        [currentUpdateDates removeObject:dictionaryToRemove];
    }
    NSDictionary* newEntryDictionary = [NSDictionary dictionaryWithObjectsAndKeys:date,kDatesForLeastRecentArticleKeyDateValue,categoryId,kDatesForLeastRecentArticleKeyCategoryIdValue, nil];
    [currentUpdateDates addObject:newEntryDictionary];
    
    [[NSUserDefaults standardUserDefaults] setObject:currentUpdateDates forKey:kDatesForLeastRecentArticleKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSMutableArray*)currentDatesForLeastRecentArticles {
    NSArray *updateDates = (NSArray*)[[NSUserDefaults standardUserDefaults] objectForKey:kDatesForLeastRecentArticleKey];    
    if (updateDates==nil) {
        return [[NSMutableArray alloc] initWithCapacity:1];
    }
    return [updateDates mutableCopy];
}

#pragma mark -

-(BOOL)isBlogEntryFavourite:(NSString*)articleId {
    NSMutableArray* currentFavouriteIds = [self currentFavouriteBlogEntries];
    for (NSString* aArticleId in currentFavouriteIds) {
        if ([articleId compare:aArticleId]==NSOrderedSame)
            return true;
    }
    return false;
}

-(void)setIsBlogEntry:(NSString*)articleId favourite:(BOOL)favourite {
    if (articleId==nil) {
        DBLog(@"setIsBlogEntry: You are trying to set the favourite state of nil articleId");
        return;
    }
    NSMutableArray* currentFavouriteIds = [self currentFavouriteBlogEntries];    
    BOOL currentFavouriteStatus = [self isBlogEntryFavourite:articleId];
    if (currentFavouriteStatus == favourite) {
        return;
	}
    else if (favourite==true && currentFavouriteStatus==false) {
        [currentFavouriteIds addObject:articleId];
    }
    else if (favourite==false && currentFavouriteStatus==true) {
        [currentFavouriteIds removeObject:articleId];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:currentFavouriteIds forKey:kFavouriteBlogEntriesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)toggleIsFavouriteBlogEntry:(NSString*)articleId {
    BOOL currentFavouriteState = [self isBlogEntryFavourite:articleId];
    [self setIsBlogEntry:articleId favourite:!currentFavouriteState];
}

-(NSMutableArray*)currentFavouriteBlogEntries {
    NSArray *updateDates = (NSArray*)[[NSUserDefaults standardUserDefaults] objectForKey:kFavouriteBlogEntriesKey];    
    if (updateDates==nil) {
        return [[NSMutableArray alloc] initWithCapacity:1];
    }
    return [updateDates mutableCopy];
}

@end
