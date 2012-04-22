//
//  ImageSlideshowViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 09.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "ImageSlideshowViewController.h"

#import "HJObjManager.h"
#import "HJManagedImageV.h"

@interface ImageSlideshowViewController()
{
    NSUInteger _activePage;
}

@property (strong, nonatomic) HJObjManager *hjObjectManager;
-(void)setUpScrollViewWithImages:(NSArray*)images;
@end

#pragma mark - 

@implementation ImageSlideshowViewController
@synthesize closeSlideshowButton = _closeSlideshowButton;
@synthesize remoteImagesArray = _remoteImagesArray;

@synthesize imageScrollView = _imageScrollView;
@synthesize hjObjectManager = _hjObjectManager;

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
    //setting up the image cache
    self.hjObjectManager = [[HJObjManager alloc] init];
	NSString* cacheDirectory = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/imgcache/imgtable/"] ;
    
    
    //empty the cache when necessary    
    BOOL shouldReset = [[NSUserDefaults standardUserDefaults] boolForKey:@"reset_on_next_start"];
    
    if (shouldReset) {
        NSLog(@"Resetting user data...");
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        
        NSString *readyCacheDirectory = [cacheDirectory stringByAppendingString:@"ready/"];
        for (NSString *file in [fm contentsOfDirectoryAtPath:readyCacheDirectory error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", readyCacheDirectory, file] error:&error];
            if (!success || error) {
                // it failed.
                //                NSLog(@"WARNING: could not delete: %@", file);
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"reset_on_next_start"];
        
        NSLog(@"NSUserDefaults successfully reseted.");
    }
    
    
    //check if the application should cache images
    BOOL shouldCacheImages = [[NSUserDefaults standardUserDefaults] boolForKey:@"enable_image_caching"];
    
    if (!shouldCacheImages) {
        HJMOFileCache* fileCache = [[[HJMOFileCache alloc] initWithRootPath:cacheDirectory] autorelease];
        self.hjObjectManager.fileCache = fileCache;
    }
    
    
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
        HJManagedImageV *newImage = [[HJManagedImageV alloc] initWithFrame:CGRectMake(i*_imageScrollView.frame.size.width, 0, _imageScrollView.frame.size.width, _imageScrollView.frame.size.height)];
        
        NSString *imageURLString = [oneImageDictionary objectForKey:@"url"];
        
        newImage.url = [NSURL URLWithString:imageURLString];
        [_hjObjectManager manage:newImage];
        [self.imageScrollView addSubview:newImage];
        i++;
    }
    
    //set up number of pages of page control
    _slideshowPageControl.numberOfPages = images.count;
    [self.view bringSubviewToFront:_slideshowPageControl];
}


- (IBAction)closeSlideshow:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    [_closeSlideshowButton release];
    [super dealloc];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGPoint cO = scrollView.contentOffset;
    _activePage = (NSUInteger)(cO.x/320.0f);    
    _slideshowPageControl.currentPage = _activePage;
}
@end
