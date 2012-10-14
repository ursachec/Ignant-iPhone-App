//
//  UIDevice+Ignant.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 14.10.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "UIDevice+Ignant.h"

@implementation UIDevice (Ignant)

+(BOOL)isIphone5
{
	return [[UIScreen mainScreen] bounds].size.height==568;
}

@end
