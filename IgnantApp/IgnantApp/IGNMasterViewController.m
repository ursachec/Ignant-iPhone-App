//
//  IGNMasterViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//


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

//import HJ headers
#import "HJMOFileCache.h"
#import "HJObjManager.h"


#import "IgnantLoadingView.h"

#import "IGNAppDelegate.h"


#import "IgnantImporter.h"

//imports for ASIHTTPRequest
#import "ASIHTTPRequest.h"
#import "NSURL+stringforurl.h"

#import "Constants.h"


@interface IGNMasterViewController ()
{
    IGNAppDelegate *appDelegate;
}

-(BOOL)isIndexPathLastRow:(NSIndexPath*)indexPath;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)loadMoreContent;

@property (nonatomic, retain) HJObjManager *hjObjectManager;
@property (nonatomic, retain, readwrite) IgnantImporter *importer;

@property (retain, nonatomic, readwrite) Category* currentCategory;
@property (assign, readwrite) BOOL isHomeCategory;
@end

#pragma mark -

@implementation IGNMasterViewController

@synthesize isHomeCategory = _isHomeCategory;

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize hjObjectManager = _hjObjectManager;

@synthesize blogEntriesTableView = _blogEntriesTableView;
@synthesize detailViewController = _detailViewController;

@synthesize importer = _importer;

@synthesize currentCategory = _currentCategory;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil category:(Category*)category
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _showLoadMoreContent = YES;
        _isLoadingMoreContent = NO;
        _isLoadingLatestContent = NO;
        
        self.currentCategory = category;
        self.isHomeCategory = (category==nil) ? TRUE : FALSE;
        
        
        appDelegate = (IGNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        //create the importer - done in a separate method in case the subclasses have to use it - 
        //!!! there have to be different persistentStoreCoordinators
        [self createImporter];
        
    }
    
    return self;
}
							
- (void)dealloc
{
    [_detailViewController release];
    [__fetchedResultsController release];
    [__managedObjectContext release];
    [_blogEntriesTableView release];
    [super dealloc];
}

-(void)createImporter
{
    //use the importer from the appDelegate
            
    _importer = [[IgnantImporter alloc] init];
    _importer.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
    _importer.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - show mosaik / more
- (IBAction)showMosaik:(id)sender 
{
    IGNMosaikViewController *mosaikVC = appDelegate.mosaikViewController;
    mosaikVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    mosaikVC.parentNavigationController = self.navigationController;
    [self.navigationController presentModalViewController:mosaikVC animated:YES];
}

- (IBAction)showMore:(id)sender 
{
    IGNMoreOptionsViewController *moreOptionsVC = [[IGNMoreOptionsViewController alloc] initWithNibName:@"IGNMoreOptionsViewController" bundle:nil];
    [self.navigationController pushViewController:moreOptionsVC animated:YES];
    [moreOptionsVC release];
}

- (IBAction)showTumblr:(id)sender {
    
    IgnantTumblrFeedViewController *tumblrVC = appDelegate.tumblrFeedViewController;
    [self.navigationController pushViewController:tumblrVC animated:YES];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //check when was the last time updating the currently set category and trigger load latest/load more
    
    NSString* currentCategoryId = self.currentCategory ? self.currentCategory.categoryId : [NSString stringWithFormat:@"%d",kCategoryIndexForHome];
    NSDate* dateForLastUpdate = [appDelegate.userDefaultsManager lastUpdateDateForCategoryId:currentCategoryId];
    NSLog(@"dateForLastUpdate: %@, catgoryId: %@", dateForLastUpdate, currentCategoryId);
    
    
    //only check if data is here if not on first run
    if (![appDelegate isLoadingDataForFirstRun])
    if (dateForLastUpdate==nil) 
    {
        [self loadLatestContent];
        NSLog(@"dateForLastUpdate is nil, loadLatestTumblrArticles");
        
    }
    else if( [dateForLastUpdate timeIntervalSinceNow]) 
    {
        NSLog(@"dateForLastUpdate not nill, timeIntervalSinceNow: %f", [dateForLastUpdate timeIntervalSinceNow]);
    
    }
    
    
    //set up some ui elements
    if (self.isHomeCategory) 
    {
        
        UIImageView *aImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ignantLogoForTopBarSmall.png"]];
        aImageView.frame = CGRectMake(0, 0, 35.0f, 35.0f);
        self.navigationItem.titleView = aImageView;
        [aImageView release];
        
    }
    else 
    {
        UILabel *someLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 40.0f)];
        someLabel.text = [self.currentCategory name];
        someLabel.textAlignment = UITextAlignmentCenter;
        someLabel.font = [UIFont fontWithName:@"Georgia" size:14.0f];
        self.navigationItem.titleView = someLabel;
        [someLabel release];
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
		[view release];
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    if (self.isHomeCategory) 
    {
            self.navigationItem.leftBarButtonItem = nil;
    }
    
    //load the object manager and file cache
    self.hjObjectManager = [[[HJObjManager alloc] init] autorelease];
	NSString* cacheDirectory = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/imgcache/imgtable/"] ;
	HJMOFileCache* fileCache = [[[HJMOFileCache alloc] initWithRootPath:cacheDirectory] autorelease];
	self.hjObjectManager.fileCache = fileCache;
    
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
            cell = [[[IgnantLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLoadMore] autorelease];
            
        }
        
        
        return cell;
        
    }
    else if([self isIndexPathLastRow:indexPath] && _isLoadingMoreContent)
    {
    
        IgnantLoadingMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierLoading];
        if (cell == nil) {
            cell = [[[IgnantLoadingMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLoading] autorelease];
        }
        
        return cell;
    }
    else
    {
    
        
        IgnantCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[IgnantCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            //#define MAX_IMAGE_WIDTH 148.0f
            //        CGFloat ratio = 296.0f/194.0f;
            //        UIImageView *thumbImageView = [[UIImageView alloc] initWithImage:athumbImage];
            //        thumbImageView.tag = 999;
            //        thumbImageView.frame = CGRectMake(5.0f, 0.0f, MAX_IMAGE_WIDTH, MAX_IMAGE_WIDTH/ratio);
            //        [cell addSubview:thumbImageView];
            //        [thumbImageView release];
            
        }
        
        
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
            
#warning TODO: check performance, maybe us something better to let the tableview know that the cell has changed
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
            self.detailViewController = [[[IGNDetailViewController alloc] initWithNibName:@"IGNDetailViewController_iPhone" bundle:nil] autorelease];
        }
        
        self.detailViewController.isShowingArticleFromLocalDatabase = YES;
        
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
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BlogEntry" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptorForDate = [[[NSSortDescriptor alloc] initWithKey:@"publishingDate" ascending:NO] autorelease];
//    NSSortDescriptor *sortDescriptorForTitle = [[[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorForDate, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //set the appropriate category if NOT home category
    if (!self.isHomeCategory)
    {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"categoryId == %@", [self.currentCategory categoryId]]];
    }
    
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
    
