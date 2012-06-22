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
@synthesize closeSlideshowButton = _closeSlideshowButton;
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
    // Do any additional setup after loading the view from its nib.
    
    
    //bring the button to front
    [self.view bringSubviewToFront:_closeSlideshowButton];
    
    
    NSLog(@"number of remote images: %d", _remoteImagesArray.count);
    
    _imageScrollView.delegate = self;
    _imageScrollView.pagingEnabled = YES;
    
//    //set up the scroll view
    [self setUpScrollViewWithImages:_remoteImagesArray];
}

- (void)viewDidUnload
{
    [self setCloseSlideshowButton:nil];
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


- (IBAction)closeSlideshow:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - UIScrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGPoint cO = scrollView.contentOffset;
    _activePage = (NSUInteger)(cO.x/320.0f);    
    _slideshowPageControl.currentPage = _activePage;
    
    [scrollView layoutSubviews];
}
@end
