//
//  ImageSlideshowViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 09.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGNViewController.h"

@interface ImageSlideshowViewController : IGNViewController <UIScrollViewDelegate>

@property(nonatomic,strong) NSArray *remoteImagesArray;

@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;
- (IBAction)closeSlideshow:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *closeSlideshowButton;

@property (strong, nonatomic) IBOutlet UIPageControl *slideshowPageControl;

@end
