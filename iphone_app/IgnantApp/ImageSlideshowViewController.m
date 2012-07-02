//
//  ImageSlideshowViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 09.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "ImageSlideshowViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"

@interface ImageSlideshowViewController()
{
    NSUInteger _activePage;
}


-(void)setUpScrollViewWithImages:(NSArray*)images;
@end

#pragma mark - 

@implementation ImageSlideshowViewController
@synthesize remoteImagesArray = _remoteImagesArray;
@synthesize imageScrollView = _imageScrollView;
@synthesize slideshowPageControl = _slideshowPageControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
        
    NSLog(@"number of remote images: %d", _remoteImagesArray.count);
    
    _imageScrollView.delegate = self;
    _imageScrollView.pagingEnabled = YES;
    
    //set up the scroll view
    [self setUpScrollViewWithImages:_remoteImagesArray];
    
    
    //set up gesture recognizer
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap)];
    recognizer.numberOfTapsRequired = 1;
    [self.imageScrollView addGestureRecognizer:recognizer];
    
    
    //add the specific navigation bar
    [self setIsSpecificNavigationBarHidden:YES animated:NO];
    [self.view addSubview:self.specificNavigationBar];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setIsSpecificNavigationBarHidden:YES animated:NO];
}

-(void)handleDoubleTap
{
    LOG_CURRENT_FUNCTION()
    
    [self toggleShowSpecificNavigationBarAnimated:YES];
}

-(void)handleTapOnSpecificNavBarBackButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - article images cache

-(void)setUpScrollViewWithImages:(NSArray*)images
{
    //first of all remove every subview on the scrolview
    for (UIView *v in [_imageScrollView subviews]) {
            [v removeFromSuperview];
    }
    
    //resize the contentSize of the scrollview to fit the number of images
    _imageScrollView.contentSize = CGSizeMake(images.count*_imageScrollView.frame.size.width, _imageScrollView.frame.size.height);
    
    //add the managed images to the scrollview
    int i = 0;
    
    for (NSDictionary* oneImageDictionary in images) {
        
#warning TODO: check if these params are set right
        NSString *imageURLString = [oneImageDictionary objectForKey:kFKImageURL];
        NSNumber *imageWidth = [oneImageDictionary objectForKey:kFKImageWidth];
        NSNumber *imageHeight = [oneImageDictionary objectForKey:kFKImageHeight];
        
        CGFloat maxWidth = 320.0f;
        CGFloat cImageWidth = 0.0f, cImageHeight = 0.0f, scale = 1.0;
        
        if (imageWidth)
            cImageWidth = (CGFloat)[imageWidth intValue];
        if (imageHeight)
            cImageHeight = (CGFloat)[imageHeight intValue];
        
        
        if (cImageWidth==0) 
            cImageWidth = 320.0f;
        
        if (cImageHeight==0) 
            cImageHeight = _imageScrollView.frame.size.height;  
        
        
        //rescale the width if necessary
        if (cImageWidth>maxWidth) {
            scale = maxWidth/cImageWidth;
            cImageWidth = maxWidth;
            cImageHeight *= scale;
        }
        
        UIImageView *newImageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*_imageScrollView.frame.size.width, (_imageScrollView.frame.size.height-cImageHeight)/2, cImageWidth , cImageHeight)];
        newImageView.backgroundColor = [UIColor clearColor];
        newImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        NSLog(@"imageURLString: %@ cImageWidth: %f , cImageHeight: %f", imageURLString,cImageWidth,cImageHeight);
        
        [newImageView setImageWithURL:[NSURL URLWithString:imageURLString] 
                     placeholderImage:nil 
                              success:^(UIImage* image){ NSLog(@"image.height: %f", image.size.width);} 
                              failure:^(NSError* error){ NSLog(@"error"); 
                              }];
        
        
        [self.imageScrollView addSubview:newImageView];

        i++;
    }
    
    //set up number of pages of page control
    _slideshowPageControl.numberOfPages = images.count;
    [self.view bringSubviewToFront:_slideshowPageControl];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGPoint cO = scrollView.contentOffset;
    _activePage = (NSUInteger)(cO.x/320.0f);    
    _slideshowPageControl.currentPage = _activePage;
    
    [scrollView layoutSubviews];
}
@end
