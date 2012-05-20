//
//  IgnantTumblrFeedViewController.m
//  OtherTests
//
//  Created by Claudiu-Vlad Ursache on 4/3/12.
//  Copyright (c) 2012 Cortado AG. All rights reserved.
//

#import "IgnantTumblrFeedViewController.h"
#import "HJObjManager.h"
#import "HJManagedImageV.h"

#import "IgnantImporter.h"
#import "IGNAppDelegate.h"

//imports for ASIHTTPRequest
#import "ASIHTTPRequest.h"
#import "NSURL+stringforurl.h"

#import "Constants.h"

#import "TumblrEntry.h"


#define kTumblrAPIKey I5QACSezTzCjvkHXaiEaXrD3t9cb8Ahmpyv7MqGIRPhdEfg2Yw
// http://api.tumblr.com/v2/blog/ignant.tumblr.com/posts?api_key=

#warning TODO: implement real data from tumblr


#define kMinimumNumberOfPostsOnLoad 5

@interface IgnantTumblrFeedViewController ()
{
    BOOL isLoadingMoreTumblr;
    BOOL _showLoadMoreTumblr;
    BOOL isLoadingLatestTumblrArticles;
    

    NSArray *_arrayWithTestImages;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    IGNAppDelegate *appDelegate;
    
    
    BOOL _isLoadingTumblrArticlesForCurrentlyEmptyDataSet;
}

@property(nonatomic, retain) HJObjManager *imageManager;
@property(nonatomic, retain) IgnantImporter* importer;
@end

@implementation IgnantTumblrFeedViewController
@synthesize tumblrTableView = _tumblrTableView;
@synthesize imageManager = _imageManager;
@synthesize importer = _importer;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize fetchedResultsController = __fetchedResultsController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _isLoadingTumblrArticlesForCurrentlyEmptyDataSet = NO;
        
        appDelegate = (IGNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        
        // Custom initialization
        [self createImporter];
        
        
        isLoadingMoreTumblr = NO;
        isLoadingLatestTumblrArticles = NO;
        
        // Set up the image cache manager
        self.imageManager = [[HJObjManager alloc] init];
        
        // Tell the manager where to store the images on the device
        NSString *cacheDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Images/"];
        HJMOFileCache *fileCache = [[[HJMOFileCache alloc] initWithRootPath:
                                     cacheDirectory] autorelease];
        
        // Have the file cache trim itself down to a size & age limit, so it doesn't grow forever
        fileCache.fileCountLimit = 100;
        fileCache.fileAgeLimit = 60*60*24*7; //1 week
        [fileCache trimCacheUsingBackgroundThread];
        
        
        self.imageManager.fileCache = fileCache;
        
        _arrayWithTestImages = [[NSArray alloc] initWithObjects:
                
            @"http://29.media.tumblr.com/tumblr_m1w8emWNTe1qztdbbo1_400.png",
            @"http://27.media.tumblr.com/tumblr_m1w8af4yZr1qztdbbo1_400.png",
            @"http://24.media.tumblr.com/tumblr_m1pxjwDgpS1qztdbbo1_400.png",
            @"http://29.media.tumblr.com/tumblr_m1pxizsIDB1qztdbbo1_400.png",
            @"http://26.media.tumblr.com/tumblr_m1jx641OGr1qztdbbo1_400.png",
            @"http://27.media.tumblr.com/tumblr_m1fk3dT2Dp1qztdbbo1_400.png",
            @"http://25.media.tumblr.com/tumblr_m1fk1o7w4Z1qztdbbo1_400.png",
            @"http://24.media.tumblr.com/tumblr_m1fk0oM2GF1qztdbbo1_400.png",
            @"http://29.media.tumblr.com/tumblr_m18c8zq3Fv1qztdbbo1_400.png",
            @"http://29.media.tumblr.com/tumblr_m18c6zOqoo1qztdbbo1_400.png", nil];
        
    }
    return self;
}

- (void)dealloc {
    [_tumblrTableView release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (_managedObjectContext == nil) 
    {
        _managedObjectContext = appDelegate.managedObjectContext; 
    }
    
    
    //set up the refresh header view
    if (_refreshHeaderView == nil) {
        
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tumblrTableView.bounds.size.height, self.view.frame.size.width, self.tumblrTableView.bounds.size.height)];
		view.delegate = self;
		[self.tumblrTableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
	}
}

