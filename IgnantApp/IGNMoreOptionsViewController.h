//
//  IGNMoreOptionsViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 03.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGNViewController.h"

@interface IGNMoreOptionsViewController : IGNViewController <UITableViewDelegate, UITableViewDataSource>

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@property (retain, nonatomic) IBOutlet UITableView *moreOptionsTableView;

@end
