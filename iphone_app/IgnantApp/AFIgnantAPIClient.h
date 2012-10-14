//
//  AFIgnantAPIClient.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 07.10.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AFIgnantAPIClient : AFHTTPClient
+ (AFIgnantAPIClient *)sharedClient;

- (void)getContentWithParameters:(NSDictionary *)parameters
						 success:(void (^)(AFHTTPRequestOperation *operation, id responseJSON))success
						 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

-(void)getDataForFirstRunWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseJSON))success
							 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


-(void)getMoreDataForTumblrWithLeastRecentDate:(NSDate*)leastRecentDate
									   success:(void (^)(AFHTTPRequestOperation *operation, id responseJSON))success
									   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

-(void)getLatestDataForTumblrWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseJSON))success
								 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

-(void)getSingleArticleWithId:(NSString*)articleId
					  success:(void (^)(AFHTTPRequestOperation *operation, id responseJSON))success
					  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

-(void)getSetOfMosaicImagesWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseJSON))success
							   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


-(void)getMoreArticlesWithCategoryId:(NSString*)categoryId
				 dateOfOldestArticle:(NSDate*)dateOfOldestArticle
							 success:(void (^)(AFHTTPRequestOperation *operation, id responseJSON))success
							 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

-(void)getLatestArticlesWithCategoryId:(NSString*)categoryId
							   success:(void (^)(AFHTTPRequestOperation *operation, id responseJSON))success
							   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

-(void)getRegisterForNotificationsWithDeviceToken:(NSString*)deviceToken
										  success:(void (^)(AFHTTPRequestOperation *operation, id responseJSON))success
										  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

-(void)getShouldFetchFirstRunDataWithLastUpdateDate:(NSDate*)lastUpdate
											success:(void (^)(AFHTTPRequestOperation *operation, id responseJSON))success
											failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
