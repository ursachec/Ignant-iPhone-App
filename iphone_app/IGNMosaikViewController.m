//
//  IGNMosaikViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 03.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "IGNMosaikViewController.h"

#import "IGNDetailViewController.h"
#import "ArticleDetailViewController.h"

//import custom views
#import "LoadMoreMosaicView.h"
#import "MosaicView.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "AFIgnantAPIClient.h"

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

@property(assign) BOOL isLoadingMoreMosaicImages;
@property(assign) BOOL isLoadingReplacingMosaicImages;
@property(assign) BOOL isMosaicShownForTheFirstTime;
@property(assign) int numberOfActiveRequests;
@property(assign) CGPoint lastContentOffset;

@property(nonatomic,strong) NSMutableArray* currentColumnHeights;

@property(nonatomic,strong) NSArray* currentBatchOfMosaicImages;
@property(nonatomic,strong) NSArray* savedMosaicImages;
@property (nonatomic,strong) UIView* overlayView;
@property(nonatomic,strong) ArticleDetailViewController* articleDetailViewController;
@property(nonatomic,strong) LoadMoreMosaicView* loadingMoreMosaicView;

-(void)drawSavedMosaicImages;
-(void)addMoreMosaicImages:(NSArray*)mosaicImages;
-(void)loadMoreMosaicImages;
-(void)setUpOverlayViewForAnimationUsingMosaicView:(MosaicView*)view;
-(void)transitionToDetailViewControllerForArticleId:(NSString*)articleId;

@end

#pragma mark -

@implementation IGNMosaikViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.numberOfActiveRequests = 0;
        self.isLoadingMoreMosaicImages = NO;
        self.isLoadingReplacingMosaicImages = NO;
        self.isMosaicShownForTheFirstTime= NO;
        
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
-(IBAction)showHome:(id)sender
{
    [self.appDelegate showHome];
    [self dismissModalViewControllerAnimated:YES];
}

-(BOOL)isMosaicImagesArrayNotEmpty
{
    return [self.savedMosaicImages count]>=kMinimumMosaicImagesLoaded;
}

-(IBAction)handleBack:(id)sender
{
	if (self.viewControllerToReturnTo) {
		[self.parentNavigationController popToViewController:self.viewControllerToReturnTo animated:NO];
	}
	
    [self dismissModalViewControllerAnimated:YES];
}

-(void)loadLatestContent
{
	
	NSTimeInterval updateTimer = -1.0f * (CGFloat)kDefaultNumberOfHoursBeforeTriggeringLatestUpdate * 60.0f * 60.f;
    NSDate* lastUpdate = [[UserDefaultsManager sharedDefautsManager] lastUpdateDateForCategoryId:[self currentCategoryId]];
    NSTimeInterval lastUpdateInSeconds = [lastUpdate timeIntervalSinceNow];
    
    BOOL forceLoad = false;
    
    if ((forceLoad ||
		 (!self.isMosaicImagesArrayNotEmpty ||
		  ((lastUpdateInSeconds==0 || lastUpdateInSeconds<updateTimer) && !_isLoadingMoreMosaicImages)))
		&& [self.appDelegate checkIfAppOnline])
	{
		
        DBLog(@"triggering load latest data, lastUpdateInSeconds: %f // updateTimer: %f", lastUpdateInSeconds, updateTimer);
		
        _isLoadingReplacingMosaicImages = YES;
        [self removeCurrentImageViews];
        _currentColumnHeights = [@[ @0,@0, @0 ] mutableCopy];
        [self loadMoreMosaicImages];
		
		NSError* error = nil;
		GATrackEvent(&error, @"mosaicVC", @"triggerMosaicReload", @"", -1);
    }
    else {
        DBLog(@"not triggering load latest data, lastUpdateInSeconds: %f // updateTimer: %f", lastUpdateInSeconds, updateTimer);
		
		if ([self.currentBatchOfMosaicImages count]==0) {
			NSArray* currentlySavedMosaicImages = [self.savedMosaicImages copy];
			self.currentBatchOfMosaicImages = currentlySavedMosaicImages;
			[self drawSavedMosaicImages];
		}
    }
	
}

