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

@property(nonatomic,retain) NSArray *remoteImagesArray;

@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;
- (IBAction)closeSlideshow:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *closeSlideshowButton;

@property (retain, nonatomic) IBOutlet UIPageControl *slideshowPageControl;

@end