- (void)viewDidUnload
{
    [self setTumblrTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [_refreshHeaderView release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    int numberOfLoadedPosts = [sectionInfo numberOfObjects];
    
    if (numberOfLoadedPosts<kMinimumNumberOfPostsOnLoad) {
        _isLoadingTumblrArticlesForCurrentlyEmptyDataSet = YES;
        [self loadLatestTumblrArticles];
    }
    
    return numberOfLoadedPosts;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TumblrEntry* currentTumblrEntry = (TumblrEntry*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    HJManagedImageV* currentImage;
    
    NSURL *urlAtCurrentIndex = [NSURL URLWithString:currentTumblrEntry.imageUrl];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier] autorelease];
        
        currentImage = [[[HJManagedImageV alloc] initWithFrame:CGRectMake(5,5,310,310)] autorelease];
        [currentImage setBackgroundColor:[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:0.3]];
        currentImage.tag = 999;
        currentImage.url = urlAtCurrentIndex;
        [self.imageManager manage:currentImage];
        
        
        [cell addSubview:currentImage];
        
    } else{
        currentImage = (HJManagedImageV*)[cell viewWithTag:999];
        [currentImage clear];
    }
    
    
    currentImage.url = urlAtCurrentIndex;
    [currentImage.loadingWheel setColor:[UIColor whiteColor]];
    [self.imageManager manage:currentImage];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
    //copied code from http://stackoverflow.com/questions/5137943/how-to-know-when-uitableview-did-scroll-to-bottom
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 10;
    if(y > h + reload_distance) 
    {
        if (!isLoadingMoreTumblr) {
            [self loadMoreTumblrArticles];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - server communication actions
-(void)loadMoreTumblrArticles
{    
    if (isLoadingMoreTumblr) return;
    isLoadingMoreTumblr = YES;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetMoreTumblrArticles,kParameterAction, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
    
    NSLog(@"encodedString go: %@",encodedString);
    
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:encodedString]];
	[request setDelegate:self];
	[request startAsynchronous];    
}

-(void)loadLatestTumblrArticles
{
    if (isLoadingLatestTumblrArticles) return;        
    isLoadingLatestTumblrArticles = YES;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetLatestTumblrArticles,kParameterAction, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
    
    NSLog(@"encodedString go: %@",encodedString);
    
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:encodedString]];
	[request setDelegate:self];
	[request startAsynchronous]; 
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    LOG_CURRENT_FUNCTION()
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    if (isLoadingMoreTumblr) {
        
        
        
        
    }
    else if (isLoadingLatestTumblrArticles) {
        
        if (_isLoadingTumblrArticlesForCurrentlyEmptyDataSet) {
            [self setIsLoadingViewHidden:NO];
        }
        
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    LOG_CURRENT_FUNCTION()
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    
    if (isLoadingMoreTumblr) {
        
        
        _showLoadMoreTumblr = YES;
        isLoadingMoreTumblr = NO;
        
    }
    else if (isLoadingLatestTumblrArticles) {
        
        NSLog(@"request: %@", [request responseString]);
        
        dispatch_queue_t importerDispatchQueue = dispatch_queue_create("com.ignant.importerDispatchQueue", NULL);
        dispatch_async(importerDispatchQueue, ^{
            [self.importer importJSONStringForTumblrPosts:[request responseString]];
        });
        
        isLoadingLatestTumblrArticles = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tumblrTableView];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    LOG_CURRENT_FUNCTION()
    
#warning TODO: do something if the request has failed
    
    if (isLoadingMoreTumblr) {
        
        isLoadingMoreTumblr = NO;
        
    }
    else if (isLoadingLatestTumblrArticles) {
        
        isLoadingLatestTumblrArticles = NO;
        
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tumblrTableView];
    }
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self loadLatestTumblrArticles];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return isLoadingLatestTumblrArticles; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - core data stuff
-(void)createImporter
{
    //use the persistent store from the appDelegate       
    _importer = [[IgnantImporter alloc] init];
    _importer.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
    _importer.delegate = self;
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TumblrEntry" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptorForDate = [[[NSSortDescriptor alloc] initWithKey:@"publishingDate" ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorForDate, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil] autorelease];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

- (void)fetch 
{
    NSError *error = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    NSAssert2(success, @"Unhandled error performing fetch at SongsViewController.m, line %d: %@", __LINE__, [error localizedDescription]);
    [self.tumblrTableView reloadData];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tumblrTableView reloadData];
}


#pragma mark - IgnantImporterDelegate

-(void)didStartImportingRSSData
{
    LOG_CURRENT_FUNCTION()
    NSLog(@"tumblrFeed didStartImportingRSSData");
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        
    //        [self showLoadingViewAnimated:YES];
    //    
    //    });
}

-(void)didFinishImportingRSSData
{
    LOG_CURRENT_FUNCTION() 
    NSLog(@"tumblrFeed didStartImportingRSSData");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetch];
        [self.tumblrTableView reloadData];
        
        if (_isLoadingTumblrArticlesForCurrentlyEmptyDataSet) {
            [self setIsLoadingViewHidden:YES];
            _isLoadingTumblrArticlesForCurrentlyEmptyDataSet = NO;
        }
        
    });
}

- (void)importerDidSave:(NSNotification *)saveNotification {  
    [appDelegate performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
}

@end
