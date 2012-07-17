//
//  UserDefaultsManager.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 31.05.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "UserDefaultsManager.h"

#import "Constants.h"

@implementation UserDefaultsManager

#pragma mark - User Defaults
-(NSDate*)lastUpdateForFirstRun
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLastStoreUpdateKey];
}

-(void)setLastUpdateDateForFirstRun:(NSDate*)date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:kLastStoreUpdateKey];        
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(NSDate*)lastUpdateDateForCategoryId:(NSString*)categoryId
{
    
    NSMutableArray* currentUpdateDates = [self currentUpdateDatesForCategories];
    NSString* currentCategoryId = categoryId;
    
    //check if an entry for the categoryId already exists and remove it
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

-(void)setLastUpdateDate:(NSDate*)date forCategoryId:(NSString*)categoryId
{
    if (categoryId==nil) {
        DBLog(@"setLastUpdateDate You are trying to set the last update date for a nil categoryId, exiting method");
        return;
    }
    
    NSMutableArray* currentUpdateDates = [self currentUpdateDatesForCategories];
    NSString* currentCategoryId = categoryId;
    
    //check if an entry for the categoryId already exists and remove it
    NSDictionary* dictionaryToRemove = nil;
    for (NSDictionary* anUpdateDateDictionary in currentUpdateDates) {
        NSString*  aCategoryId = [anUpdateDateDictionary objectForKey:kUpdateDatesForCategoriesKeyCategoryIdValue];
        if ([aCategoryId compare:currentCategoryId]==NSOrderedSame) {
            dictionaryToRemove = anUpdateDateDictionary; break;
        }
    }
    
    //remove the found dictionary from the currentUpdateDates array
    if (dictionaryToRemove!=nil) {
        [currentUpdateDates removeObject:dictionaryToRemove];
    }
    
    //add the new dictionary to the currentUpdateDates array
    NSDictionary* newEntryDictionary = [NSDictionary dictionaryWithObjectsAndKeys:date,kUpdateDatesForCategoriesKeyDateValue,categoryId,kUpdateDatesForCategoriesKeyCategoryIdValue, nil];
    [currentUpdateDates addObject:newEntryDictionary];
    
    [[NSUserDefaults standardUserDefaults] setObject:currentUpdateDates forKey:kUpdateDatesForCategoriesKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSMutableArray*)currentUpdateDatesForCategories
{
    NSArray *updateDates = (NSArray*)[[NSUserDefaults standardUserDefaults] objectForKey:kUpdateDatesForCategoriesKey];
    if (updateDates==nil) {
        return [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    return [updateDates mutableCopy];
}

-(NSDate*)dateForLeastRecentArticleWithCategoryId:(NSString*)categoryId
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    NSMutableArray* currentUpdateDates = [self currentDatesForLeastRecentArticles];
    NSString* currentCategoryId = categoryId;
    
    //check if an entry for the categoryId already exists and remove it
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

-(void)setDateForLeastRecentArticle:(NSDate*)date withCategoryId:(NSString*)categoryId
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    if (categoryId==nil || date==nil) {
        DBLog(@"setDateForLeastRecentArticle: You are trying to set the date for least recent article a nil categoryIdor date, exiting function");
        return;
    }
    
    NSMutableArray* currentUpdateDates = [self currentDatesForLeastRecentArticles];
    NSString* currentCategoryId = categoryId;
    
    //check if an entry for the categoryId already exists and remove it
    NSDictionary* dictionaryToRemove = nil;
    for (NSDictionary* anUpdateDateDictionary in currentUpdateDates) {
        NSString*  aCategoryId = [anUpdateDateDictionary objectForKey:kDatesForLeastRecentArticleKeyCategoryIdValue];
        if ([aCategoryId compare:currentCategoryId]==NSOrderedSame) {
            dictionaryToRemove = anUpdateDateDictionary; break;
        }
    }
    
    //remove the found dictionary from the currentUpdateDates array
    if (dictionaryToRemove!=nil) {
        [currentUpdateDates removeObject:dictionaryToRemove];
    }
    
    //add the new dictionary to the currentUpdateDates array
    NSDictionary* newEntryDictionary = [NSDictionary dictionaryWithObjectsAndKeys:date,kDatesForLeastRecentArticleKeyDateValue,categoryId,kDatesForLeastRecentArticleKeyCategoryIdValue, nil];
    [currentUpdateDates addObject:newEntryDictionary];
    
    [[NSUserDefaults standardUserDefaults] setObject:currentUpdateDates forKey:kDatesForLeastRecentArticleKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSMutableArray*)currentDatesForLeastRecentArticles
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    NSArray *updateDates = (NSArray*)[[NSUserDefaults standardUserDefaults] objectForKey:kDatesForLeastRecentArticleKey];    
    if (updateDates==nil) {
        return [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    return [updateDates mutableCopy];
}

#pragma mark - blog entry favourites
-(BOOL)isBlogEntryFavourite:(NSString*)articleId
{
    NSMutableArray* currentFavouriteIds = [self currentFavouriteBlogEntries];
    for (NSString* aArticleId in currentFavouriteIds) {
        if ([articleId compare:aArticleId]==NSOrderedSame)
            return true;
    }
    
    return false;
}

-(void)setIsBlogEntry:(NSString*)articleId favourite:(BOOL)favourite
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    if (articleId==nil) {
        DBLog(@"setIsBlogEntry: You are trying to set the favourite state of nil articleId");
        return;
    }
    
    NSMutableArray* currentFavouriteIds = [self currentFavouriteBlogEntries];    
    BOOL currentFavouriteStatus = [self isBlogEntryFavourite:articleId];
    
    if (currentFavouriteStatus == favourite)
        return;
    
    else if (favourite==true && currentFavouriteStatus==false) {
        [currentFavouriteIds addObject:articleId];
    }
    else if (favourite==false && currentFavouriteStatus==true) {
        [currentFavouriteIds removeObject:articleId];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:currentFavouriteIds forKey:kFavouriteBlogEntriesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)toggleIsFavouriteBlogEntry:(NSString*)articleId
{
    BOOL currentFavouriteState = [self isBlogEntryFavourite:articleId];
    [self setIsBlogEntry:articleId favourite:!currentFavouriteState];
}

-(NSMutableArray*)currentFavouriteBlogEntries
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    NSArray *updateDates = (NSArray*)[[NSUserDefaults standardUserDefaults] objectForKey:kFavouriteBlogEntriesKey];    
    if (updateDates==nil) {
        return [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    return [updateDates mutableCopy];
}

@end
