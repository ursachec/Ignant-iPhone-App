//
//  IgnantCell.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 12/23/11.
//  Copyright (c) 2011 Cortado AG. All rights reserved.
//

#import "IgnantCell.h"
#import "Constants.h"

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
    
#define CELL_PADDING_TOP 5.0f
    
#define PADDING_RIGHT 0.0f
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
#define PADDING_FOR_DATE_AND_CATEGORY_LABELS 3.0f
    
    //image size: 148 * 96
    CGRect contentRect = self.bounds;

    UIFont *titleFont = [UIFont fontWithName:@"Georgia" size:TITLE_FONT_SIZE];
    UIFont *dateFont = [UIFont fontWithName:@"Georgia" size:DATE_FONT_SIZE];
    
    CGPoint pointToDraw = CGPointMake(0, 0);
    CGFloat actualFontSize = 0.0f;
    CGSize size = CGSizeMake(0, 0);
    CGSize titleSize = CGSizeMake(0, 0);
        
    //draw the arrow
    [IGNANT_GRAY_COLOR set];
    UIImage *arrowImage = [UIImage imageNamed:@"ignantCellArrow.png"];
    CGSize arrowImageSize = CGSizeMake(20.0f, 30.0f);
    CGRect arrowImageRect = CGRectMake(contentRect.size.width-arrowImageSize.width-PADDING_RIGHT, (contentRect.size.height-arrowImageSize.height-CELL_PADDING_TOP)/2, arrowImageSize.width, arrowImageSize.height);
    [arrowImage drawInRect:arrowImageRect];
    
    //draw article name
    [[UIColor blackColor] set];
    
    NSString *title = _cell.title;
    titleSize = [title sizeWithFont:titleFont minFontSize:TITLE_FONT_SIZE actualFontSize:&actualFontSize forWidth:TITLE_WIDTH lineBreakMode:UILineBreakModeTailTruncation];
    CGPoint pointToDrawArticleName = CGPointMake(PADDING_FOR_TEXTS, (contentRect.size.height-titleSize.height-CELL_PADDING_TOP)/2 );
    titleSize = [title drawAtPoint:pointToDrawArticleName forWidth:TITLE_WIDTH withFont:titleFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines]; 
    
    //draw category name
    [IGNANT_GRAY_COLOR set];
    CGSize categoryNameSize = CGSizeMake(0, 0);
    NSString *categoryName = _cell.categoryName; //stringByAppendingFormat:@" ∙ "]
    size = [categoryName sizeWithFont:dateFont minFontSize:DATE_FONT_SIZE actualFontSize:&actualFontSize forWidth:DATE_WIDTH lineBreakMode:UILineBreakModeTailTruncation];
    pointToDraw = CGPointMake(PADDING_FOR_TEXTS, pointToDrawArticleName.y+size.height+2.0f);
    size = [categoryName drawAtPoint:pointToDraw forWidth:DATE_WIDTH withFont:dateFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    categoryNameSize = size;
    
    //draw date
    [IGNANT_GRAY_COLOR set];
    NSString *date = _cell.dateString;
    size = [date sizeWithFont:dateFont minFontSize:DATE_FONT_SIZE actualFontSize:&actualFontSize forWidth:DATE_WIDTH lineBreakMode:UILineBreakModeTailTruncation];
    pointToDraw = CGPointMake(PADDING_FOR_TEXTS, pointToDrawArticleName.y-size.height);
    size = [date drawAtPoint:pointToDraw forWidth:DATE_WIDTH withFont:dateFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];  
    
    //draw bottom line
    [IGNANT_GRAY_COLOR set];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(ctx, 0.85, 0.85, 0.85, 1.0);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextMoveToPoint(ctx, 0.0f, contentRect.size.height-1.0f);
    CGContextAddLineToPoint(ctx, 320.0f, contentRect.size.height-1.0f);
    CGContextStrokePath(ctx);
}

@end

@implementation IgnantCell
@synthesize cellContentView;
@synthesize cellImageView;
@synthesize title, categoryName, dateString;

#define COLOR_BACKGROUND_VIEW [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]
#define COLOR_SELECTED_BACKGROUND_VIEW [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]
#define COLOR_IMAGEVIEW_BACKGROUND [UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:0.2f]

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.opaque = YES;
        
        cellContentView = [[IgnantCellContentView alloc] initWithFrame:self.contentView.bounds cell:self];
        
        cellContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cellContentView.contentMode = UIViewContentModeLeft;
        [self.contentView addSubview:cellContentView];
        
        cellImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 149.0f,97.0f)];
        cellImageView.backgroundColor = COLOR_IMAGEVIEW_BACKGROUND;
        [self.contentView addSubview:cellImageView];
                
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

@end
