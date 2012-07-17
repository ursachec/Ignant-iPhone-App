//
//  IgnantTumblrFeedViewController.m
//  OtherTests
//
//  Created by Claudiu-Vlad Ursache on 4/3/12.
//  Copyright (c) 2012 Cortado AG. All rights reserved.
//

#import "IgnantTumblrFeedViewController.h"

#import "IgnantImporter.h"


//imports for ASIHTTPRequest
#import "ASIHTTPRequest.h"
#import "NSURL+stringforurl.h"

#import "Constants.h"

#import "TumblrEntry.h"

#import "IgnantLoadMoreCell.h"
#import "IgnantLoadingMoreCell.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "TumblrCell.h"

#define kMinimumNumberOfPostsOnLoad 5

@interface IgnantTumblrFeedViewController ()
{
    BOOL _isLoadingMoreTumblr;
    BOOL _showLoadMoreTumblr;
    BOOL isLoadingLatestTumblrArticles;
    
    int _numberOfActiveRequests;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    BOOL _isLoadingTumblrArticlesForCurrentlyEmptyDataSet;
    
    CGPoint lastContentOffset;
}

@property(nonatomic, strong, readwrite) UILabel* couldNotLoadDataLabel;

@end

@implementation IgnantTumblrFeedViewController
@synthesize tumblrTableView = _tumblrTableView;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize fetchedResultsController = __fetchedResultsController;

@synthesize couldNotLoadDataLabel = _couldNotLoadDataLabel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _numberOfActiveRequests = 0;
        _isLoadingTumblrArticlesForCurrentlyEmptyDataSet = NO;
                        
        self.importer = nil;
        
        _showLoadMoreTumblr = YES;
        _isLoadingMoreTumblr = NO;
        isLoadingLatestTumblrArticles = NO;
                
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (_managedObjectContext == nil) 
    {
        _managedObjectContext = self.appDelegate.managedObjectContext; 
    }
    
    //set up the refresh header view
    if (_refreshHeaderView == nil) {
        
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tumblrTableView.bounds.size.height, self.view.frame.size.width, self.tumblrTableView.bounds.size.height)];
		view.delegate = self;
		[self.tumblrTableView addSubview:view];
		_refreshHeaderView = view;
	}
}

- (void)viewDidUnload
{
    [self setTumblrTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSError* error = nil;
    [[GANTracker sharedTracker] trackPageview:kGAPVTumblrView
                                    withError:&error];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setUpTumblrTitleView];
    
    
    [self setIsNoConnectionViewHidden:YES];
    
    if ([self isTumblrEntriesArrayEmpty]) {
        
        if ([self.appDelegate checkIfAppOnline]) {
            _isLoadingTumblrArticlesForCurrentlyEmptyDataSet = YES;
            [self loadLatestTumblrArticles];
        }
        else {
            [self setIsNoConnectionViewHidden:NO];
        }
    }
    else {
        [self triggerLoadLatestDataIfNecessary];
    }
}

#pragma mark - helpful methods
-(BOOL)isTumblrEntriesArrayEmpty
{    
    //decide if to load posts for the first time or not
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    int numberOfLoadedPosts = [sectionInfo numberOfObjects];
    return (numberOfLoadedPosts<kMinimumNumberOfPostsOnLoad);
}

-(void)triggerLoadLatestDataIfNecessary
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    NSTimeInterval updateTimer = -1.0f * (CGFloat)kDefaultNumberOfHoursBeforeTriggeringLatestUpdate * 60.0f * 60.f;
    
    NSDate* lastUpdate = [self.appDelegate.userDefaultsManager lastUpdateDateForCategoryId:[self currentCategoryId]];
    NSTimeInterval lastUpdateInSeconds = [lastUpdate timeIntervalSinceNow];
    
    if (lastUpdateInSeconds<updateTimer) {
        DBLog(@"triggering load latest data, lastUpdateInSeconds: %f // updateTimer: %f", lastUpdateInSeconds, updateTimer);
        [self loadLatestTumblrArticles];
    }
    else {
        DBLog(@"not triggering load latest data, lastUpdateInSeconds: %f // updateTimer: %f", lastUpdateInSeconds, updateTimer);
    }
}

