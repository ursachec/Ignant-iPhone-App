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
        self.backgroundColor = [UIColor redColor];
        self.opaque = YES;
    }
    return self;
}

-(void) drawRect:(CGRect)rect
{
    UIImage *image = [UIImage imageNamed:@"toolbarTopNOHexagon"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
}
-(void) changeNavigationBar
{
    NSLog(@"changeNavigationBar");
}

-(void)dealloc
{
    [super dealloc];
}

@end
