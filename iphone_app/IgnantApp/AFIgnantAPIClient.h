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
@end
