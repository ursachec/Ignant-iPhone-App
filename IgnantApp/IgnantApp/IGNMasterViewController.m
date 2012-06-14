//
//  IGNMasterViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//


#import "Reachability.h"

//import necessary ViewController files
#import "IGNMasterViewController.h"
#import "IGNDetailViewController.h"
#import "IGNMoreOptionsViewController.h"
#import "IGNMosaikViewController.h"
#import "IgnantTumblrFeedViewController.h"

//import CoreData headers
#import "BlogEntry.h"
#import "Image.h"
#import "Category.h"

//import cell headers
#import "IgnantCell.h"
#import "IgnantLoadMoreCell.h"
#import "IgnantLoadingMoreCell.h"


#import "IgnantLoadingView.h"


#import "IgnantImporter.h"

//imports for ASIHTTPRequest
#import "ASIHTTPRequest.h"
#import "NSURL+stringforurl.h"

#import "Constants.h"


#import <SDWebImage/UIImageView+WebCache.h>


@interface IGNMasterViewController ()

-(BOOL)isIndexPathLastRow:(NSIndexPath*)indexPath;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)loadMoreContent;
-(NSString*)currentCategoryId;

@property (strong, nonatomic, readwrite) Category* currentCategory;
@property (assign, readwrite) BOOL isHomeCategory;

@end

#pragma mark -

@implementation IGNMasterViewController

@synthesize isHomeCategory = _isHomeCategory;

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

@synthesize blogEntriesTableView = _blogEntriesTableView;
@synthesize detailViewController = _detailViewController;

@synthesize currentCategory = _currentCategory;

@synthesize fetchingDataForFirstRun;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil category:(Category*)category
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _showLoadMoreContent = YES;
        _isLoadingMoreContent = NO;
        _isLoadingLatestContent = NO;
        
        self.currentCategory = category;
        self.isHomeCategory = (category==nil) ? TRUE : FALSE;
        
        if (self.isHomeCategory) {
#warning TODO: set this title in a better way
                    self.title = @"Home";
        }
        else if(category!=nil) {
            self.title = category.name;
        }
        
        self.importer = nil;
    }
    
    return self;
}

-(void)forceSetCurrentCategory:(Category *)currentCategory
{
    _showLoadMoreContent = YES;
    _isLoadingMoreContent = NO;
    _isLoadingLatestContent = NO;
    
    self.currentCategory = currentCategory;
    self.isHomeCategory = (currentCategory==nil) ? TRUE : FALSE;
    
    if (self.isHomeCategory) {
        self.title = @"Home";
    }
    else if(currentCategory!=nil) {
        self.title = currentCategory.name;
    }
    
    self.fetchedResultsController = nil;
    [self fetch];
}


-(NSString*)currentCategoryId
{
    NSString* categoryId = self.currentCategory ? self.currentCategory.categoryId : [NSString stringWithFormat:@"%d",kCategoryIndexForHome];
    return categoryId;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - show mosaik / more
- (IBAction)showMosaik:(id)sender 
{
    IGNMosaikViewController *mosaikVC = self.appDelegate.mosaikViewController;
    mosaikVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    mosaikVC.parentNavigationController = self.navigationController;
    
    if (!mosaikVC.isMosaicImagesArrayNotEmpty && ![self.appDelegate checkIfAppOnline]) 
    {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"" 
                                                     message:NSLocalizedString(@"ui_alert_message_you_need_an_internet_connection",nil)  
                                                    delegate:self 
                                           cancelButtonTitle:NSLocalizedString(@"ui_alert_dismiss",nil)
                                           otherButtonTitles:nil];
        [av show];
        
        return;
    }
    else 
    {
        [self.navigationController presentModalViewController:mosaikVC animated:YES];
    }
}

- (IBAction)showMore:(id)sender 
{
    IGNMoreOptionsViewController *moreOptionsVC = [[IGNMoreOptionsViewController alloc] initWithNibName:@"IGNMoreOptionsViewController" bundle:nil];
    [self.navigationController pushViewController:moreOptionsVC animated:YES];
}