//    NSLog(@"categoryViews: %@", blogEntry.numberOfViews);
        
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    cell.dateString = [formatter stringFromDate:blogEntry.publishingDate];
    [formatter release];
    
    
    //set up image    
    cell.imageIdentifier = blogEntry.thumbIdentifier;
    
    NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    applicationDocumentsDir = [applicationDocumentsDir stringByAppendingFormat:@"thumbs/"];
    NSString *storePath = [applicationDocumentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg",cell.imageIdentifier]];
    UIImage* athumbImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:storePath]];
    
    cell.thumbImage = athumbImage;
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
    
    NSLog(@"encodedString go: %@",encodedString);
    
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
    
    
#warning NEW IMPLEMENTATION
    
    NSString *currentCategoryId = self.currentCategory ? self.currentCategory.categoryId : [NSString stringWithFormat:@"%d",kCategoryIndexForHome]; 
    NSDate* newImplementationDateForMost = [appDelegate.userDefaultsManager dateForLeastRecentArticleWithCategoryId:currentCategoryId];
    NSLog(@"newImplementationDateForMost: %@, currentCategory: %@", newImplementationDateForMost, currentCategoryId);

#warning END OF NEW IMPLEMENTATION
    
        
    NSDate* lastImportDateForMainPageArticle = (NSDate*) [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsLastImportDateForMainPageArticle];
    
    NSLog(@"lastImportDateForMainPageArticle: %@", lastImportDateForMainPageArticle);
    NSNumber *secondsSince1970 = [NSNumber numberWithInteger:[lastImportDateForMainPageArticle timeIntervalSince1970]];
    
    //set the relevant categoryId
    NSString *categoryId = @"";
    if (self.isHomeCategory) 
    {
        categoryId = [NSString stringWithFormat:@"%d",kCategoryIndexForHome];
    }
    else 
    {
        categoryId = [self.currentCategory categoryId];
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetMoreArticlesForCategory,kParameterAction,categoryId,kCurrentCategoryId, secondsSince1970, kDateOfOldestArticle, nil];
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
    
    NSString *currentCategoryId = self.currentCategory ? self.currentCategory.categoryId : [NSString stringWithFormat:@"%d",kCategoryIndexForHome]; 
    NSDate *lastUpdateDateForCurrentCategoryId = [appDelegate.userDefaultsManager lastUpdateDateForCategoryId:currentCategoryId];
    
    
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
        
        #warning IMPORTANT!!! TODO implement importing the string to CoreData
        
        NSLog(@"load more content: %@", [request responseString]);
        
        _numberOfActiveRequests--;
        _showLoadMoreContent = YES;
        _isLoadingMoreContent = NO;
        
    }
    else if (_isLoadingLatestContent) {
        
        NSLog(@"request: %@", [request responseString]);


        #warning IMPORTANT!!! TODO implement importing the string to CoreData
        
        dispatch_queue_t importerDispatchQueue = dispatch_queue_create("com.ignant.importerDispatchQueue", NULL);
        dispatch_async(importerDispatchQueue, ^{
            [self.importer importJSONString:[request responseString]];
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
        
        if ([appDelegate.userDefaultsManager lastUpdateDateForCategoryId:self.currentCategory.categoryId]==nil) {
            [self setIsLoadingViewHidden:YES];
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
        [appDelegate.userDefaultsManager setLastUpdateDate:[NSDate date] forCategoryId:self.currentCategory.categoryId];
    });
}

- (void)importerDidSave:(NSNotification *)saveNotification {  
    
    [appDelegate performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
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
	
    NSDate* dateForLastUpdate = [appDelegate.userDefaultsManager lastUpdateDateForCategoryId:self.currentCategory.categoryId];
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

@end