#pragma mark - View lifecycle
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSError* error = nil;
	GATrackPageView(&error, kGAPVMosaicView);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setIsSpecificToolbarHidden:YES animated:NO];
    [self loadLatestContent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self drawSavedMosaicImages];
    
    // add the big mosaik view to the content scrollview
    self.bigMosaikView.userInteractionEnabled = YES;
    [self.mosaikScrollView addSubview:self.bigMosaikView];
    
    //set up the overlay view
    UIView* overlayView = [[UIView alloc] initWithFrame:self.view.frame];
    overlayView.backgroundColor = [UIColor whiteColor];
    self.overlayView = overlayView;
    
    //set up the mock navigation bar + toolbar
    [self setUpToolbarAndNavigationBar];
    [self setIsSpecificNavigationBarHidden:NO animated:NO];
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

#pragma mark - server communication actions
-(void)loadMoreMosaicImages
{    
    LOG_CURRENT_FUNCTION()
    
    if (_isLoadingMoreMosaicImages) {
        return;
	}
	
    self.isLoadingMoreMosaicImages = YES;
    self.numberOfActiveRequests++;
    
    //show a covering loading view if mosaic images array is empty
    if(!self.isMosaicImagesArrayNotEmpty || _isLoadingReplacingMosaicImages)
    {
        [self setIsLoadingViewHidden:NO];
    }
    
    self.loadingMoreMosaicView.isLoading = YES;
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	DEF_BLOCK_SELF
	[[AFIgnantAPIClient sharedClient] getSetOfMosaicImagesWithSuccess:^(AFHTTPRequestOperation *operation, id responseJSON) {
		
		blockSelf.isLoadingMoreMosaicImages = NO;
		blockSelf.numberOfActiveRequests--;
		
		NSArray* images = nil;
		if ([responseJSON isKindOfClass:[NSDictionary class]]) {
			images = responseJSON[kTLMosaicEntries];
		}
		
		if ([images count]<1 && !blockSelf.isMosaicImagesArrayNotEmpty){
			[blockSelf showViewsForCouldNotGetMosaicData];
			blockSelf.loadingMoreMosaicView.isLoading = NO;
			blockSelf.isLoadingReplacingMosaicImages = NO;
			return;
		}
		
		[[UserDefaultsManager sharedDefautsManager] setLastUpdateDate:[NSDate date] forCategoryId:[self currentCategoryId]];
		
		if (blockSelf.isLoadingReplacingMosaicImages) {
			[blockSelf replaceCurrentMosaicImagesWithNewOnes:[images copy]];
		}
		else {	
			//add the mosaic images
			[blockSelf addMoreMosaicImages:[images copy]];
		}
				
		//redraw the images
		[blockSelf drawSavedMosaicImages];
		blockSelf.loadingMoreMosaicView.isLoading = NO;
		blockSelf.isLoadingReplacingMosaicImages = NO;
		
		[blockSelf setIsLoadingViewHidden:YES];
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
		blockSelf.isLoadingMoreMosaicImages = NO;
		blockSelf.isLoadingReplacingMosaicImages = NO;
		blockSelf.loadingMoreMosaicView.isLoading = NO;
		
		blockSelf.numberOfActiveRequests--;
		
		if (!blockSelf.isMosaicImagesArrayNotEmpty){
			[blockSelf showViewsForCouldNotGetMosaicData];
		}
		
	}];
}

#pragma mark - client-side loading / saving of the mosaic images
-(void)replaceCurrentMosaicImagesWithNewOnes:(NSArray*)newMosaicImages
{
    LOG_CURRENT_FUNCTION()
    
    self.currentBatchOfMosaicImages = newMosaicImages;
    
    //save the new mosaic images array to disk, overwriting the last file
    NSMutableDictionary *imagesDictionary = [[NSMutableDictionary alloc] init];
    [imagesDictionary setObject:[newMosaicImages copy] forKey:kImagesKey];
    
    //write the data to the file
    NSString* fullPath = [DIRECTORY_FOR_MOSAIC_IMAGES_FILE stringByAppendingPathComponent:filenameForMosaicImagesPlist];
    if (![imagesDictionary writeToFile:fullPath atomically:NO])
    {
        DBLog(@"didNOTWriteToFile");
#warning TODO: do something in case the mosaic images couldn't be saved to file
    }
}

