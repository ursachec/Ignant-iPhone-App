//
//  Constants.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 11.03.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//


//some preprocessor commans
#define LOG_CURRENT_FUNCTION() NSLog(@"%@", NSStringFromSelector(_cmd));


//################################################################################
//categories
extern int const kCategoryIndexForHome;
extern int const kCategoryIndexForMostRed;

//################################################################################
//other constants

extern int const kInvalidBlogEntryIndex;

//these are the tags given to the buttons in the detailviewcontroller for sowing related articles
extern int const kFirstRelatedArticleTag;
extern int const kSecondRelatedArticleTag;
extern int const kThirdRelatedArticleTag;


//################################################################################


//server adresses
extern NSString * const kAdressForContentServer;

//top parameter names
extern NSString * const kParameterAction;

//possible API Commands
extern NSString * const kAPICommandSearch;
extern NSString * const kAPICommandGetDataForFirstRun;
extern NSString * const kAPICommandGetMorePosts;
extern NSString * const kAPICommandGetArticlesForCategory;
extern NSString * const kAPICommandGetSingleArticle;
extern NSString * const kAPICommandGetSetOfMosaicImages;


//getting content
extern NSString * const kCategoryId;
extern NSString * const kNumberOfResultsToBeReturned;
extern NSString * const kArticleId;

extern NSString * const kDateOfNewestArticle;
extern NSString * const kDateOfOldestArticle;



extern NSString * const kTLSingleArticle;
extern NSString * const kTLArticles;
extern NSString * const kTLOverwrite;
extern NSString * const kTLError;
extern NSString * const kTLErrorMessage;
extern NSString * const kTLMetaInformation;
extern NSString * const kTLResponseStatus;
extern NSString * const kTLCategoriesList;
extern NSString * const kTLMosaicImages;


extern NSString * const kMetaInformationFlagNoMoreObjects;

extern NSString * const kIgnantObjectTypeLightArticle;
extern NSString * const kIgnantObjectTypeRelatedArticle;
extern NSString * const kIgnantObjectTypeFullArticle;
extern NSString * const kIgnantObjectTypeBase;
extern NSString * const kIgnantObjectTypeRemoteImage;
extern NSString * const kIgnantObjectTypeTemplate;
extern NSString * const kIgnantObjectTypeCategory;

extern NSString * const kFKArticleType;
extern NSString * const kFKArticleId;
extern NSString * const kFKArticleTitle;
extern NSString * const kFKArticlePublishingDate;
extern NSString * const kFKArticleThumbImage;
extern NSString * const kFKArticleRemoteImages;
extern NSString * const kFKArticleNumberOfViews;
extern NSString * const kFKArticleCategoryId;
extern NSString * const kFKArticleCategoryName;
extern NSString * const kFKArticleCategory;
extern NSString * const kFKArticleTemplate;
extern NSString * const kFKArticleDescriptionText;
extern NSString * const kFKArticleDescriptionRichText;
extern NSString * const kFKArticleImages;
extern NSString * const kFKArticleRelatedArticles;


extern NSString * const kFKRelatedArticleCategoryText;
extern NSString * const kFKRelatedArticleBase64Thumbnail;



extern NSString * const kFKCategoryType;
extern NSString * const kFKCategoryId;
extern NSString * const kFKCategoryName;
extern NSString * const kFKCategoryDescription;


extern NSString * const kFKImageType;
extern NSString * const kFKImageId;
extern NSString * const kFKImageDescription;
extern NSString * const kFKImageBase64Representation;
extern NSString * const kFKImageURL;

extern NSString * const kFKImageWidth;
extern NSString * const kFKImageHeight;
extern NSString * const kFKImageReferenceArticleId;

