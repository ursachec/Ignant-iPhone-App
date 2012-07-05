//
//  CategoryCell.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 28.06.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "CategoryCell.h"


CGFloat const kCategoryCellHeight = 62.1f;

@interface CategoryCell()
@property(nonatomic,strong,readwrite) UIView *overlayView;
@property(nonatomic, readwrite, strong) UILabel* titleLabel;
@end

#define COLOR_BACKGROUND_VIEW [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]
#define COLOR_SELECTED_BACKGROUND_VIEW [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]

@implementation CategoryCell
@synthesize overlayView = _overlayView;
@synthesize titleLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
#define DEBUG_SHOW_HELP_COLORS false
        
        self.opaque = YES;
        
        
        CGRect oldRect = self.contentView.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, oldRect.origin.y, oldRect.size.width, kCategoryCellHeight);
        
        UIView* newContentView = [[UIView alloc] initWithFrame:newRect];
        newContentView.backgroundColor = [UIColor clearColor];
        
        //--- add the image icon to the category cell
        CGSize imageSize = CGSizeMake(18.0f, 20.0f);
        CGFloat paddingLeft = 10.0f;
        
        //--- titleLabel
        CGSize labelSize = CGSizeMake(newContentView.frame.size.width-paddingLeft, newContentView.frame.size.height);
        CGRect labelFrame = CGRectMake(paddingLeft, 0.0f , labelSize.width, labelSize.height);
        UILabel *aTitleLabel = [[UILabel alloc] initWithFrame:labelFrame];
        aTitleLabel.backgroundColor = [UIColor colorWithRed:0 green:1.0f blue:0 alpha:0.f];
        aTitleLabel.font = [UIFont fontWithName:@"Georgia" size:14.0f];
        
#if DEBUG_SHOW_HELP_COLORS
        aTitleLabel.backgroundColor = [UIColor greenColor];
#endif
        self.titleLabel = aTitleLabel;
        [newContentView addSubview:aTitleLabel];
        
        
        //--- arrow
        CGFloat paddingRight = 10.0f;
        CGFloat ratio = .5f;
        CGSize arrowSize = CGSizeMake(17.0f*ratio, 26.0f*ratio);
        CGRect arrowViewFrame = CGRectMake(newContentView.frame.size.width-arrowSize.width-paddingRight, (newContentView.frame.size.height-arrowSize.height)/2, arrowSize.width, arrowSize.height);
        UIImageView* arrowView = [[UIImageView alloc] initWithFrame:arrowViewFrame];
        arrowView.image = [UIImage imageNamed:@"arrow_right.png"];
        
#if DEBUG_SHOW_HELP_COLORS
        arrowView.backgroundColor = [UIColor redColor];
#endif
        
        [newContentView addSubview:arrowView];
        
        
        //separator
        CGSize separatorSize = CGSizeMake(320.0f, 1.0f);
        UIView* aSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0, newContentView.bounds.size.height-separatorSize.height, separatorSize.width, separatorSize.height)];
        aSeparatorView.backgroundColor = [UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:1.0f];
        [newContentView addSubview:aSeparatorView];
        
        //--- overlay view
        UIView* aOverlayView =[[UIView alloc] initWithFrame:newContentView.bounds];
        aOverlayView.backgroundColor = [UIColor colorWithRed:.0 green:.0f blue:.0f alpha:.0f];
        [newContentView addSubview:aOverlayView];
        self.overlayView = newContentView;
        
        [self.contentView addSubview:newContentView];
        
        
        //background view
        UIView *bV =[[UIView alloc] initWithFrame:newContentView.bounds]; 
        bV.backgroundColor = COLOR_BACKGROUND_VIEW;
        self.backgroundView = bV;
        
        //selected background view
        UIView *sbV =[[UIView alloc] initWithFrame:newContentView.bounds]; 
        sbV.backgroundColor = COLOR_SELECTED_BACKGROUND_VIEW;
        self.selectedBackgroundView = sbV;
        
    }
    return self;
}

-(void)configureWithTitle:(NSString*)title
{
    self.titleLabel.text = title;
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        _overlayView.frame = self.contentView.bounds;
        _overlayView.backgroundColor = [UIColor colorWithRed:.0f green:0.f blue:0.f alpha:.1f];
    }
}

@end
