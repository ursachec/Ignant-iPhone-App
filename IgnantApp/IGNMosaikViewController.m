//
//  IGNMosaikViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 03.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "IGNMosaikViewController.h"

#import "IGNDetailViewController.h"

#import "IGNAppDelegate.h"

//import custom views
#import "LoadMoreMosaicView.h"
#import "MosaicView.h"

//imports for ASIHTTPRequest
#import "ASIHTTPRequest.h"
#import "NSURL+stringforurl.h"

#import "Constants.h"

#warning TODO: see what image size to use / maybe do some server directory selection to differentiate between Retina and NON-Retina display versions

static int kMinimumMosaicImagesLoaded = 1;

NSString *const filenameForMosaicImagesPlist = @"mosaic_images.plist";


NSString * const kImagesKey = @"images";

NSString * const kImageWidth = @"width";
NSString * const kImageHeight = @"height";
NSString * const kImageUrl = @"url";
NSString * const kImageArticleId = @"articleId";
NSString * const kImageArticleTitle = @"articleTitle";
NSString * const kImageFilename = @"filename";


#define DIRECTORY_FOR_MOSAIC_IMAGES_FILE [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]


@interface IGNMosaikViewController ()
{
    BOOL _isLoadingMoreMosaicImages;
    int _numberOfActiveRequests;
    
    IGNAppDelegate* appDelegate;    
}
@property(nonatomic,retain) NSArray* savedMosaicImages;
@property (nonatomic,retain) UIView* overlayView;

@property(nonatomic,retain) IGNDetailViewController* detailViewController;

@property(nonatomic,retain) LoadMoreMosaicView* loadingMoreMosaicView;

-(void)drawSavedMosaicImages;
-(void)addMoreMosaicImages:(NSArray*)mosaicImages;
-(void)loadMoreMosaicImages;

-(void)setUpOverlayViewForAnimationUsingMosaicView:(MosaicView*)view;

-(void)transitionToDetailViewControllerForArticleId:(NSString*)articleId;

@end

#pragma mark -

@implementation IGNMosaikViewController
@synthesize bigMosaikView;
@synthesize mosaikScrollView;
@synthesize closeMosaikButton;
@synthesize savedMosaicImages;
@synthesize overlayView = _overlayView;
@synthesize detailViewController;
@synthesize parentNavigationController;
@synthesize isMosaicImagesArrayNotEmpty = _isMosaicImagesArrayNotEmpty;
@synthesize loadingMoreMosaicView = _loadingMoreMosaicView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _numberOfActiveRequests = 0;
        
        _isLoadingMoreMosaicImages = NO;
        
        appDelegate = (IGNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(NSString*)currentCategoryId
{
    NSString* categoryId = [NSString stringWithFormat:@"%d",kCategoryIndexForMosaik];
    return categoryId;
}

#pragma mark - helpful methods
-(BOOL)isMosaicImagesArrayNotEmpty
{
    NSArray *s = self.savedMosaicImages;
    
    
    return [self.savedMosaicImages count]<kMinimumMosaicImagesLoaded;
}

#pragma mark - handle going back
-(IBAction)handleBack:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //add the back-to-start button
    UIImage *backButtonImage = [UIImage imageNamed:@"backButton.png"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat ratio = .65;
    backButton.frame = CGRectMake(0, 0, 46*ratio, 30*ratio);
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(handleBack:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    //trigger the drawing for the images
    [self drawSavedMosaicImages];
    
    //check if the mosaicImages are loaded and trigger a load if not
    if(self.isMosaicImagesArrayNotEmpty)
    {
        [self loadMoreMosaicImages];
    }
    
    // add the big mosaik view to the content scrollview
    self.bigMosaikView.userInteractionEnabled = YES;
    [self.mosaikScrollView addSubview:self.bigMosaikView];
    
    //set up the overlay view
    UIView* overlayView = [[UIView alloc] initWithFrame:self.view.frame];
    overlayView.backgroundColor = [UIColor whiteColor];
    self.overlayView = overlayView;
    [overlayView release];
}

- (void)viewDidUnload
{
    
    self.loadingMoreMosaicView = nil;
    self.overlayView = nil;
    
    [self setBigMosaikView:nil];
    [self setMosaikScrollView:nil];
    [self setCloseMosaikButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_overlayView release];
    [bigMosaikView release];
    [mosaikScrollView release];
    [closeMosaikButton release];
    [super dealloc];
}

#pragma mark - server communication actions
-(void)loadMoreMosaicImages
{    
    _numberOfActiveRequests++;
    
    //show a covering loading view if mosaic images array is empty
    if(self.isMosaicImagesArrayNotEmpty)
    {
        [self setIsLoadingViewHidden:NO];
    }
    
    self.loadingMoreMosaicView.isLoading = YES;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetSetOfMosaicImages,kParameterAction, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
    
    NSLog(@"encodedString go: %@",encodedString);
    
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:encodedString]];
	[request setDelegate:self];
	[request startAsynchronous];    
}