-(void)addMoreMosaicImages:(NSArray*)mosaicImages
{
    //first retrieve the currently saved mosaic images as copy
    NSArray* currentlySavedMosaicImages = [self.savedMosaicImages copy];
    
    //then add the mosaicImages parameter to the currently saved ones
    NSArray* newArrayOfSavedMosaicImages = [currentlySavedMosaicImages arrayByAddingObjectsFromArray:mosaicImages];
    
    self.currentBatchOfMosaicImages = mosaicImages;
    
    DBLog(@"currentlySavedMosaicImages.count: %d , newArrayOfSavedMosaicImages.count: %d", [currentlySavedMosaicImages count],  [newArrayOfSavedMosaicImages count]);
    
    //save the new mosaic images array to disk, overwriting the last file
    NSMutableDictionary *imagesDictionary = [[NSMutableDictionary alloc] init];
    [imagesDictionary setObject:[newArrayOfSavedMosaicImages copy] forKey:kImagesKey];
    
    //write the data to the file
    NSString* fullPath = [DIRECTORY_FOR_MOSAIC_IMAGES_FILE stringByAppendingPathComponent:filenameForMosaicImagesPlist];
    if (![imagesDictionary writeToFile:fullPath atomically:NO])
    {
        DBLog(@"didNOTWriteToFile");
#warning TODO: do something in case the mosaic images couldn't be saved to file
    }
}