-(void)setUpTumblrTitleView
{
    CGRect tumblrLogoFrame = CGRectMake(0, 0, 24.0f, 24.0f);
    UIView *aTumblrLogoView = [[UIView alloc] initWithFrame:tumblrLogoFrame];
    aTumblrLogoView.backgroundColor = [UIColor whiteColor];
    
    CGSize tumblrLogoSize = CGSizeMake(17.0f, 19.0f);
    UIImageView *aImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tumblr_logo_small"]];
    aImageView.frame = CGRectMake((tumblrLogoFrame.size.width-tumblrLogoSize.width)/2, (tumblrLogoFrame.size.height-tumblrLogoSize.height)/2, tumblrLogoSize.width, tumblrLogoSize.height);
    aImageView.backgroundColor = [UIColor clearColor];
    
    [aTumblrLogoView addSubview:aImageView];
    
    self.navigationItem.titleView = aTumblrLogoView;
}

-(NSString*)currentCategoryId
{
    NSString* categoryId = [NSString stringWithFormat:@"%d",kCategoryIndexForTumblr];
    return categoryId;
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
    return numberOfLoadedPosts + _showLoadMoreTumblr;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TumblrCell";
    static NSString *CellIdentifierLoadMore = @"LoadMoreCell";
    static NSString *CellIdentifierLoading = @"LoadingCell";
    
    if ( [self isIndexPathLastRow:indexPath] && !_isLoadingMoreTumblr  ) 
    {
        IgnantLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierLoadMore];
        if (cell == nil) {
            cell = [[IgnantLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLoadMore];
        }
        
        return cell;
    }
    
    else if([self isIndexPathLastRow:indexPath] && _isLoadingMoreTumblr)
    {
        IgnantLoadingMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierLoading];
        if (cell == nil) {
            cell = [[IgnantLoadingMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLoading];
        }
        
        return cell;
    }
    else
    {
        TumblrCell *cell = (TumblrCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        TumblrEntry* currentTumblrEntry = (TumblrEntry*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSURL *urlAtCurrentIndex = [NSURL URLWithString:currentTumblrEntry.imageUrl];
        
        if (cell == nil)
        {
            cell = [[TumblrCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];                        
        }
        
#warning TODO: add placeholder image
        [cell.tumblrImageView setImageWithURL:urlAtCurrentIndex
                             placeholderImage:nil];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

//set up the height of the given cell, taken into account the "load more posts" cell 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ( [self isIndexPathLastRow:indexPath]  ) 
    {
        return 40.0f;
    }
    else
    {
        return 350.0f;
    }
}

-(BOOL)isIndexPathLastRow:(NSIndexPath*)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
    
    if(indexPath.row >= numberOfObjects && _showLoadMoreTumblr)
    {
        return YES;
    }
    
    return NO;
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
    
    float reload_distance = -20;
    if(y > h + reload_distance) 
    {
        if (lastContentOffset.y < offset.y) //only trigger when scroll direction is DOWN
        if (!_isLoadingMoreTumblr && _numberOfActiveRequests==0) {
            [self loadMoreTumblrArticles];
        }
    }
    
    lastContentOffset = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - server communication actions
-(void)loadMoreTumblrArticles
{        
    if (_isLoadingMoreTumblr) return;
    _isLoadingMoreTumblr = YES;
    
    DBLog(@"loadMoreTumblrArticles");
    
    _numberOfActiveRequests++;
    
    NSDate* newImplementationDateForMost = [self.appDelegate.userDefaultsManager dateForLeastRecentArticleWithCategoryId:[self currentCategoryId]];    
    NSNumber *secondsSince1970 = [NSNumber numberWithInteger:[newImplementationDateForMost timeIntervalSince1970]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetMoreTumblrArticles,kParameterAction, secondsSince1970,kDateOfOldestArticle, [self currentPreferredLanguage],kParameterLanguage, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
    
    DBLog(@"LOAD MORE TUMBLR encodedString go: %@",encodedString);
    
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:encodedString]];
	[request setDelegate:self];
	[request startAsynchronous];    
}

-(void)loadLatestTumblrArticles
{
    if (isLoadingLatestTumblrArticles) return;        
    isLoadingLatestTumblrArticles = YES;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetLatestTumblrArticles,kParameterAction, [self currentPreferredLanguage],kParameterLanguage, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
    
    DBLog(@"LOAD LATEST TUMBLR encodedString go: %@",encodedString);
    
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:encodedString]];
	[request setDelegate:self];
	[request startAsynchronous]; 
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    LOG_CURRENT_FUNCTION()
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    if (_isLoadingMoreTumblr) {
        
        
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
    
    if (_isLoadingMoreTumblr) {
        
        dispatch_queue_t importerDispatchQueue = dispatch_queue_create("com.ignant.importerDispatchQueueMoreTumblr", NULL);
        dispatch_async(importerDispatchQueue, ^{
            [self.importer importJSONStringForTumblrPosts:[request responseString]];
        });
        dispatch_release(importerDispatchQueue);
        
    }
    else if (isLoadingLatestTumblrArticles) {
                
        dispatch_queue_t importerDispatchQueue = dispatch_queue_create("com.ignant.importerDispatchQueueLatestTumblr", NULL);
        dispatch_async(importerDispatchQueue, ^{
            [self.importer importJSONStringForTumblrPosts:[request responseString]];
        });
        dispatch_release(importerDispatchQueue);
        
        isLoadingLatestTumblrArticles = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tumblrTableView];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    LOG_CURRENT_FUNCTION()
        
    if (_isLoadingMoreTumblr) {
        
        _numberOfActiveRequests--;
        _isLoadingMoreTumblr = NO;
        
    }
    else if (isLoadingLatestTumblrArticles) {
        
        isLoadingLatestTumblrArticles = NO;
        
        if (_isLoadingTumblrArticlesForCurrentlyEmptyDataSet) {
            [self setIsCouldNotLoadDataViewHidden:NO];
        }
        
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


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TumblrEntry" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptorForDate = [[NSSortDescriptor alloc] initWithKey:@"publishingDate" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptorForDate];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     */
	    DBLog(@"Unresolved error %@, %@", error, [error userInfo]);
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

-(void)didStartImportingData
{
    LOG_CURRENT_FUNCTION()
    DBLog(@"tumblrFeed didStartImportingData");
    

    
    
}

-(void)didFinishImportingData
{
    LOG_CURRENT_FUNCTION() 
    DBLog(@"tumblrFeed didStartImportingData");
    
    
    
    
    if (_isLoadingMoreTumblr) {
        
        _numberOfActiveRequests--;
        _showLoadMoreTumblr = YES;
        _isLoadingMoreTumblr = NO;
        
    }
    else {
        
    }
    
    //set the last update date
    [self.appDelegate.userDefaultsManager setLastUpdateDate:[NSDate date] forCategoryId:[self currentCategoryId]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetch];
        [self.tumblrTableView reloadData];
        
        if (_isLoadingTumblrArticlesForCurrentlyEmptyDataSet) {            
            [self setIsLoadingViewHidden:YES];
            _isLoadingTumblrArticlesForCurrentlyEmptyDataSet = NO;
        }
    });
}

-(void)didFailImportingData
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
#warning TODO: DO SOMETHING IN THIS CASE!!!
    
    if (_isLoadingMoreTumblr) {
        
        _numberOfActiveRequests--;
        _showLoadMoreTumblr = YES;
        _isLoadingMoreTumblr = NO;
        
    }
    else {
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_isLoadingTumblrArticlesForCurrentlyEmptyDataSet) {            
#warning TODO: show appropriate window here: could not import data for first run, or similar
            _isLoadingTumblrArticlesForCurrentlyEmptyDataSet = NO;
        }
    });
}


- (void)importerDidSave:(NSNotification *)saveNotification {  
    [self.appDelegate performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
}

#pragma mark - custom special views
-(UIView *)couldNotLoadDataView
{
    UIView* defaultView = [super couldNotLoadDataView];
    self.couldNotLoadDataLabel.text = NSLocalizedString(@"could_not_load_data_for_tumblr_feed", @"Could not load tumblr feed");
    
    return defaultView;
}

@end
