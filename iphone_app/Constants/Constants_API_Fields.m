//
//  Constants_API_Fields.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 07.05.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "Constants_API_Fields.h"

//----------------------------


//TOP LEVEL
NSString * const kTLSingleArticle = @"singleArticle";
NSString * const kTLArticles = @"articles";
NSString * const kTLPosts = @"posts";
NSString * const kTLOverwrite = @"overwrite";
NSString * const kTLError = @"error";
NSString * const kTLErrorMessage = @"error_message";
NSString * const kTLMetaInformation = @"meta_information";
NSString * const kTLResponseStatus = @"response_status";
NSString * const kTLCategoriesList = @"categories";
NSString * const kTLMosaicImages = @"mosaicImages";
NSString * const kTLMosaicEntries = @"entries";

NSString * const kTLReturnImageType = @"imgType";
NSString * const kTLReturnMosaicImage = @"mosaicImg";
NSString * const kTLReturnRelatedArticleImage = @"relatedImg";
NSString * const kTLReturnCategoryImage = @"categoryImg";
NSString * const kTLReturnDetailImage = @"detailImg";
NSString * const kTLReturnSlideshowImage = @"slideshowImg";


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

//TUMBLR
NSString * const kTumblrPostPublishingDate = @"tPublishingDate";
NSString * const kTumblrPostImageUrl = @"tUrl";

//MOSAIC
NSString * const kMosaicEntryUrl = @"meUrl";
NSString * const kMosaicEntryArticleId = @"meArticleId";
NSString * const kMosaicEntryHeight = @"meHeight";
NSString * const kMosaicEntryWidth = @"meWidth";


//ARTICLE
NSString * const kFKArticleType = @"type";
NSString * const kFKArticleId = @"articleId";
NSString * const kFKArticleTitle = @"title";
NSString * const kFKArticlePublishingDate = @"publishingDate";
NSString * const kFKArticleThumbImage = @"thumbImage";
NSString * const kFKArticleRemoteImages = @"remoteImages";
NSString * const kFKArticleNumberOfViews = @"numberOfViews";
NSString * const kFKArticleWebLink = @"webLink";
NSString * const kFKArticleShowOnHomeCategory = @"shouldShowOnHomeCategory";
NSString * const kFKArticleVideoEmbedCode = @"videoEmbedCode";

NSString * const kFKArticleCategoryId = @"categoryId";
NSString * const kFKArticleCategoryName = @"categoryName";

NSString * const kFKArticleCategory = @"rCategory";
NSString * const kFKArticleTemplate = @"rTemplate";
NSString * const kFKArticleDescriptionText = @"descriptionText";
NSString * const kFKArticleDescriptionRichText = @"descriptionRichText";
NSString * const kFKArticleImages = @"images";
NSString * const kFKArticleRelatedArticles = @"relatedArticles";

//template types
NSString * const kFKArticleTemplateDefault = @"default";
NSString * const kFKArticleTemplateArticle = @"article";
NSString * const kFKArticleTemplateMonifaktur = @"monifaktur";
NSString * const kFKArticleTemplateVideo = @"video";
NSString * const kFKArticleTemplateItravel = @"itravel";
NSString * const kFKArticleTemplateIgnanTV = @"ignantv";
NSString * const kFKArticleTemplateAicuisine = @"aicuisine";

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