#pragma mark - client-side loading / saving of the mosaic images
-(void)addMoreMosaicImages:(NSArray*)mosaicImages
{
#warning TODO: implement comparing the existing imags and removing duplicates (unique_id for each image - articleId)
    
    //first retrieve the currently saved mosaic images as copy
    NSArray* currentlySavedMosaicImages = [self.savedMosaicImages copy];
    
    //then add the mosaicImages parameter to the currently saved ones
    NSArray* newArrayOfSavedMosaicImages = [currentlySavedMosaicImages arrayByAddingObjectsFromArray:mosaicImages];
    
    //save the new mosaic images array to disk, overwriting the last file
    NSMutableDictionary *imagesDictionary = [[NSMutableDictionary alloc] init];
    [imagesDictionary setObject:[newArrayOfSavedMosaicImages copy] forKey:kImagesKey];
    
    //write the data to the file
    NSString* fullPath = [DIRECTORY_FOR_MOSAIC_IMAGES_FILE stringByAppendingPathComponent:filenameForMosaicImagesPlist];
    if (![imagesDictionary writeToFile:fullPath atomically:NO])
    {
        NSLog(@"didNOTWriteToFile");
#warning TODO: do something in case the mosaic images couldn't be saved to file
    }
}

//return the saved mosaic images from disk
-(NSArray*)savedMosaicImages
{
    //the array of images to be returned
    NSArray* images;
    
    //loading data from disk if it exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString* fullPath = [DIRECTORY_FOR_MOSAIC_IMAGES_FILE stringByAppendingPathComponent:filenameForMosaicImagesPlist];
    if ([fileManager fileExistsAtPath:fullPath])
    {
        NSData* data = [NSData dataWithContentsOfFile:fullPath];
        NSMutableDictionary* plist = [NSPropertyListSerialization propertyListFromData:data
                                                                      mutabilityOption:NSPropertyListImmutable
                                                                                format:NULL 
                                                                      errorDescription:NULL];
        images =[plist objectForKey:kImagesKey];
    }

    //file not found, just return an empty array
    else
    images = [[NSArray alloc] init];
    
    return [[images copy] autorelease];
}

#pragma mark - adding images to the mosaic view

