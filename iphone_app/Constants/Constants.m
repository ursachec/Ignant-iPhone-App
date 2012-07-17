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
int const kDefaultNumberOfHoursBeforeTriggeringLatestUpdate = 24;

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
#define shouldUseIgnantServer false


NSString* const kAdressForMercedesPage = @"http://m.mercedes-benz.de/";
NSString* const kAdressForItunesStore = @"itms-apps://ax.itunes.apple.com/at/app/instapaper/id288545208?mt=8";

#if TARGET_IPHONE_SIMULATOR==TRUE
NSString * const kAdressForContentServer = @"http://localhost/ignant/Ignant-iPhone-App/server_side/ignant.php";
NSString * const kAdressForImageServer = @"http://localhost/ignant/Ignant-iPhone-App/server_side/imgsrv.php";
NSString * const kAdressForVideoServer = @"http://localhost/ignant/Ignant-iPhone-App/server_side/videosrv.php";
#elif shouldUseRemoteServer
NSString * const kAdressForContentServer = @"http://107.21.216.249/ignant/ignant.php";
NSString * const kAdressForImageServer = @"http://107.21.216.249/ignant/imgsrv.php";
NSString * const kAdressForVideoServer = @"http://107.21.216.249/ignant/videosrv.php";
#elif shouldUseIgnantServer
NSString * const kAdressForContentServer = @"http://www.ignant.de/iphone_app/ignant.php";
NSString * const kAdressForImageServer = @"http://www.ignant.de/iphone_app/imgsrv.php";
NSString * const kAdressForVideoServer = @"http://www.ignant.de/iphone_app/videosrv.php";
#else
NSString * const kAdressForContentServer = @"http://192.168.144.236/ignant/Ignant-iPhone-App/server_side/ignant.php";
NSString * const kAdressForImageServer = @"http://192.168.144.236/ignant/Ignant-iPhone-App/server_side/imgsrv.php";
NSString * const kAdressForVideoServer = @"http://192.168.144.236/ignant/Ignant-iPhone-App/server_side/videosrv.php";
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


NSString * const kUndefinedCategoryId = @"undefined";
NSString * const kCurrentCategoryId = @"categoryId";
NSString * const kNumberOfResultsToBeReturned = @"numberOfResultsToReturn";
NSString * const kArticleId = @"articleId";

NSString * const kDateOfNewestArticle = @"dateOfNewestArticle";
NSString * const kDateOfOldestArticle = @"dateOfOldestArticle";