- (IBAction)showTumblr:(id)sender {
    IgnantTumblrFeedViewController *tumblrVC = self.appDelegate.tumblrFeedViewController;
    [self.navigationController pushViewController:tumblrVC animated:YES];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    NSLog(@"importer is nil: %@", (self.importer==nil) ? @"TRUE" : @"FALSE");
        
    //check when was the last time updating the currently set category and trigger load latest/load more
    NSDate* dateForLastUpdate = [self.appDelegate.userDefaultsManager lastUpdateDateForCategoryId:[self currentCategoryId]];    
    NSLog(@"dateForLastUpdate: %@", dateForLastUpdate);
    
    
    //only check if data is here if not on first run
    if (![self.appDelegate isLoadingDataForFirstRun] && [self.appDelegate checkIfAppOnline])
    if (dateForLastUpdate==nil) 
    {
        [self loadLatestContent];        
    }
    
    if (!self.isHomeCategory && [self.appDelegate checkIfAppOnline])
    {
        if (dateForLastUpdate==nil) 
        {
            [self loadLatestContent];        
        }
        else if( [dateForLastUpdate timeIntervalSinceNow]) 
        {
            NSLog(@"dateForLastUpdate not nil, timeIntervalSinceNow: %f", [dateForLastUpdate timeIntervalSinceNow]);
        }
    }
    
    //set up some ui elements
    if (self.isHomeCategory) 
    {
        UIImageView *aImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ignantLogoForTopBarSmall.png"]];
        aImageView.frame = CGRectMake(0, 0, 35.0f, 35.0f);
        self.navigationItem.titleView = aImageView;
    }
    else 
    {
        UILabel *someLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 40.0f)];
        someLabel.text = [[self.currentCategory name] uppercaseString];
        someLabel.textAlignment = UITextAlignmentCenter;
        someLabel.font = [UIFont fontWithName:@"Georgia" size:10.0f];
        self.navigationItem.titleView = someLabel;
    }
    
    if (self.appDelegate.shouldLoadDataForFirstRun && [self.appDelegate checkIfAppOnline]) {
        [self setIsLoadingViewHidden:NO];
        self.navigationController.navigationBarHidden = YES;
    }
    
    else if (self.appDelegate.shouldLoadDataForFirstRun && ![self.appDelegate checkIfAppOnline]) {
        [self setIsCouldNotLoadDataViewHidden:NO];
        self.navigationController.navigationBarHidden = YES;
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //set up the refresh header view
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.blogEntriesTableView.bounds.size.height, self.view.frame.size.width, self.blogEntriesTableView.bounds.size.height)];
		view.delegate = self;
		[self.blogEntriesTableView addSubview:view];
		_refreshHeaderView = view;
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    if (self.isHomeCategory) 
    {
            self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)viewDidUnload
{
    [self setBlogEntriesTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

#pragma mark - UITableView delegate & datasource

//set up the height of the given cell, taken into account the "load more posts" cell 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ( [self isIndexPathLastRow:indexPath]  ) 
    {
        return 60.0f;
    }
    else
    {
        return 109.0f;
    }
}


// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

//set up the number of rows in the section +/- the "load more posts" cell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects] + _showLoadMoreContent;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"IgnantCell";
    static NSString *CellIdentifierLoadMore = @"LoadMoreCell";
    static NSString *CellIdentifierLoading = @"LoadingCell";
    
    
    if ( [self isIndexPathLastRow:indexPath] && !_isLoadingMoreContent  ) 
    {
        
        IgnantLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierLoadMore];
        if (cell == nil) {
            cell = [[IgnantLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLoadMore];
            
        }
        
        return cell;
    }
    
    else if([self isIndexPathLastRow:indexPath] && _isLoadingMoreContent)
    {
    
        IgnantLoadingMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierLoading];
        if (cell == nil) {
            cell = [[IgnantLoadingMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLoading];
        }
        
        return cell;
    }
    
    else
    {
        
        IgnantCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[IgnantCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            //#define MAX_IMAGE_WIDTH 148.0f
            //        CGFloat ratio = 296.0f/194.0f;
            //        UIImageView *thumbImageView = [[UIImageView alloc] initWithImage:athumbImage];
            //        thumbImageView.tag = 999;
            //        thumbImageView.frame = CGRectMake(5.0f, 0.0f, MAX_IMAGE_WIDTH, MAX_IMAGE_WIDTH/ratio);
            //        [cell addSubview:thumbImageView];
            //        [thumbImageView release];
            
        }
        
        BlogEntry *blogEntry = (BlogEntry*)[self.fetchedResultsController objectAtIndexPath:indexPath];            
        NSString* currentArticleId = blogEntry.articleId;
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:currentArticleId,kArticleId, nil];
        NSString *requestString = kAdressForImageServer;
        NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
        NSURL* urlAtCurrentIndex = [NSURL URLWithString:encodedString];
        [cell.cellImageView setImageWithURL:urlAtCurrentIndex
                           placeholderImage:nil];
        
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
    }
    
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if ([self isIndexPathLastRow:indexPath]) 
    {
        if (!_isLoadingMoreContent) 
        {
            [self loadMoreContent];
            [_blogEntriesTableView reloadData];
        }
        else
        {
            NSLog(@"trying to load more posts, will not trigger again");
        }
    }
    else
    {
        if (!self.detailViewController) {
            self.detailViewController = [[IGNDetailViewController alloc] initWithNibName:@"IGNDetailViewController_iPhone" bundle:nil];
        }
        
        self.detailViewController.isShowingArticleFromLocalDatabase = YES;
        self.detailViewController.viewControllerToReturnTo = self;
        
        //set up the selected object and previous/next objects
        NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.detailViewController.blogEntry = (BlogEntry*)selectedObject;
        
        NSArray *fetchedResultsArray = self.fetchedResultsController.fetchedObjects;
        self.detailViewController.fetchedResults = fetchedResultsArray;
        self.detailViewController.currentBlogEntryIndex = indexPath.row;
        
        if (indexPath.row-1>=0) {
            self.detailViewController.previousBlogEntryIndex = indexPath.row-1;
        } 
        else{
            self.detailViewController.previousBlogEntryIndex = kInvalidBlogEntryIndex;
        }
        
        if(indexPath.row+1<fetchedResultsArray.count)
        {
            self.detailViewController.nextBlogEntryIndex = indexPath.row+1;
        }
        else{
            self.detailViewController.nextBlogEntryIndex = kInvalidBlogEntryIndex;
        }
        
        //set the managedObjectContext and push the view controller
        self.detailViewController.managedObjectContext = self.managedObjectContext;
        self.detailViewController.isNavigationBarAndToolbarHidden = NO;
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    }
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BlogEntry" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptorForDate = [[NSSortDescriptor alloc] initWithKey:@"publishingDate" ascending:NO];
//    NSSortDescriptor *sortDescriptorForTitle = [[[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorForDate, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //set the appropriate category if NOT home category
    if (!self.isHomeCategory)
    {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"categoryId == %@", [self.currentCategory categoryId]]];
    }
    else {
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"showInHomeCategory == %@", [NSNumber numberWithBool:TRUE]]];
        
    }
    
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
    [self.blogEntriesTableView reloadData];
}
 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.blogEntriesTableView reloadData];
}
 
