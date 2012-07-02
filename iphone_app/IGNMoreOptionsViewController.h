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
@property (retain, nonatomic) IBOutlet UITableView *moreOptionsTableView;

@end
