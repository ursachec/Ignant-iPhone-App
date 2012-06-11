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
        rectWithRightHeight.size.height = 60.0f;
        
        
        
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
        CGSize activityIndicatorSize = CGSizeMake(25.0f, 25.0f);
        activityIndicator.frame = CGRectMake(105.0f, (rectWithRightHeight.size.height-activityIndicatorSize.height)/2, activityIndicatorSize.width, activityIndicatorSize.height);
        [self.contentView addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        
        //add the message label
//        CGSize messageLabelSize = CGSizeMake(self.frame.size.width - activityIndicator.frame.size.width,  rectWithRightHeight.size.height);
        CGSize messageLabelSize = CGSizeMake(70.0f,  rectWithRightHeight.size.height);
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(activityIndicator.frame.origin.x+activityIndicator.frame.size.width, 0, messageLabelSize.width , messageLabelSize.height)];
        messageLabel.text = @"loading...";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.textAlignment = UITextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Georgia" size:14.0f];
        messageLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:messageLabel];
        
          
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