//return the saved mosaic images from disk
-(NSArray*)savedMosaicImages
{
    //the array of images to be returned
    NSArray* images = nil;
    
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
-(void)removeCurrentImageViews
{
    for (UIView* oneSubview in self.bigMosaikView.subviews) {
        [oneSubview removeFromSuperview];
    }
}


-(void)triggerLoadingMosaicImageWithArticleId:(NSString*)articleId forImageView:(UIImageView*)imageView
{
    NSString *encodedString = [[NSString alloc] initWithFormat:@"%@?%@=%@&%@=%@",kAdressForImageServer,kArticleId,articleId,kTLReturnImageType,kTLReturnMosaicImage];
    NSURL* thumbURL = [[NSURL alloc] initWithString:encodedString];
    [self triggerLoadingImageAtURL:thumbURL forImageView:imageView];
}

-(void)drawSavedMosaicImages
{
#define PADDING_BOTTOM 5.0f
#define PADDING_TOP .0f
	
    if (_currentColumnHeights==nil) {
        _currentColumnHeights = [@[ @0,@0,@0 ] mutableCopy];
    }
	
    BOOL shouldIncludeLoadingMoreView = false;
    
    //load the plist with the saved mosaic images in memory
    NSMutableArray* images = [[NSArray arrayWithArray:self.currentBatchOfMosaicImages] mutableCopy];
            
    //add the load more mosaic view to the image dictionary
    if(shouldIncludeLoadingMoreView)
    {
        NSMutableDictionary* loadMoreMosaicDictionary = [[NSMutableDictionary alloc] init];
        [loadMoreMosaicDictionary setObject:[NSNumber numberWithFloat:100.0f] forKey:kImageWidth];
        [loadMoreMosaicDictionary setObject:[NSNumber numberWithFloat:50.0f] forKey:kImageHeight];
        [images addObject:loadMoreMosaicDictionary];
    }
    
    //get active column
    int fc = [(NSNumber*)[_currentColumnHeights objectAtIndex:0] intValue];
    int sc = [(NSNumber*)[_currentColumnHeights objectAtIndex:1] intValue];
    int tc = [(NSNumber*)[_currentColumnHeights objectAtIndex:2] intValue];
    
    const int numberOfColumns = 3;
    int columnHeights[numberOfColumns] = {fc,sc,tc};
    int smallestColumn = MIN(MIN(fc, sc), tc);
    int imageCounter = [images count];    
    
    for (NSDictionary* oneImageDictionary in images) 
    {
        //getting mosaic entry properties       
        NSNumber* mosaicEntryWidth = [oneImageDictionary objectForKey:kMosaicEntryWidth];
        NSNumber* mosaicEntryHeight = [oneImageDictionary objectForKey:kMosaicEntryHeight];
        NSString* mosaicEntryArticleId = [oneImageDictionary objectForKey:kMosaicEntryArticleId];
        
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
        if (isColumnLoadMoreView && shouldIncludeLoadingMoreView)
        {
            //always show the loading mosaic view in the center
            activeColumn = 1;
            xposForActiveColumn = [self xposForColumn:activeColumn];
            heightOfActiveColumn = columnHeights[activeColumn];
            
            fMosaicEntryWidth = 100.0f;
            fMosaicEntryHeight = 50.0f;
            
            //add a load more view to the scrollview
            CGPoint mosaicViewPoint = CGPointMake(xposForActiveColumn, PADDING_TOP+heightOfActiveColumn+PADDING_BOTTOM);
            CGRect mosaicViewFrame = CGRectMake(mosaicViewPoint.x, mosaicViewPoint.y, fMosaicEntryWidth, fMosaicEntryHeight);
            LoadMoreMosaicView* oneView = [[LoadMoreMosaicView alloc] initWithFrame:mosaicViewFrame];
            oneView.userInteractionEnabled = YES;
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
            
            UIImageView* tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fMosaicEntryWidth, fMosaicEntryHeight)];
			tempImageView.backgroundColor = IGNANT_GRAY_COLOR;
            [oneView addSubview:tempImageView];
            [self.bigMosaikView addSubview:oneView];
            
            //trigger loading the image
            [self triggerLoadingMosaicImageWithArticleId:mosaicEntryArticleId forImageView:tempImageView];
        }
        
        //add one of the columnHeights value to the relevant columnHeight
        columnHeights[activeColumn] += (fMosaicEntryHeight+PADDING_BOTTOM);
        
        if (!isColumnLoadMoreView || !shouldIncludeLoadingMoreView){
            [_currentColumnHeights replaceObjectAtIndex:activeColumn withObject:@(columnHeights[activeColumn])];
        }
        
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


-(void)showViewsForCouldNotGetMosaicData
{
    [self setIsCouldNotLoadDataViewHidden:NO];
    
    [self setIsSpecificNavigationBarHidden:NO animated:YES];
    [self.view bringSubviewToFront:self.specificNavigationBar];
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
-(void)triggerActionForTapInView:(MosaicView*)view
{
    [self transitionToDetailViewControllerForArticleId:view.articleId];
}

-(void)setUpToolbarAndNavigationBar
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
    [self handleBack:sender];
}

-(void)transitionToDetailViewControllerForArticleId:(NSString*)articleId
{
    DBLog(@"transitionToDetailViewControllerForArticleId: %@", articleId);
    
    //blog entry to be shown is set, show the view controller loading the article data
    if (!self.articleDetailViewController) {
        self.articleDetailViewController = [[ArticleDetailViewController alloc] initWithNibName:@"IGNDetailViewController_iPhone" bundle:nil];
    }
    
    self.articleDetailViewController.isShownFromMosaic = YES;
    self.articleDetailViewController.currentArticleId = articleId;
    self.articleDetailViewController.didLoadContentForRemoteArticle = NO;
    self.articleDetailViewController.isShowingArticleFromLocalDatabase = NO;
    
    //reset the indexes
    self.articleDetailViewController.nextBlogEntryIndex = kInvalidBlogEntryIndex;
    self.articleDetailViewController.previousBlogEntryIndex = kInvalidBlogEntryIndex;
    
    //set the managedObjectContext and push the view controller
    self.articleDetailViewController.managedObjectContext = self.appDelegate.managedObjectContext;
    self.articleDetailViewController.isNavigationBarAndToolbarHidden = NO;
    
    if (![self.parentNavigationController.topViewController isKindOfClass:[ArticleDetailViewController class]])
    {
        [self.parentNavigationController pushViewController:self.articleDetailViewController animated:NO];        
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
    
    float reload_distance = -20;
    if(y > h + reload_distance) 
    {
        if (self.lastContentOffset.y < offset.y) //only trigger when scroll direction is DOWN
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
    self.couldNotLoadDataLabel.text = NSLocalizedString(@"could_not_load_data_for_mosaic", @"Could not load data for the mosaic");
    
    return defaultView;
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
