//
//  MosaicView.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 24.04.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "MosaicView.h"

@interface MosaicView ()
{
    BOOL _shouldTriggerFinalizingAnimation;
}
@end

@implementation MosaicView
@synthesize delegate = _delegate;
@synthesize articleId;
@synthesize articleTitle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
        
        UITapGestureRecognizer *longPressGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:longPressGestureRecognizer];
        
        
    }
    return self;
}

#pragma mark -

-(void)handleTap:(UITapGestureRecognizer*)recognizer
{

    if(self.delegate!=nil)
    {
        [_delegate triggerActionForTapInView:self];
    }
}


@end
