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
//categories
int const kCategoryIndexForHome = -1;
int const kCategoryIndexForMostRed = -500;

//################################################################################

//server stuff
#define shouldUseRemoteServer FALSE


#if TARGET_IPHONE_SIMULATOR==TRUE
NSString * const kAdressForContentServer = @"http://localhost/ignant/Ignant-iPhone-App/server_side/ignant.php";
#elif shouldUseRemoteServer
NSString * const kAdressForContentServer = @"http://107.21.216.249/ignant/ignant.php";
#else
NSString * const kAdressForContentServer = @"http://192.168.44.113/ignant/ignant.php";
#endif

NSString * const kParameterAction = @"action";

//possible actions
NSString * const kAPICommandSearch = @"search";
NSString * const kAPICommandGetDataForFirstRun = @"getDataForTheFirstRun";
NSString * const kAPICommandGetMorePosts = @"getMorePosts";
NSString * const kAPICommandGetArticlesForCategory = @"getArticlesForCategory";
NSString * const kAPICommandGetSingleArticle = @"getSingleArticle";
NSString * const kAPICommandGetSetOfMosaicImages = @"getSetOfMosaicImages";
NSString * const kAPICommandGetMoreTumblrArticles = @"getMoreTumblrArticles";
NSString * const kAPICommandGetLatestTumblrArticles = @"getLatestTumblrArticles";


NSString * const kCategoryId = @"categoryId";
NSString * const kNumberOfResultsToBeReturned = @"numberOfResultsToReturn";
NSString * const kArticleId = @"articleId";

NSString * const kDateOfNewestArticle = @"dateOfNewestArticle";
NSString * const kDateOfOldestArticle = @"dateOfOldestArticle";


//----------------------------


//TOP LEVEL
NSString * const kTLSingleArticle = @"singleArticle";
NSString * const kTLArticles = @"articles";
NSString * const kTLOverwrite = @"overwrite";
NSString * const kTLError = @"error";
NSString * const kTLErrorMessage = @"error_message";
NSString * const kTLMetaInformation = @"meta_information";
NSString * const kTLResponseStatus = @"response_status";
NSString * const kTLCategoriesList = @"categories";
NSString * const kTLMosaicImages = @"mosaicImages";



//METAINFORMATION
NSString * const kMetaInformationFlagNoMoreObjects = @"no_more_objects";

//OBJECT TYPES
NSString * const kIgnantObjectTypeLightArticle = @"light_article";
NSString * const kIgnantObjectTypeRelatedArticle = @"related_article";
NSString * const kIgnantObjectTypeFullArticle = @"full_article";
NSString * const kIgnantObjectTypeBase64Image = @"base64_image";
NSString * const kIgnantObjectTypeRemoteImage = @"remote_image";
NSString * const kIgnantObjectTypeTemplate = @"template";
NSString * const kIgnantObjectTypeCategory = @"category";



//ARTICLE
NSString * const kFKArticleType = @"type";
NSString * const kFKArticleId = @"articleId";
NSString * const kFKArticleTitle = @"title";
NSString * const kFKArticlePublishingDate = @"publishingDate";
NSString * const kFKArticleThumbImage = @"thumbImage";
NSString * const kFKArticleRemoteImages = @"remoteImages";
NSString * const kFKArticleNumberOfViews = @"numberOfViews";


NSString * const kFKArticleCategoryId = @"categoryId";
NSString * const kFKArticleCategoryName = @"categoryName";


NSString * const kFKArticleCategory = @"rCategory";
NSString * const kFKArticleTemplate = @"rTemplate";
NSString * const kFKArticleDescriptionText = @"descriptionText";
NSString * const kFKArticleDescriptionRichText = @"descriptionRichText";
NSString * const kFKArticleImages = @"images";
NSString * const kFKArticleRelatedArticles = @"relatedArticles";

//RELATED ARTICLE
NSString * const kFKRelatedArticleCategoryText = @"categoryText";
NSString * const kFKRelatedArticleBase64Thumbnail = @"base64Thumbnail";


//CATEGORY
NSString * const kFKCategoryType = @"type";
NSString * const kFKCategoryId = @"id";
NSString * const kFKCategoryName = @"name";
NSString * const kFKCategoryDescription = @"description";

//IMAGE
NSString * const kFKImageType = @"type";
NSString * const kFKImageId = @"id";
NSString * const kFKImageDescription = @"description";
NSString * const kFKImageBase64Representation = @"base64Representation";
NSString * const kFKImageURL = @"url";

NSString * const kFKImageWidth = @"width";
NSString * const kFKImageHeight = @"height";
NSString * const kFKImageReferenceArticleId = @"refArticleId";

