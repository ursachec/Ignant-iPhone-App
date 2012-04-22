//
//  IgnantLoadMoreCell.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 07.03.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "IgnantLoadMoreCell.h"

@implementation IgnantLoadMoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
#define SHOW_DEBUG_COLORS NO
        
        //setting up the load more content view
        CGRect loadMoreRect = self.frame;
        loadMoreRect.size.height = 60.0f;
        
        UIView *loadMoreView = [[UIView alloc] initWithFrame:loadMoreRect];
        
        if(SHOW_DEBUG_COLORS)
        loadMoreView.backgroundColor = [UIColor cyanColor];
                
        
        //set up the text label
        CGSize customTextLabelSize = CGSizeMake(100.0f, 30.0f);
        UILabel *customTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, (loadMoreView.frame.size.height-customTextLabelSize.height)/2, customTextLabelSize.width, customTextLabelSize.height)];
        customTextLabel.text = @"More posts";
        
        if(SHOW_DEBUG_COLORS)
        customTextLabel.backgroundColor = [UIColor redColor];
        
        customTextLabel.font = [UIFont fontWithName:@"Georgia" size:15.0f];;
        [loadMoreView addSubview:customTextLabel];
        
        
        //set up the small + sign imageview
        CGSize plusSignSize = CGSizeMake(13.0f, 13.0f);
        CGRect plusSignFrame = CGRectMake(customTextLabel.frame.origin.x-plusSignSize.width-10.0f, (loadMoreView.frame.size.height-plusSignSize.height)/2, plusSignSize.width, plusSignSize.height);
        UIImageView *plusSign = [[UIImageView alloc] initWithFrame:plusSignFrame];
        plusSign.image = [UIImage imageNamed:@"cellLoadMorePlusSign"];
        
        if(SHOW_DEBUG_COLORS)
        plusSign.backgroundColor = [UIColor blackColor];
        
        [loadMoreView addSubview:plusSign];
        
        
        
        
        [customTextLabel release];
        
        [self.contentView addSubview:loadMoreView];
        [loadMoreView release];
        [plusSign release];
        
        
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        selectedBackgroundView.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = selectedBackgroundView;
        [selectedBackgroundView release];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
