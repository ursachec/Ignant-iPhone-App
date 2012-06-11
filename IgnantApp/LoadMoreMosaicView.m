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

@interface LoadMoreMosaicView ()
@property(nonatomic) UIActivityIndicatorView* activityIndicator;
@end

@implementation LoadMoreMosaicView
@synthesize activityIndicator = _activityIndicator;
@synthesize isLoading = _isLoading;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGSize activityIndicatorSize = CGSizeMake(20.0f, 20.0f);
        CGRect activityIndicatorFrame = CGRectMake(0.0f, 0.0f, activityIndicatorSize.width, activityIndicatorSize.height);
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.frame = activityIndicatorFrame;
        [_activityIndicator setHidesWhenStopped:YES];
        [self addSubview:_activityIndicator];
        
    }
    return self;
}


-(void)setIsLoading:(BOOL)isLoading
{    
    if (isLoading) {
        [_activityIndicator startAnimating];
    }
    else {
        [_activityIndicator stopAnimating];
    }

    [self setNeedsDisplay];
}

@end
