//
//  Constants.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 11.03.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "Constants_Colors.h"
#import "Constants_API_Flow_Control.h"
#import "Constants_API_Fields.h"

//some preprocessor commans
#define LOG_CURRENT_FUNCTION() NSLog(@"%@", NSStringFromSelector(_cmd));
#define LOG_CURRENT_FUNCTION_AND_CLASS() NSLog(@"%@ self.class: %@", NSStringFromSelector(_cmd), NSStringFromClass([self class]));


//################################################################################
//categories
extern int const kCategoryIndexForHome;
extern int const kCategoryIndexForMostRed;
extern int const kCategoryIndexForTumblr;
extern int const kCategoryIndexForMosaik;

//################################################################################
//social media constants
extern NSString *const kFacebookAppId;

//################################################################################
//user defaults keys
extern NSString * const kLastStoreUpdateKey;

extern NSString * const kUpdateDatesForCategoriesKey;
extern NSString * const kUpdateDatesForCategoriesKeyDateValue;
extern NSString * const kUpdateDatesForCategoriesKeyCategoryIdValue;

extern NSString * const kDatesForLeastRecentArticleKey;
extern NSString * const kDatesForLeastRecentArticleKeyDateValue;
extern NSString * const kDatesForLeastRecentArticleKeyCategoryIdValue;


//################################################################################
//other constants

extern int const kInvalidBlogEntryIndex;

//these are the tags given to the buttons in the detailviewcontroller for sowing related articles
extern int const kFirstRelatedArticleTag;
extern int const kSecondRelatedArticleTag;
extern int const kThirdRelatedArticleTag;


//################################################################################

extern NSString* const kAdressForMercedesPage; 
extern NSString* const kAdressForItunesStore;

//server adresses
extern NSString * const kAdressForContentServer;
extern NSString * const kAdressForImageServer;
extern NSString * const kAdressForVideoServer;
extern NSString * const kReachabilityHostnameToCheck;

//top parameter names
extern NSString * const kParameterAction;

//server status
extern NSString * const kAPICommandIsServerReachable;
extern NSString * const kAPIKeyIsServerReachable;
extern NSString * const kAPIResponseServerOk;
extern NSString * const kAPIResponseServerError;

//possible API Commands
extern NSString * const kAPICommandGetDataForFirstRun;
extern NSString * const kAPICommandGetMoreArticlesForCategory;
extern NSString * const kAPICommandGetLatestArticlesForCategory;
extern NSString * const kAPICommandGetSingleArticle;
extern NSString * const kAPICommandGetSetOfMosaicImages;
extern NSString * const kAPICommandGetMoreTumblrArticles;
extern NSString * const kAPICommandGetLatestTumblrArticles;

//getting content
extern NSString * const kUndefinedCategoryId;
extern NSString * const kCurrentCategoryId;
extern NSString * const kNumberOfResultsToBeReturned;
extern NSString * const kArticleId;

extern NSString * const kDateOfNewestArticle;
extern NSString * const kDateOfOldestArticle;
