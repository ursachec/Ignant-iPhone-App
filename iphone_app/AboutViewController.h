//
//  AboutViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 04.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGNViewController.h"

@interface AboutViewController : IGNViewController
@property (retain, nonatomic) IBOutlet UIScrollView *aboutScrollView;
@property (retain, nonatomic) IBOutlet UITextView *aboutTextView;
@property (retain, nonatomic) IBOutlet UIImageView *aboutImageView;

@end
