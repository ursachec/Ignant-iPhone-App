//
//  MosaicView.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 24.04.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "MosaicView.h"

@interface MosaicView ()
@end

@implementation MosaicView
@synthesize delegate = _delegate;
@synthesize articleId;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {        
        UITapGestureRecognizer *recognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        recognizer2.numberOfTapsRequired = 2;
        [self addGestureRecognizer:recognizer2];
        
        
        UITapGestureRecognizer *recognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [recognizer1 requireGestureRecognizerToFail:recognizer2];
        recognizer1.numberOfTapsRequired = 1;
        [self addGestureRecognizer:recognizer1];
        
    }
    return self;
}

#pragma mark -

-(void)handleDoubleTap:(UITapGestureRecognizer*)recognizer
{
    if([_delegate respondsToSelector:@selector(triggerActionForDoubleTapInView:)])
    {
        [_delegate triggerActionForDoubleTapInView:self];
    }
}

-(void)handleTap:(UITapGestureRecognizer*)recognizer
{
    if([_delegate respondsToSelector:@selector(triggerActionForTapInView:)])
    {
        [_delegate triggerActionForTapInView:self];
    }
}


@end
