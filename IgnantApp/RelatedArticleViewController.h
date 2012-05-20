//
//  RelatedArticleViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 13.03.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IGNViewController.h"

@interface RelatedArticleViewController : IGNViewController

@property (retain, nonatomic) IBOutlet UIButton *dismissViewController;

- (IBAction)dismissViewController:(id)sender;

@end
