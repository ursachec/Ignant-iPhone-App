//
//  IGNMosaikViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 03.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "IGNMosaikViewController.h"

#import "IGNDetailViewController.h"

//import custom views
#import "LoadMoreMosaicView.h"
#import "MosaicView.h"

//imports for ASIHTTPRequest
#import "ASIHTTPRequest.h"
#import "NSURL+stringforurl.h"

#import "Constants.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "SBJSON.h"

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
    CGPoint lastContentOffset;
      
}
@property(nonatomic,strong) NSArray* savedMosaicImages;
@property (nonatomic,strong) UIView* overlayView;
@property (retain, nonatomic) IBOutlet UIView *mockNavigationBar;

@property(nonatomic,strong) IGNDetailViewController* detailViewController;


@property(nonatomic,strong) LoadMoreMosaicView* loadingMoreMosaicView;

-(void)drawSavedMosaicImages;
-(void)addMoreMosaicImages:(NSArray*)mosaicImages;
-(void)loadMoreMosaicImages;

-(void)setUpOverlayViewForAnimationUsingMosaicView:(MosaicView*)view;

-(void)transitionToDetailViewControllerForArticleId:(NSString*)articleId;

-(void)showToolbarAndNavigationBar;

- (IBAction)didTapOnMore:(id)sender;
- (IBAction)didTapOnMosaik:(id)sender;
- (IBAction)didTapOnMercedes:(id)sender;

@end

#pragma mark -

@implementation IGNMosaikViewController
@synthesize bigMosaikView;
@synthesize mosaikScrollView;
@synthesize closeMosaikButton;
@synthesize savedMosaicImages;
@synthesize overlayView = _overlayView;
@synthesize mockNavigationBar;
@synthesize detailViewController;
@synthesize parentNavigationController;
@synthesize isMosaicImagesArrayNotEmpty = _isMosaicImagesArrayNotEmpty;
@synthesize shareAndMoreToolbar;
@synthesize loadingMoreMosaicView = _loadingMoreMosaicView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _numberOfActiveRequests = 0;
        
        _isLoadingMoreMosaicImages = NO;
        
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
    return [self.savedMosaicImages count]>=kMinimumMosaicImagesLoaded;
}

#pragma mark - handle going back
-(IBAction)handleBack:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setIsSpecificNavigationBarHidden:YES animated:NO];
    [self setIsSpecificToolbarHidden:YES animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //trigger the drawing for the images
    [self drawSavedMosaicImages];
    
    //check if the mosaicImages are loaded and trigger a load if not
    if(!self.isMosaicImagesArrayNotEmpty)
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
    
    
    //set up the mock navigation bar + toolbar
    [self setUpToolbarAndMockNavigationBar];
}

