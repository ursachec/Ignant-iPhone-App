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
        loadMoreRect.size.height = 40.0f;
        
        UIView *loadMoreView = [[UIView alloc] initWithFrame:loadMoreRect];
        
        if(SHOW_DEBUG_COLORS)
        loadMoreView.backgroundColor = [UIColor cyanColor];
            
        [self.contentView addSubview:loadMoreView];
        
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        selectedBackgroundView.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = selectedBackgroundView;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
