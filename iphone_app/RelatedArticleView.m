//
//  RelatedArticleView.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 13.03.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "RelatedArticleView.h"


@implementation RelatedArticleView
@synthesize thumbImage;
@synthesize categoryName;
@synthesize articleName;

-(id)initWithFrame:(CGRect)frame articleName:(NSString*)articleName articleCategory:(NSString*)categoryName articleThumb:(UIImage*)articleThumbImage
{
    self = [super initWithFrame:frame];
    if (self) {

        
        
        
    }
    return self;
    
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