- (void)viewDidUnload
{
    
    self.loadingMoreMosaicView = nil;
    self.overlayView = nil;
    
    [self setBigMosaikView:nil];
    [self setMosaikScrollView:nil];
    [self setCloseMosaikButton:nil];
    [self setShareAndMoreToolbar:nil];
    [self setMockNavigationBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - server communication actions
-(void)loadMoreMosaicImages
{    
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    _numberOfActiveRequests++;
    
    //show a covering loading view if mosaic images array is empty
    if(!self.isMosaicImagesArrayNotEmpty)
    {
        [self setIsLoadingViewHidden:NO];
    }
    
    self.loadingMoreMosaicView.isLoading = YES;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetSetOfMosaicImages,kParameterAction, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
    
    NSLog(@"LOAD MORE MOSAIK encodedString go: %@",encodedString);
    
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
    
    return [images copy];
}

#pragma mark - adding images to the mosaic view

-(void)drawSavedMosaicImages
{
    //first of all delete all currently shown images
    for (UIView* oneSubview in self.bigMosaikView.subviews) {
        [oneSubview removeFromSuperview];
    }
    
#define PADDING_BOTTOM 5.0f
#define PADDING_TOP .0f
    
    //load the plist with the saved mosaic images in memory
    NSMutableArray* images = [[NSArray arrayWithArray:self.savedMosaicImages] mutableCopy];
    
    //add the load more mosaic view to the image dictionary
    //TODO: define how to implement
#warning TODO!!!! define how to implement adding the load more mosaic view
    NSMutableDictionary* loadMoreMosaicDictionary = [[NSMutableDictionary alloc] init];
    [loadMoreMosaicDictionary setObject:[NSNumber numberWithFloat:100.0f] forKey:kImageWidth];
    [loadMoreMosaicDictionary setObject:[NSNumber numberWithFloat:50.0f] forKey:kImageHeight];
    [images addObject:loadMoreMosaicDictionary];
    
    
    //get active column
    const int numberOfColumns = 3;
    int columnHeights[numberOfColumns] = {0,0,0}; 
    int smallestColumn = 0;
    int imageCounter = [images count];
    
    for (NSDictionary* oneImageDictionary in images) 
    {
        //getting mosaic entry properties       
        NSNumber* mosaicEntryWidth = [oneImageDictionary objectForKey:kMosaicEntryWidth];
        NSNumber* mosaicEntryHeight = [oneImageDictionary objectForKey:kMosaicEntryHeight];
        NSString* mosaicEntryArticleId = [oneImageDictionary objectForKey:kMosaicEntryArticleId];
        NSString* mosaicEntryUrl = [oneImageDictionary objectForKey:kMosaicEntryUrl];
        
        CGFloat fMosaicEntryWidth = [mosaicEntryWidth floatValue];
        CGFloat fMosaicEntryHeight = [mosaicEntryHeight floatValue];
        
        
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
            CGPoint mosaicViewPoint = CGPointMake(xposForActiveColumn, PADDING_TOP+heightOfActiveColumn+PADDING_BOTTOM);
            CGRect mosaicViewFrame = CGRectMake(mosaicViewPoint.x, mosaicViewPoint.y, fMosaicEntryWidth, fMosaicEntryHeight);
            LoadMoreMosaicView* oneView = [[LoadMoreMosaicView alloc] initWithFrame:mosaicViewFrame];
            oneView.userInteractionEnabled = YES;
            oneView.backgroundColor = [UIColor clearColor];
            oneView.alpha = 1.0f;
            
            self.loadingMoreMosaicView = oneView;
            
            [self.bigMosaikView addSubview:_loadingMoreMosaicView];
        }
        else 
        {
#warning TODO: find better way to handle higher resolution of images
            fMosaicEntryWidth/=2;
            fMosaicEntryHeight/=2;
            
            //add a mosaic view to the scrollview
            CGPoint mosaicViewPoint = CGPointMake(xposForActiveColumn, heightOfActiveColumn+PADDING_BOTTOM);
            CGRect mosaicViewFrame = CGRectMake(mosaicViewPoint.x, mosaicViewPoint.y, fMosaicEntryWidth, fMosaicEntryHeight);
            MosaicView* oneView = [[MosaicView alloc] initWithFrame:mosaicViewFrame];
            oneView.delegate = self;
            oneView.articleId = mosaicEntryArticleId;
            oneView.alpha = 1.0f;
            
#warning THIS is just temporary
            UIImageView* tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fMosaicEntryWidth, fMosaicEntryHeight)];
//            tempImageView.image = scaledImage;
            [oneView addSubview:tempImageView];
            
            
            [self.bigMosaikView addSubview:oneView];
            
            //trigger loading the image
#warning IDEA: placeholder image ignant logo, looks interesting
            NSURL* mURL = [NSURL URLWithString:mosaicEntryUrl];
            [tempImageView setImageWithURL:mURL
                          placeholderImage:nil];
            
        }
        
        //add one of the columnHeights value to the relevant columnHeight
        columnHeights[activeColumn] += (fMosaicEntryHeight+PADDING_BOTTOM);
        
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
    
    //add the closeButton to the view
    [self.view addSubview:self.closeMosaikButton];
    
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
    LOG_CURRENT_FUNCTION()
    
    _isLoadingMoreMosaicImages = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{    
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    _isLoadingMoreMosaicImages = NO;
    
    //currently using dummy mosaik images
    NSString* jsonString = [request responseString];
    SBJSON *parser = [[SBJSON alloc] init];
    
    NSString *json_string = [jsonString copy];
    NSDictionary *dictionaryFromJSON = [parser objectWithString:json_string error:nil];
    NSArray* images = [dictionaryFromJSON objectForKey:kTLMosaicEntries];
    
    
    //add the mosaic images
    [self addMoreMosaicImages:[images copy]];
    
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    
    if (!self.isMosaicImagesArrayNotEmpty){
        [self setIsCouldNotLoadDataViewHidden:NO];
    }
    
    _isLoadingMoreMosaicImages = NO;
    self.loadingMoreMosaicView.isLoading = NO;
    
#warning THIS could be a problem for the loading view
    [self setIsLoadingViewHidden:YES]; 
    _numberOfActiveRequests--;
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
    nameLabel.textAlignment = UITextAlignmentCenter;
    [_overlayView addSubview:nameLabel];
    
    //customize the overlayview a bit
    _overlayView.layer.borderWidth = 2.0f;
    _overlayView.layer.borderColor = [UIColor blackColor].CGColor;
    
    //add the currently selected image to the overlay view
    [_overlayView addSubview:view];
}

#pragma mark - MosaicView delegate

-(void)triggerActionForDoubleTapInView:(MosaicView*)view
{
    NSLog(@"double tap in view");
    
    [self toggleShowSpecificNavigationBarAnimated:YES];
    [self toggleShowSpecificToolbar];
    
}

-(void)triggerActionForTapInView:(MosaicView*)view
{
    NSLog(@"tap in view");
    
    [self transitionToDetailViewControllerForArticleId:view.articleId];
}

-(void)setUpToolbarAndMockNavigationBar
{    
    //add the specific navigation bar
    [self setIsSpecificNavigationBarHidden:YES animated:NO];
    [self.view addSubview:self.specificNavigationBar];
    
    //add the specific navigation bar
    [self setIsSpecificToolbarHidden:YES animated:NO];
    [self.view addSubview:self.specificToolbar];
}

-(void)handleTapOnSpecificNavBarBackButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)transitionToDetailViewControllerForArticleId:(NSString*)articleId
{
    NSLog(@"transitionToDetailViewControllerForArticleId: %@", articleId);
    
    //blog entry to be shown is set, show the view controller loading the article data
    if (!self.detailViewController) {
        self.detailViewController = [[IGNDetailViewController alloc] initWithNibName:@"IGNDetailViewController_iPhone" bundle:nil];
    }
    
    self.detailViewController.currentArticleId = articleId;
    self.detailViewController.didLoadContentForRemoteArticle = NO;
    self.detailViewController.isShowingArticleFromLocalDatabase = NO;
    
    //reset the indexes
    self.detailViewController.nextBlogEntryIndex = kInvalidBlogEntryIndex;
    self.detailViewController.previousBlogEntryIndex = kInvalidBlogEntryIndex;
    
    //set the managedObjectContext and push the view controller
    self.detailViewController.managedObjectContext = self.appDelegate.managedObjectContext;
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
    
    float reload_distance = -20;
    if(y > h + reload_distance) 
    {
        if (lastContentOffset.y < offset.y) //only trigger when scroll direction is DOWN
        if (!_isLoadingMoreMosaicImages && _numberOfActiveRequests==0) 
        {
            [self loadMoreMosaicImages];
        }
    }
}

