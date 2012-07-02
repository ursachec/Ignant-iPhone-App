//
//  IgnantLoadingMoreCell.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 05.03.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "IgnantLoadingMoreCell.h"

@implementation IgnantLoadingMoreCell
@synthesize morePostsView, loadingContentView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        //setting up the load more content view
        CGRect rectWithRightHeight = self.frame;
        rectWithRightHeight.size.height = 40.0f;
        
        
        //set the background view properties
        UIView *backgroundView = [[UIView alloc] initWithFrame:rectWithRightHeight];
        backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundView = backgroundView;
        
        //set the selected background view properties
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:rectWithRightHeight];
        selectedBackgroundView.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = selectedBackgroundView;
        
        
        //add the activity indicator and start animating
        UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGSize activityIndicatorSize = CGSizeMake(21.0f, 21.0f);
        CGFloat scalingFactor = 0.8;
        
        activityIndicator.frame = CGRectMake((rectWithRightHeight.size.width-activityIndicatorSize.width*scalingFactor)/2, (rectWithRightHeight.size.height-activityIndicatorSize.height*scalingFactor)/2, activityIndicatorSize.width*scalingFactor, activityIndicatorSize.height*scalingFactor);
        [activityIndicator.layer setValue:[NSNumber numberWithFloat:scalingFactor] forKeyPath:@"transform.scale"];
        
        [self.contentView addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