- (void)configureCell:(IgnantCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    BlogEntry *blogEntry = (BlogEntry*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.title = [blogEntry.title uppercaseString];
    
    cell.categoryName = blogEntry.categoryName;
    
    NSString* currentArticleId = blogEntry.articleId;
    
   
//    NSLog(@"categoryViews: %@", blogEntry.numberOfViews);
        
    if (blogEntry.publishingDate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        cell.dateString = [formatter stringFromDate:blogEntry.publishingDate];
    }
}

-(BOOL)isIndexPathLastRow:(NSIndexPath*)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];    
    
    if(indexPath.row >= numberOfObjects && _showLoadMoreContent)
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - getting content from the server
-(void)loadLatestContent
{
    if (_isLoadingLatestContent) return;        
    _isLoadingLatestContent = YES;
    
    NSString *categoryId = self.currentCategory!=nil ? self.currentCategory.categoryId : kUndefinedCategoryId;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetLatestArticlesForCategory,kParameterAction,categoryId,kCurrentCategoryId, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
    
    NSLog(@"MASTER LOAD LATEST CONTENT encodedString go: %@",encodedString);
    
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:encodedString]];
	[request setDelegate:self];
	[request startAsynchronous]; 
}

-(void)loadMoreContent
{
    if (_isLoadingMoreContent) return;        
    _isLoadingMoreContent = YES;
    
#warning IS THIS REALLY NECESSARY AT THIS POINT ? 
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.blogEntriesTableView reloadData];
        
    });
    
    NSDate* newImplementationDateForMost = [self.appDelegate.userDefaultsManager dateForLeastRecentArticleWithCategoryId:[self currentCategoryId]];
    
    NSNumber *secondsSince1970 = [NSNumber numberWithInteger:[newImplementationDateForMost timeIntervalSince1970]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetMoreArticlesForCategory,kParameterAction,[self currentCategoryId],kCurrentCategoryId, secondsSince1970, kDateOfOldestArticle, nil];
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
    
    NSLog(@"requestStarted");
    
    NSDate *lastUpdateDateForCurrentCategoryId = [self.appDelegate.userDefaultsManager lastUpdateDateForCategoryId:[self currentCategoryId]];
    
    
    if (_isLoadingMoreContent) {
        
        
        
    }
    
    else if (_isLoadingLatestContent) {
        
        if (lastUpdateDateForCurrentCategoryId==nil) {
            [self setIsLoadingViewHidden:NO];
        }
        
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    LOG_CURRENT_FUNCTION()
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (_isLoadingMoreContent) {
                
        
        
        
        dispatch_queue_t importerDispatchQueue = dispatch_queue_create("com.ignant.importerDispatchQueue", NULL);
        dispatch_async(importerDispatchQueue, ^{
            [self.importer importJSONWithMorePosts:[request responseString] forCategoryId:[self currentCategoryId]];
        });
        
        _numberOfActiveRequests--;
        _showLoadMoreContent = YES;
        _isLoadingMoreContent = NO;
        
    }
    else if (_isLoadingLatestContent) {
                
        dispatch_queue_t importerDispatchQueue = dispatch_queue_create("com.ignant.importerDispatchQueue", NULL);
        dispatch_async(importerDispatchQueue, ^{
            [self.importer importJSONWithLatestPosts:[request responseString] forCategoryId:[self currentCategoryId]];
        });
        
        _isLoadingLatestContent = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.blogEntriesTableView];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"requestFailed");
    
