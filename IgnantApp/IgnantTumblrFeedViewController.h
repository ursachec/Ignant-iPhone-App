//
//  IgnantTumblrFeedViewController.h
//  OtherTests
//
//  Created by Claudiu-Vlad Ursache on 4/3/12.
//  Copyright (c) 2012 Cortado AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGNViewController.h"

#import "EGORefreshTableHeaderView.h"

@interface IgnantTumblrFeedViewController : IGNViewController <EGORefreshTableHeaderDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tumblrTableView;

@end
