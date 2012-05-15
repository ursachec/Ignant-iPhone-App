//
//  LoadMoreMosaicView.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 27.04.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//
/*
 
 This class implements a custom control to trigger the loading of further mosaic images

 */


#import "LoadMoreMosaicView.h"

@implementation LoadMoreMosaicView

@synthesize isLoading = _isLoading;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setIsLoading:(BOOL)isLoading
{
    NSLog(@"setIsLoading: %@", isLoading ? @"TRUE" : @"FALSE");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