-(void)drawSavedMosaicImages
{
    //first of all delete all currently shown images
    for (UIView* oneSubview in self.bigMosaikView.subviews) {
        [oneSubview removeFromSuperview];
    }
    
#define PADDING_BOTTOM 5.0f
    
    //load the plist with the saved mosaic images in memory
    NSMutableArray* images = [[NSArray arrayWithArray:self.savedMosaicImages] mutableCopy];
    
    //add the load more mosaic view to the image dictionary
    //TODO: define how to implement
#warning TODO!!!! define how to implement adding the load more mosaic view
    NSMutableDictionary* loadMoreMosaicDictionary = [[NSMutableDictionary alloc] init];
    [loadMoreMosaicDictionary setObject:[NSNumber numberWithFloat:100.0f] forKey:kImageWidth];
    [loadMoreMosaicDictionary setObject:[NSNumber numberWithFloat:50.0f] forKey:kImageHeight];
    [images addObject:loadMoreMosaicDictionary];
    [loadMoreMosaicDictionary release];
    
    
    //get active column
    const int numberOfColumns = 3;
    int columnHeights[numberOfColumns] = {0,0,0}; 
    int smallestColumn = 0;
    int imageCounter = [images count];
    
    for (NSDictionary* oneImageDictionary in images) 
    {
        //getting image properties
        NSNumber* imageWidthNumber = [oneImageDictionary objectForKey:kImageWidth];
        NSNumber* imageHeightNumber = [oneImageDictionary objectForKey:kImageHeight];
        NSString* imageArticleId = [oneImageDictionary objectForKey:kImageArticleId];
        NSString* imageArticleTitle = [oneImageDictionary objectForKey:kImageArticleTitle];
        
        CGFloat imageWidth = [imageWidthNumber floatValue];
        CGFloat imageHeight = [imageHeightNumber floatValue];
        
#warning THIS IS just temporary
        NSString* imageFilename = [oneImageDictionary objectForKey:kImageFilename];;
        UIImage* currentImageFromBundle = [UIImage imageNamed:imageFilename];
        UIImage *scaledImage = [UIImage imageWithCGImage:[currentImageFromBundle CGImage] scale:0.5 orientation:UIImageOrientationUp];
        [scaledImage retain];
        
        //calculate the column with the smallest height
        int smallestHeight = 0, i = 0;        
        smallestColumn = 0;
        smallestHeight = columnHeights[0];
        
        for (; i<numberOfColumns; i++) {
            if (columnHeights[i] < smallestHeight) {
                smallestHeight = columnHeights[i];
                smallestColumn=i;
            }
        }
        
        //define the active column as being the one with the smallest height
        int activeColumn = smallestColumn;
          
        //get active column values
        CGFloat xposForActiveColumn = [self xposForColumn:activeColumn];
        CGFloat heightOfActiveColumn = columnHeights[activeColumn];
        
        
        BOOL isColumnLoadMoreView = (imageCounter==1);
        
        if (isColumnLoadMoreView) 
        {
            //add a load more view to the scrollview
            CGPoint mosaicViewPoint = CGPointMake(xposForActiveColumn, heightOfActiveColumn+PADDING_BOTTOM);
            CGRect mosaicViewFrame = CGRectMake(mosaicViewPoint.x, mosaicViewPoint.y, imageWidth, imageHeight);
            LoadMoreMosaicView* oneView = [[LoadMoreMosaicView alloc] initWithFrame:mosaicViewFrame];
            oneView.userInteractionEnabled = YES;
            oneView.backgroundColor = [UIColor clearColor];
            oneView.alpha = 1.0f;
            
//            UIButton *loadMoreMosaicButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            loadMoreMosaicButton.frame = CGRectMake(0, 0, 100, 50);
//            [loadMoreMosaicButton addTarget:self action:@selector(loadMoreMosaicImages) forControlEvents:UIControlEventTouchDown];
//            [loadMoreMosaicButton setImage:[UIImage imageNamed:@"mosaicLoadMore"] forState:UIControlStateNormal];
//            [oneView addSubview:loadMoreMosaicButton];
            
            
            self.loadingMoreMosaicView = oneView;
            [oneView release];
            
            [self.bigMosaikView addSubview:_loadingMoreMosaicView];
        }
        else 
        {
#warning TODO: find better way to handle higher resolution of images
            imageWidth/=2;
            imageHeight/=2;
            
            
            //add a mosaic view to the scrollview
            CGPoint mosaicViewPoint = CGPointMake(xposForActiveColumn, heightOfActiveColumn+PADDING_BOTTOM);
            CGRect mosaicViewFrame = CGRectMake(mosaicViewPoint.x, mosaicViewPoint.y, imageWidth, imageHeight);
            MosaicView* oneView = [[MosaicView alloc] initWithFrame:mosaicViewFrame];
            oneView.delegate = self;
            oneView.articleId = imageArticleId;
            oneView.articleTitle = imageArticleTitle;
            oneView.alpha = 1.0f;
            
#warning THIS is just temporary
            UIImageView* tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
            tempImageView.image = scaledImage;
            [oneView addSubview:tempImageView];
            [tempImageView release];
            [currentImageFromBundle release];
            
            [scaledImage release];
            
            [self.bigMosaikView addSubview:oneView];
        }
        
        //add one of the columnHeights value to the relevant columnHeight
        columnHeights[activeColumn] += (imageHeight+PADDING_BOTTOM);
        
        imageCounter--;
    }
    
    //calculate the height of the largest column
    int largestHeight = 0, i = 0; 
    
    for (; i<numberOfColumns; i++) {
        if (columnHeights[i] > largestHeight) {
            largestHeight = columnHeights[i];
        }
    }
    CGFloat heightOfLargestColumn = (CGFloat)largestHeight;
    
    //resize content size of scrollview
    CGRect frameOfBigMosaicView = self.bigMosaikView.frame;
    self.bigMosaikView.frame = CGRectMake(frameOfBigMosaicView.origin.x, frameOfBigMosaicView.origin.y, frameOfBigMosaicView.size.width, heightOfLargestColumn+PADDING_BOTTOM);
    
    //resize the scrollview to fit the content properly
    [self.mosaikScrollView setContentSize:self.bigMosaikView.frame.size];
}

#pragma mark - some help methods

-(CGFloat)xposForColumn:(int)column
{
#define PADDING_LEFT 5.0f
#define PADDING_RIGHT 5.0f
#define COLUMN_WIDTH 100.0f    
    
    CGFloat xpos = column*COLUMN_WIDTH + (column+1)*PADDING_LEFT;
    return xpos;
}

