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

#import "AFIgnantAPIClient.h"

#define kMinimumNumberOfPostsOnLoad 5

@interface IgnantTumblrFeedViewController ()

@property(assign) CGPoint lastContentOffset;
@property(assign) int numberOfActiveRequests;
@property(assign) BOOL isLoadingMoreTumblr;
@property(assign) BOOL showLoadMoreTumblr;
@property(assign) BOOL isLoadingLatestTumblrArticles;
@property(assign) BOOL isLoadingTumblrArticlesForCurrentlyEmptyDataSet;

@property(nonatomic, strong, readwrite) UILabel* couldNotLoadDataLabel;
@property(nonatomic, strong, readwrite) EGORefreshTableHeaderView *refreshHeaderView;

@end

@implementation IgnantTumblrFeedViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize fetchedResultsController = __fetchedResultsController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _numberOfActiveRequests = 0;
        _isLoadingTumblrArticlesForCurrentlyEmptyDataSet = NO;
                        
        self.importer = nil;
        
        self.showLoadMoreTumblr = YES;
        self.isLoadingMoreTumblr = NO;
        self.isLoadingLatestTumblrArticles = NO;
                
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
	GATrackPageView(&error, kGAPVTumblrView);
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
    /*
    CGRect tumblrLogoFrame = CGRectMake(0, 0, 24.0f, 24.0f);
    UIView *aTumblrLogoView = [[UIView alloc] initWithFrame:tumblrLogoFrame];
    aTumblrLogoView.backgroundColor = [UIColor whiteColor];
    
    CGSize tumblrLogoSize = CGSizeMake(17.0f, 19.0f);
    UIImageView *aImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tumblr_logo_small"]];
    aImageView.frame = CGRectMake((tumblrLogoFrame.size.width-tumblrLogoSize.width)/2, (tumblrLogoFrame.size.height-tumblrLogoSize.height)/2, tumblrLogoSize.width, tumblrLogoSize.height);
    aImageView.backgroundColor = [UIColor clearColor];
    
    [aTumblrLogoView addSubview:aImageView];
    
    self.navigationItem.titleView = aTumblrLogoView;
    */
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
		
		__block UIImageView* blockImageView = cell.tumblrImageView;
        [blockImageView		setImageWithURL:urlAtCurrentIndex
                             placeholderImage:nil
								 success:^(UIImage* image){
									 
											 blockImageView.alpha = .0f;
											 [UIView animateWithDuration:ASYNC_IMAGE_DURATION animations:^{
												 blockImageView.alpha = 1.0f;
											 }];	  
									  }
								failure:^(NSError* error){
								}];
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
        if (self.lastContentOffset.y < offset.y) //only trigger when scroll direction is DOWN
        if (!_isLoadingMoreTumblr && _numberOfActiveRequests==0) {
            [self loadMoreTumblrArticles];
        }
    }
    
    self.lastContentOffset = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - server communication actions
-(void)loadMoreTumblrArticles
{        
    if (self.isLoadingMoreTumblr) return;
    self.isLoadingMoreTumblr = YES;
    
    DBLog(@"loadMoreTumblrArticles");
    
    self.numberOfActiveRequests++;
    
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	DEF_BLOCK_SELF
#warning TODO: AFNetworking test this
	NSDate* newImplementationDateForMost = [self.appDelegate.userDefaultsManager dateForLeastRecentArticleWithCategoryId:[self currentCategoryId]];
	[[AFIgnantAPIClient sharedClient] getMoreDataForTumblrWithLeastRecentDate:newImplementationDateForMost
																	  success:^(AFHTTPRequestOperation *operation, id responseJSON) {
																			
																		  NSString* responseString = [[NSString alloc] initWithData:[operation responseData] encoding:NSUTF8StringEncoding];
																		  [blockSelf importTumblrDataWithResponseString:responseString];
																		  
																		  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
																		  
																	  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
																		  
																		  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
																		  
																		  self.numberOfActiveRequests--;
																		  self.isLoadingMoreTumblr = NO;
																		  
																	  }];
	
}

-(void)loadLatestTumblrArticles
{
#warning TODO: built in afnetworking - check if this works
	
    if (self.isLoadingLatestTumblrArticles) {
		return;
	}
    self.isLoadingLatestTumblrArticles = YES;
    
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	if (_isLoadingTumblrArticlesForCurrentlyEmptyDataSet) {
		[self setIsLoadingViewHidden:NO];
	}
	
	DEF_BLOCK_SELF
	[[AFIgnantAPIClient sharedClient] getLatestDataForTumblrWithSuccess:^(AFHTTPRequestOperation *operation, id responseJSON) {
		
		NSString* responseString = [[NSString alloc] initWithData:[operation responseData] encoding:NSUTF8StringEncoding];
		[blockSelf importTumblrDataWithResponseString:responseString];
		blockSelf.isLoadingLatestTumblrArticles = NO;
        [blockSelf.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:blockSelf.tumblrTableView];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		blockSelf.isLoadingLatestTumblrArticles = NO;
        if (blockSelf.isLoadingTumblrArticlesForCurrentlyEmptyDataSet) {
            [blockSelf setIsCouldNotLoadDataViewHidden:NO];
        }
        [blockSelf.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tumblrTableView];
		
	}];

}

-(void)importTumblrDataWithResponseString:(NSString*)reponseString
{
	DEF_BLOCK_SELF
	dispatch_queue_t importerDispatchQueue = dispatch_queue_create("com.ignant.importerDispatchQueueLatestTumblr", NULL);
	dispatch_async(importerDispatchQueue, ^{
		[blockSelf.importer importJSONStringForTumblrPosts:reponseString];
	});
	dispatch_release(importerDispatchQueue);
	
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self loadLatestTumblrArticles];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return self.isLoadingLatestTumblrArticles;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date];
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
    
    if (success) {
        [self.tumblrTableView reloadData];
    }
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
    
    if (self.isLoadingMoreTumblr) {
        
        self.numberOfActiveRequests--;
        self.showLoadMoreTumblr = YES;
        self.isLoadingMoreTumblr = NO;
        
    }
    else {
        
    }
    
    //set the last update date
    [self.appDelegate.userDefaultsManager setLastUpdateDate:[NSDate date] forCategoryId:[self currentCategoryId]];
    
	DEF_BLOCK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        [blockSelf fetch];
        [blockSelf.tumblrTableView reloadData];
        
        if (blockSelf.isLoadingTumblrArticlesForCurrentlyEmptyDataSet) {
            [blockSelf setIsLoadingViewHidden:YES];
            blockSelf.isLoadingTumblrArticlesForCurrentlyEmptyDataSet = NO;
        }
    });
}

-(void)didFailImportingData
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
        
    if (self.isLoadingMoreTumblr) {
        self.numberOfActiveRequests--;
        self.showLoadMoreTumblr = YES;
        self.isLoadingMoreTumblr = NO;
    }
    else {
        
    }
    
	DEF_BLOCK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (blockSelf.isLoadingTumblrArticlesForCurrentlyEmptyDataSet) {
            blockSelf.isLoadingTumblrArticlesForCurrentlyEmptyDataSet = NO;
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