#warning TODO: do something if the request has failed
    
    if (_isLoadingMoreContent) {    
        _numberOfActiveRequests--;
        _isLoadingMoreContent = NO;
    }
    
    else if (_isLoadingLatestContent) {
        if ([self.appDelegate.userDefaultsManager lastUpdateDateForCategoryId:[self currentCategoryId]]==nil) {
            [self setIsCouldNotLoadDataViewHidden:NO];
        }
        
        _isLoadingLatestContent = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.blogEntriesTableView];
    }
}

#pragma mark - IgnantImporterDelegate

-(void)didStartImportingData
{
    NSLog(@"MasterVC didStartImportingData");
    
    LOG_CURRENT_FUNCTION_AND_CLASS()
        
}

-(void)didFailImportingData
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setIsLoadingViewHidden:YES];
    });

}
-(void)didFinishImportingData
{
    
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self fetch];
        [self.blogEntriesTableView reloadData];
        [self setIsLoadingViewHidden:YES];
        
        [self.appDelegate.userDefaultsManager setLastUpdateDate:[NSDate date] forCategoryId:[self currentCategoryId]];
    });
}

- (void)importerDidSave:(NSNotification *)saveNotification {  
    
    [self.appDelegate performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
}


#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.blogEntriesTableView];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
//	[self reloadTableViewDataSource];
//	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    
    [self loadLatestContent];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
    NSDate* dateForLastUpdate = [self.appDelegate.userDefaultsManager lastUpdateDateForCategoryId:[self currentCategoryId]];
	return dateForLastUpdate==nil ? [NSDate dateWithTimeIntervalSince1970:0] : dateForLastUpdate;
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
        if (!_isLoadingMoreContent) 
        {
            [self loadMoreContent];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - IgnantNoInternetConnectionViewDelegate
-(void)retryToLoadData
{
    NSLog(@"retryToLoadData");
    
    if ([self.appDelegate checkIfAppOnline]) {
        [self.appDelegate fetchAndLoadDataForFirstRun];
    }
    
    else {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"" 
                                                     message:NSLocalizedString(@"ui_alert_message_you_need_an_internet_connection",nil)  
                                                    delegate:self 
                                           cancelButtonTitle:NSLocalizedString(@"ui_alert_dismiss",nil)
                                           otherButtonTitles:nil];
        [av show];
        
        return;
    }
}

#pragma mark - custom special views
-(void)setUpCouldNotLoadDataView
{
    [super setUpCouldNotLoadDataView];
    
    
    NSLog(@"MASTER shouldLoadData: %@", self.appDelegate.shouldLoadDataForFirstRun ? @"TRUE" : @"FALSE");
    
#warning BETTER TEXT!
    
    
    if (self.appDelegate.shouldLoadDataForFirstRun && [self.appDelegate checkIfAppOnline]) {
        self.couldNotLoadDataLabel.text = @"Could not load data from SERVER for first RUN, sorry!";
    }
    
    else if (self.appDelegate.shouldLoadDataForFirstRun && ![self.appDelegate checkIfAppOnline]) {
        self.couldNotLoadDataLabel.text = @"You need an internet connection to load data for the first time.";
    }
    
    else {
        self.couldNotLoadDataLabel.text = @"Could not load data, sorry double!";
    }

}

@end
