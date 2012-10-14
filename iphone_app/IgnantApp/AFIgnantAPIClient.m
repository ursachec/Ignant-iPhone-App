//
//  AFIgnantAPIClient.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 07.10.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "AFIgnantAPIClient.h"

#import "AFJSONRequestOperation.h"

@implementation AFIgnantAPIClient

+ (AFIgnantAPIClient *)sharedClient {
    static AFIgnantAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFIgnantAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAFContentBaseURL]];
		[_sharedClient setDefaultHeader:@"Accept" value:@"application/json"];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
	
    
    return self;
}

- (void)getContentWithParameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseJSON))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	[self getPath:@"ignant.php" parameters:parameters success:success failure:failure];
}

-(void)getDataForFirstRunWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseJSON))success
							 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{	
    NSString* currentPreferredLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
	NSDictionary *params = @{kParameterAction:kAPICommandGetDataForFirstRun, kParameterLanguage:currentPreferredLanguage};
	[self getContentWithParameters:params success:success failure:failure];	
}

-(void)getMoreDataForTumblrWithLeastRecentDate:(NSDate*)leastRecentDate
										success:(void (^)(AFHTTPRequestOperation *operation, id responseJSON))success
									   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSNumber *secondsSince1970 = [NSNumber numberWithInteger:[leastRecentDate timeIntervalSince1970]];
	NSString* currentPreferredLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
	NSDictionary *params = @{
							kParameterAction:kAPICommandGetMoreTumblrArticles,
							kParameterLanguage:currentPreferredLanguage,
							kDateOfOldestArticle:secondsSince1970
							};
	[self getContentWithParameters:params success:success failure:failure];
	
}

-(void)getLatestDataForTumblrWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseJSON))success
								 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSString* currentPreferredLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
	NSDictionary *params = @{kParameterAction:kAPICommandGetLatestTumblrArticles, kParameterLanguage:currentPreferredLanguage};
	[self getContentWithParameters:params success:success failure:failure];	
}

@end