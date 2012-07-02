//
//  IgnantNoInternetConnectionView.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 06.06.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "IgnantNoInternetConnectionView.h"

@implementation IgnantNoInternetConnectionView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:1.0f green:0.0f blue:1.0f alpha:1.0f];
        
        
        
        
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

- (IBAction)retryToLoadData:(id)sender {
    if ([_delegate respondsToSelector:@selector(retryToLoadData)]) {
        [_delegate retryToLoadData];
    }
}
@end
