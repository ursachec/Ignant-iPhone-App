//
//  TumblrCell.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 10.06.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "TumblrCell.h"

@interface TumblrCellContentView : UIView 
{
    TumblrCell *_cell;
    BOOL _highlighted;
}
@end

@implementation TumblrCellContentView

- (id)initWithFrame:(CGRect)frame cell:(TumblrCell *)cell
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

@end

@implementation TumblrCell
@synthesize cellContentView;
@synthesize tumblrImageView;

#define COLOR_BACKGROUND_VIEW [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]
#define COLOR_SELECTED_BACKGROUND_VIEW [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.opaque = YES;
        
        cellContentView = [[TumblrCellContentView alloc] initWithFrame:self.contentView.bounds cell:self];
        
        cellContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cellContentView.contentMode = UIViewContentModeLeft;
        [self.contentView addSubview:cellContentView];

        tumblrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9,9,302,302)];
        [tumblrImageView setBackgroundColor:IGNANT_GRAY_COLOR];
        [self.contentView addSubview:tumblrImageView];


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
