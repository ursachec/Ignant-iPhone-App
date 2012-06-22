//
//  PolynomialLineView.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 12/22/11.
//  Copyright (c) 2011 Cortado AG. All rights reserved.
//

#import "PolynomialLineView.h"

@implementation PolynomialLineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
//        self.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.3];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"overwridden drawRect");
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect contentRect = self.bounds;
    
    CGFloat lineWidth = 320;
    int iterations = 0;
    
    //create different number of iterations
    
    //20% chance for a line with many iterations
    
    int chanceInt = rand()%5;
    if (chanceInt==0) 
    {
        iterations = 15+rand()%25;
    }
    else
    {
        iterations = 4+rand()%5;
    }
    
    
    CGFloat cgBaseline = 10;
    
    // Create the two paths, cgpath and uipath.
    CGMutablePathRef cgpath = CGPathCreateMutable();
    CGPathMoveToPoint(cgpath, NULL, 0, cgBaseline);
    
    CGFloat xincrement = lineWidth / (CGFloat)iterations;
    
    int counter = iterations;
    
    for (CGFloat x1 = 0, x2 = xincrement; 
         (x2 < lineWidth || counter>0 );
         x1 = x2, x2 += xincrement)
    {        
        CGPathAddCurveToPoint(cgpath, NULL, x1, ( rand()%2==0 ? cgBaseline-rand()%20 : cgBaseline+rand()%20 ) , x2-rand()%15,  ( rand()%2==0 ? cgBaseline-rand()%20 : cgBaseline+rand()%20 ), x2, cgBaseline);
        counter--;
    }
    
    CGPathMoveToPoint(cgpath, NULL, contentRect.size.width, cgBaseline);
    
    
    [[UIColor blackColor] setStroke];
    CGContextAddPath(ctx, cgpath);
    
    
    // Stroke each path
    CGContextSaveGState(ctx); 
    
    // configure context the same as uipath
    CGContextSetLineWidth(ctx, 0.9);
    CGContextSetLineJoin(ctx,kCGLineJoinMiter);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetMiterLimit(ctx, 2.0);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    CGPathRelease(cgpath);
  
}

- (void)strokeUIBezierPath:(UIBezierPath*)path
{
    [path stroke];
}


@end
