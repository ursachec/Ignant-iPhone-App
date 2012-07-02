//
//  IgnantLoadingView.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 07.01.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "IgnantLoadingView.h"

@interface IgnantLoadingView()

@end

@implementation IgnantLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        
        
        //just temporary
        CGSize sizeForActivityIndicator = CGSizeMake(40, 40);
        CGRect frameForActivityIndicator = CGRectMake( (self.frame.size.width - sizeForActivityIndicator.width)/2, (self.frame.size.height - sizeForActivityIndicator.height)/2, sizeForActivityIndicator.width, sizeForActivityIndicator.height);
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:frameForActivityIndicator];
        activityIndicator.color = [UIColor blackColor];
        [activityIndicator startAnimating];
        [self addSubview:activityIndicator];
        
    }
    return self;
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
