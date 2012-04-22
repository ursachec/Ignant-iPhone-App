//
//  IgnantCell.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 12/23/11.
//  Copyright (c) 2011 Cortado AG. All rights reserved.
//

#import "IgnantCell.h"


@interface IgnantCellContentView : UIView 
{
    IgnantCell *_cell;
    BOOL _highlighted;
}
@end

@implementation IgnantCellContentView

- (id)initWithFrame:(CGRect)frame cell:(IgnantCell *)cell
{
    if (self = [super initWithFrame:frame])
    {        
        _cell = cell;
        
        self.opaque = YES;
        self.backgroundColor = _cell.backgroundColor;
    }
    
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    [self setNeedsDisplay];
}

- (BOOL)isHighlighted
{
    return _highlighted;
}

- (void)drawRect:(CGRect)rect
{
    
#define IGNANT_GRAY_COLOR [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0]
#define IGNANT_BLACK_COLOR [UIColor blackColor]
    
#define PADDING_RIGHT 5.0f
#define PADDING_LEFT 100.0f
#define PADDING_TOP 10.0f   
#define PADDING_BOTTOM 5.0f

#define TITLE_WIDTH 130.0f
#define TITLE_FONT_SIZE 12.0f
    
#define DESCRIPTION_WIDTH 180.0f
#define DESCRIPTION_FONT_SIZE 13.0f
    
#define DATE_WIDTH 100.0f  
#define DATE_FONT_SIZE 10.0f
    
    
#define PADDING_FOR_TEXTS 170.0f
    
    //image size: 148 * 96
    CGRect contentRect = self.bounds;

    UIFont *titleFont = [UIFont fontWithName:@"Georgia" size:TITLE_FONT_SIZE];
    UIFont *dateFont = [UIFont fontWithName:@"Georgia-Italic" size:DATE_FONT_SIZE];
    
    CGPoint pointToDraw = CGPointMake(0, 0);
    CGFloat actualFontSize = 0.0f;
    CGSize size = CGSizeMake(0, 0);
    CGSize titleSize = CGSizeMake(0, 0);
    
    //draw article name
    [[UIColor blackColor] set];
    CGPoint pointToDrawArticleName = CGPointMake(PADDING_FOR_TEXTS, 37.0f);
    NSString *title = _cell.title;
    titleSize = [title sizeWithFont:titleFont minFontSize:TITLE_FONT_SIZE actualFontSize:&actualFontSize forWidth:TITLE_WIDTH lineBreakMode:UILineBreakModeTailTruncation];
    titleSize = [title drawAtPoint:pointToDrawArticleName forWidth:TITLE_WIDTH withFont:titleFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines]; 
    
    //draw category name
    [IGNANT_BLACK_COLOR set];
    CGSize categoryNameSize = CGSizeMake(0, 0);
    NSString *categoryName = [_cell.categoryName stringByAppendingFormat:@" ∙ "];
    size = [categoryName sizeWithFont:dateFont minFontSize:DATE_FONT_SIZE actualFontSize:&actualFontSize forWidth:DATE_WIDTH lineBreakMode:UILineBreakModeTailTruncation];
    pointToDraw = CGPointMake(PADDING_FOR_TEXTS, pointToDrawArticleName.y+size.height);
    size = [categoryName drawAtPoint:pointToDraw forWidth:DATE_WIDTH withFont:dateFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    categoryNameSize = size;
    
    
    //draw date
    [IGNANT_BLACK_COLOR set];
    NSString *date = _cell.dateString;
    size = [date sizeWithFont:dateFont minFontSize:DATE_FONT_SIZE actualFontSize:&actualFontSize forWidth:DATE_WIDTH lineBreakMode:UILineBreakModeTailTruncation];
    pointToDraw = CGPointMake(PADDING_FOR_TEXTS+categoryNameSize.width, pointToDrawArticleName.y+size.height);
    size = [date drawAtPoint:pointToDraw forWidth:DATE_WIDTH withFont:dateFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];  
    
    //draw bottom line
    [IGNANT_GRAY_COLOR set];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(ctx, 0.85, 0.85, 0.85, 1.0);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextMoveToPoint(ctx, 0, 102);
    CGContextAddLineToPoint(ctx, 320,102);
    CGContextStrokePath(ctx);
    
    //draw middle line
    CGContextSetRGBStrokeColor(ctx, 0.85, 0.85, 0.85, 1.0);
    CGContextSetLineWidth(ctx, 4.0f);
    CGContextMoveToPoint(ctx, 160, .0f);
    CGContextAddLineToPoint(ctx, 160, 97.0f);
    CGContextStrokePath(ctx);
    
    
    //draw the arrow
    UIImage *arrowImage = [UIImage imageNamed:@"ignantCellArrow.png"];
    CGSize arrowImageSize = CGSizeMake(20.0f, 30.0f);
    CGRect arrowImageRect = CGRectMake(contentRect.size.width-arrowImageSize.width-PADDING_RIGHT, (contentRect.size.height-arrowImageSize.height)/2, arrowImageSize.width, arrowImageSize.height);
    [arrowImage drawInRect:arrowImageRect];
    
    
    //draw thumb image
    //    UIImage *thumbImage = []; _cell.imageIdentifier
#pragma mark - drawing the thumbImage    
#define MAX_IMAGE_WIDTH 148.0f
//    296 x 194
    
#warning maybe add this out of drawrect if performance issues arise
    
//    NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    applicationDocumentsDir = [applicationDocumentsDir stringByAppendingFormat:@"thumbs/"];
//    NSString *storePath = [applicationDocumentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg",_cell.imageIdentifier]];
//    
//    UIImage *someImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:storePath]];
    
//    NSLog(@"someImageSize: %@, storePath: %@", NSStringFromCGSize(someImage.size), storePath);
    
    CGFloat ratio = 296.0f/194.0f;
    CGRect imageRect = CGRectMake(5.0f, 0.0f, 149, 97);
    [_cell.thumbImage drawInRect:imageRect];
    
}


@end

@implementation IgnantCell
@synthesize cellContentView;
@synthesize thumbImage, title, categoryName, dateString;
@synthesize managedImage;

@synthesize imageIdentifier;

#define COLOR_BACKGROUND_VIEW [UIColor colorWithRed:1 green:1 blue:1 alpha:1]
#define COLOR_SELECTED_BACKGROUND_VIEW [UIColor colorWithRed:1 green:1 blue:1 alpha:1]

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.opaque = YES;
        
        cellContentView = [[IgnantCellContentView alloc] initWithFrame:self.contentView.bounds cell:self];
        
        cellContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cellContentView.contentMode = UIViewContentModeLeft;
        [self.contentView addSubview:cellContentView];
        
        
        
//        CGFloat ratio = 296.0f/194.0f;
//        CGRect imageRect = CGRectMake(5.0f, 0.0f, MAX_IMAGE_WIDTH, MAX_IMAGE_WIDTH/ratio);
//        [_cell.thumbImage drawInRect:imageRect];
//        
//        UIImageView *thumbImageView = [[UIImageView alloc] initWithImage:thumbImage];
//        
//        [cellContentView addSubview:thumbImage];
        
        
//        CGFloat ratio = 375.0f/245.0f;
//        CGFloat width = 20.0f;
//        
//        managedImage.frame = CGRectMake(10.0, 10.0, width, width*ratio);
//        [self.contentView addSubview:managedImage];
        
        
        
        self.backgroundView =[[UIView alloc] initWithFrame:self.bounds]; 
        self.backgroundView.backgroundColor = COLOR_BACKGROUND_VIEW;
        
        self.selectedBackgroundView =[[UIView alloc] initWithFrame:self.bounds]; 
        self.selectedBackgroundView.backgroundColor = COLOR_SELECTED_BACKGROUND_VIEW;
        
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    cellContentView.backgroundColor = backgroundColor;
}
-(void)dealloc{
    
    [super dealloc];
    
    [cellContentView release];
}


@end
