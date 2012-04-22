//
//  NSURL+stringforurl.h
//  BaisyTest1
//
//  Created by Claudiu- Vlad Ursache on 25.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (stringforurl)
+(NSString*)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary;
+(NSString*)urlEscapeString:(NSString *)unencodedString;

@end
