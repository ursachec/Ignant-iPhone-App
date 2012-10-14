//
//  IgnantNavigationBar.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 29.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import "IgnantNavigationBar.h"

@implementation IgnantNavigationBar
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
		
		UIImage *backgroundPortrait = [[UIImage imageNamed: @"navbar_background_portrait"]
													 resizableImageWithCapInsets: UIEdgeInsetsMake(0, 0, 0, 0)];
		[self setBackgroundImage: backgroundPortrait
				   forBarMetrics: UIBarMetricsDefault];
		
		UIImage *backgroundLandscape = [[UIImage imageNamed: @"navbar_background_landscape"]
									   resizableImageWithCapInsets: UIEdgeInsetsMake(0, 0, 0, 0)];
		[self setBackgroundImage: backgroundLandscape
				   forBarMetrics: UIBarMetricsLandscapePhone];
    }
    return self;
}


@end
