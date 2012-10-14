//
//  NSLocale+Ignant.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 14.10.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "NSLocale+Ignant.h"

@implementation NSLocale (Ignant)

+(NSString*)currentPreferredLanguage
{
	return [[NSLocale preferredLanguages] objectAtIndex:0];
}



@end