#pragma mark - custom special views
-(UIView *)couldNotLoadDataView
{
    UIView* defaultView = [super couldNotLoadDataView];
    self.couldNotLoadDataLabel.text = @"Could not load data for the mosaic";
    
    return defaultView;
}

-(void)setIsCouldNotLoadDataViewHidden:(BOOL)hidden
{
    [super setIsCouldNotLoadDataViewHidden:hidden];

    //add the closeButton to the view
    [self.couldNotLoadDataView addSubview:self.closeMosaikButton];
    [self.couldNotLoadDataView bringSubviewToFront:self.closeMosaikButton];
}
#pragma mark - actions
-(void)handleTapOnSpecificToolbarLeft:(id)sender
{
    LOG_CURRENT_FUNCTION()
    [self.mosaikScrollView scrollRectToVisible:CGRectMake(0.f, 0.0f, 320.0f, 20.0f) animated:YES];
}

-(void)handleTapOnSpecificToolbarMercedes:(id)sender
{
    LOG_CURRENT_FUNCTION()
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAdressForMercedesPage]];
}

-(void)handleTapOnSpecificToolbarRight:(id)sender
{
    LOG_CURRENT_FUNCTION()
    
    [self.appDelegate showMore];
    [self dismissModalViewControllerAnimated:YES];
}

@end