#pragma mark - ASIHTTP request delegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    _isLoadingMoreMosaicImages = YES;
    
    LOG_CURRENT_FUNCTION()
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{    
    
    _isLoadingMoreMosaicImages = NO;
    
    LOG_CURRENT_FUNCTION()
    
    //currently using dummy mosaik images
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mosaic_images" ofType:@"plist"];
    NSData* data = [NSData dataWithContentsOfFile:path];
    NSMutableDictionary* plist = [NSPropertyListSerialization propertyListFromData:data
                                                                  mutabilityOption:NSPropertyListImmutable
                                                                            format:NULL 
                                                                  errorDescription:NULL];
        
    NSArray* images = [plist objectForKey:kImagesKey];
    
    
    //add the mosaic images
    [self addMoreMosaicImages:[[images copy] autorelease]];
    
    //redraw the images
    [self drawSavedMosaicImages];
    
    _numberOfActiveRequests--;

    self.loadingMoreMosaicView.isLoading = NO;
    
#warning THIS could be a problem for the loading view
    [self setIsLoadingViewHidden:YES];        
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    _isLoadingMoreMosaicImages = NO;
    
    self.loadingMoreMosaicView.isLoading = NO;
    
    LOG_CURRENT_FUNCTION()
    
    NSLog(@"show is NOT loading");
    
#warning THIS could be a problem for the loading view
    [self setIsLoadingViewHidden:YES]; 
    
#warning TODO: do something if the request failed!
    
    _numberOfActiveRequests--;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - overlay view

-(void)setUpOverlayViewForAnimationUsingMosaicView:(MosaicView*)mosaicView
{
    for (UIView* subview in _overlayView.subviews) {
        [subview removeFromSuperview];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:mosaicView.frame];
    
    CALayer *newLayer = mosaicView.layer;
    newLayer.frame = CGRectMake(0, 0, mosaicView.bounds.size.width, mosaicView.bounds.size.height);
    newLayer.contents = mosaicView.layer.contents;
    [view.layer addSublayer:newLayer];

    view.backgroundColor = [UIColor whiteColor];
    
    CGPoint newViewCenter = CGPointMake(_overlayView.center.x, _overlayView.center.y);
    view.center = newViewCenter;
    
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 2.0f;
    view.layer.opacity = 0.7f;
    
    //add the name label to the overlay view
    CGSize labelSize = CGSizeMake(_overlayView.frame.size.width, 20.0f);
    CGFloat paddingTop = 5.0f;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, view.frame.origin.y+view.frame.size.height+paddingTop, labelSize.width, labelSize.height)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont fontWithName:@"Georgia" size:12.0f];
    nameLabel.text = mosaicView.articleTitle;
    nameLabel.textAlignment = UITextAlignmentCenter;
    [_overlayView addSubview:nameLabel];
    [nameLabel release];
    
    //customize the overlayview a bit
    _overlayView.layer.borderWidth = 2.0f;
    _overlayView.layer.borderColor = [UIColor blackColor].CGColor;
    
    //add the currently selected image to the overlay view
    [_overlayView addSubview:view];
}

#pragma mark - MosaicView delegate

-(void)triggerActionForTapInView:(MosaicView*)view
{
    [self transitionToDetailViewControllerForArticleId:view.articleId];
}

-(void)transitionToDetailViewControllerForArticleId:(NSString*)articleId
{
    NSLog(@"transitionToDetailViewControllerForArticleId: %@", articleId);
    
    //blog entry to be shown is set, show the view controller loading the article data
    if (!self.detailViewController) {
        self.detailViewController = [[[IGNDetailViewController alloc] initWithNibName:@"IGNDetailViewController_iPhone" bundle:nil] autorelease];
    }
    
    self.detailViewController.currentArticleId = articleId;
    self.detailViewController.didLoadContentForRemoteArticle = NO;
    self.detailViewController.isShowingArticleFromLocalDatabase = NO;
    
    //reset the indexes
    self.detailViewController.nextBlogEntryIndex = kInvalidBlogEntryIndex;
    self.detailViewController.previousBlogEntryIndex = kInvalidBlogEntryIndex;
    
    //set the managedObjectContext and push the view controller
    self.detailViewController.managedObjectContext = appDelegate.managedObjectContext;
    self.detailViewController.isNavigationBarAndToolbarHidden = NO;
    
    if (![self.parentNavigationController.topViewController isKindOfClass:[IGNDetailViewController class]]) 
    {
        [self.parentNavigationController pushViewController:self.detailViewController animated:NO];        
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
    //copied code from http://stackoverflow.com/questions/5137943/how-to-know-when-uitableview-did-scroll-to-bottom
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    int secondsForNextAllowedUpdate = 2;
    
    float reload_distance = 10;
    if(y > h + reload_distance) 
    {
        if (!_isLoadingMoreMosaicImages && _numberOfActiveRequests==0) 
        {
            [self loadMoreMosaicImages];
        }
    }
}

@end
