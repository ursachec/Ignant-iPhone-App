//
//  Constants.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 11.03.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "Constants.h"



//WARNING! (because of slappy programming) don't change the index to be other than -1, app crashes when navigating in the detailviewcontroller to the last index
int const kInvalidBlogEntryIndex = -1;

int const kFirstRelatedArticleTag = 501;
int const kSecondRelatedArticleTag = 502;
int const kThirdRelatedArticleTag = 503;


//################################################################################
//update cycles
int const kDefaultNumberOfHoursBeforeTriggeringLatestUpdate = 1;

//################################################################################
//categories
int const kCategoryIndexForHome = -1;
int const kCategoryIndexForMostRed = -500;
int const kCategoryIndexForTumblr = -600;
int const kCategoryIndexForMosaik = -700;


//################################################################################
//social media constants
NSString *const kFacebookAppId = @"270065646390191";


//################################################################################
//user defaults keys
NSString * const kLastStoreUpdateKey = @"LastStoreUpdate";

NSString * const kUpdateDatesForCategoriesKey = @"updateDates";
NSString * const kUpdateDatesForCategoriesKeyDateValue = @"updateDatesDate";
NSString * const kUpdateDatesForCategoriesKeyCategoryIdValue = @"updateDatesCategoryId";

NSString * const kDatesForLeastRecentArticleKey = @"leastRecentArticlesDates";
NSString * const kDatesForLeastRecentArticleKeyDateValue = @"leastRecentArticleDate";
NSString * const kDatesForLeastRecentArticleKeyCategoryIdValue = @"leastRecentArticleCategoryId";

NSString * const kFavouriteBlogEntriesKey = @"favouriteBlogEntries";
NSString * const kFavouriteBlogEntriesKeyArticleIdValue = @"favouriteBlogEntriesArticleId";


//################################################################################

//server stuff
#define shouldUseRemoteServer false
#define shouldUseIgnantServer true

NSString* const kAdressForMercedesPage = @"http://mb.mercedes-benz.com/de_DE";
NSString* const kAdressForItunesStore = @"itms-apps://ax.itunes.apple.com/app/ignant/id500183975?ls=1&mt=8";

#if shouldUseRemoteServer
NSString * const kAFContentBaseURL = @"http://107.21.216.249/ignant/ignant.php";
NSString * const kAdressForContentServer = @"http://107.21.216.249/ignant/ignant.php";
NSString * const kAdressForImageServer = @"http://107.21.216.249/ignant/imgsrv.php";
NSString * const kAdressForVideoServer = @"http://107.21.216.249/ignant/videosrv.php";
#elif shouldUseIgnantServer
NSString * const kAFContentBaseURL = @"http://www.ignant.de/app/ignant.php";
NSString * const kAdressForContentServer = @"http://www.ignant.de/app/ignant.php";
NSString * const kAdressForImageServer = @"http://www.ignant.de/app/imgsrv.php";
NSString * const kAdressForVideoServer = @"http://www.ignant.de/app/videosrv.php";
#else
NSString * const kAFContentBaseURL = @"http://192.168.2.107:9999/ign/";
NSString * const kAdressForContentServer = @"http://192.168.2.107:9999/ign/ignant.php";
NSString * const kAdressForImageServer = @"http://www.ignant.de/app/imgsrv.php";
NSString * const kAdressForVideoServer = @"http://www.ignant.de/app/videosrv.php";
#endif

NSString * const kReachabilityHostnameToCheck = @"www.google.de";

NSString * const kParameterAction = @"action";
NSString * const kParameterLanguage = @"lang";

//server status
NSString * const kAPICommandIsServerReachable = @"isServerReachable";
NSString * const kAPIKeyIsServerReachable = @"status";
NSString * const kAPIResponseServerOk = @"ok";
NSString * const kAPIResponseServerError = @"error";


//registering for notifications
NSString * const kAPICommandRegisterForNotifications = @"registerForNotifications";
NSString * const kAPIKeyRegisterForNotificationsDeviceToken = @"deviceToken";
NSString * const kAPIKeyDidRegisterForNotifications = @"didRegister";


//possible actions
NSString * const kAPICommandGetDataForFirstRun = @"getDataForTheFirstRun";
NSString * const kAPICommandGetMoreArticlesForCategory = @"getMoreArticlesForCategory";
NSString * const kAPICommandGetLatestArticlesForCategory = @"getLatestArticlesForCategory";
NSString * const kAPICommandGetSingleArticle = @"getSingleArticle";
NSString * const kAPICommandGetSetOfMosaicImages = @"getSetOfMosaicImages";
NSString * const kAPICommandGetMoreTumblrArticles = @"getMoreTumblrArticles";
NSString * const kAPICommandGetLatestTumblrArticles = @"getLatestTumblrArticles";
NSString * const kAPICommandShouldReloadDataForTheFirstRun  = @"getShouldReloadDataForTheFirstRun";

NSString * const kUndefinedCategoryId = @"undefined";
NSString * const kCurrentCategoryId = @"categoryId";
NSString * const kNumberOfResultsToBeReturned = @"numberOfResultsToReturn";
NSString * const kArticleId = @"articleId";

NSString * const kDateOfNewestArticle = @"dateOfNewestArticle";
NSString * const kDateOfOldestArticle = @"dateOfOldestArticle";

