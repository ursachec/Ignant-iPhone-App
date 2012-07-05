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
@property(nonatomic, strong) UIActivityIndicatorView* activityIndicator;
@end

@implementation LoadMoreMosaicView
@synthesize activityIndicator = _activityIndicator;
@synthesize isLoading = _isLoading;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGSize viewSize = frame.size;
        CGSize activityIndicatorSize = CGSizeMake(20.0f, 20.0f);
        CGRect activityIndicatorFrame = CGRectMake((viewSize.width-activityIndicatorSize.width)/2, (viewSize.height-activityIndicatorSize.height)/2, activityIndicatorSize.width, activityIndicatorSize.height);
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.backgroundColor = [UIColor clearColor];
        _activityIndicator.frame = activityIndicatorFrame;
        [_activityIndicator setHidesWhenStopped:YES];
        
        CGFloat scalingFactor = 0.8f;
        [_activityIndicator.layer setValue:[NSNumber numberWithFloat:scalingFactor] forKeyPath:@"transform.scale"];
        
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
