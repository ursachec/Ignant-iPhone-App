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
{
    CGPoint lastContentOffset;
}

-(BOOL)isIndexPathLastRow:(NSIndexPath*)indexPath;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)loadMoreContent;
-(NSString*)currentCategoryId;


@property (strong, nonatomic, readwrite) UIView* scrollTopHomeButtonView;
@property (strong, nonatomic, readwrite) Category* currentCategory;
@property (unsafe_unretained, readwrite) BOOL isHomeCategory;


@property (strong, nonatomic, readwrite) NSDateFormatter* articleCellDateFormatter;
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

@synthesize importer = _importer;

@synthesize articleCellDateFormatter = _articleCellDateFormatter;


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
            self.title = NSLocalizedString(@"vc_title_home", @"Home");
        }
        else if(category!=nil) {
            self.title = category.name;
        }
        
        self.importer = nil;
        
        
    }
    
    return self;
}

-(NSDateFormatter*)articleCellDateFormatter
{
    if (_articleCellDateFormatter==nil) {
        _articleCellDateFormatter = [[NSDateFormatter alloc] init];
        [_articleCellDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_articleCellDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    
    return _articleCellDateFormatter;
}

-(void)forceSetCurrentCategory:(Category *)currentCategory
{
    _showLoadMoreContent = YES;
    _isLoadingMoreContent = NO;
    _isLoadingLatestContent = NO;
    
    self.currentCategory = currentCategory;
    self.isHomeCategory = (currentCategory==nil) ? TRUE : FALSE;
    
    if (self.isHomeCategory) {
        self.title = NSLocalizedString(@"vc_title_home", @"Home");
    }
    else if(currentCategory!=nil) {
        self.title = currentCategory.name;
    }
    self.importer = nil;
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

-(void)showArticleWithId:(NSString*)articleId
{    
    if (!self.detailViewController) {
        self.detailViewController = [[IGNDetailViewController alloc] initWithNibName:@"IGNDetailViewController_iPhone" bundle:nil];
    }

    self.detailViewController.didLoadContentForRemoteArticle = NO;
    self.detailViewController.isShowingArticleFromLocalDatabase = NO;
    self.detailViewController.viewControllerToReturnTo = self;
    
    //set up the selected object and previous/next objects
    self.detailViewController.currentArticleId = articleId;
    self.detailViewController.nextBlogEntryIndex = kInvalidBlogEntryIndex;
    self.detailViewController.previousBlogEntryIndex = kInvalidBlogEntryIndex;

    //set the managedObjectContext and push the view controller
    self.detailViewController.managedObjectContext = self.managedObjectContext;
    self.detailViewController.isNavigationBarAndToolbarHidden = NO;
    [self.navigationController pushViewController:self.detailViewController animated:NO];        
}

#pragma mark - View lifecycle

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSError* error = nil;
    [[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:kGAPVCategoryView,[self currentCategoryId]]
                                    withError:&error];
}

-(void)handleTapOnHomeButtonScrollTop
{
    [self.blogEntriesTableView scrollRectToVisible:CGRectMake(0.0f, 0.0f, 310.0f, 10.0f) animated:YES];
}

-(void)setupHomeButtonScrollTop
{
    CGRect navBarFrame = self.navigationController.navigationBar.frame;
    
    CGSize buttonSize = CGSizeMake(40.0f, 40.0f);
    CGRect vFrame = CGRectMake((navBarFrame.size.width-buttonSize.width)/2, (navBarFrame.size.height-buttonSize.height)/2, buttonSize.width, buttonSize.height);
    
    UIButton* aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    aButton.backgroundColor = [UIColor clearColor];
    [aButton setTitle:@"" forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height);
    [aButton addTarget:self action:@selector(handleTapOnHomeButtonScrollTop) forControlEvents:UIControlEventTouchDown];
    
    UIView* aView = [[UIView alloc] initWithFrame:vFrame];
    [aView addSubview:aButton];
    
    self.scrollTopHomeButtonView = aView;
    
    [self.navigationController.navigationBar addSubview:self.scrollTopHomeButtonView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.scrollTopHomeButtonView removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isHomeCategory) {
        [self setupHomeButtonScrollTop];
    }
    
    //check when was the last time updating the currently set category and trigger load latest/load more
    NSDate* dateForLastUpdate = [self.appDelegate.userDefaultsManager lastUpdateDateForCategoryId:[self currentCategoryId]];    
    DBLog(@"dateForLastUpdate: %@ isLoadingDataForFirstRun: %@", dateForLastUpdate, [self.appDelegate isLoadingDataForFirstRun] ? @"TRUE" : @"FALSE");
    
    //only check if data is here if not on first run
    if ((dateForLastUpdate==nil) && ![self.appDelegate isLoadingDataForFirstRun] && [self.appDelegate checkIfAppOnline])
    {
        [self loadLatestContent];
    }
    else if(![self.appDelegate isLoadingDataForFirstRun])
    {
        if ( [self.appDelegate checkIfAppOnline])
        {
            [self triggerLoadLatestDataIfNecessary];
        }
        else if ( ![self.appDelegate checkIfAppOnline] ) {
            
            if (dateForLastUpdate==nil)
            {
                [self setIsNoConnectionViewHidden:NO];
            }
            else if( [dateForLastUpdate timeIntervalSinceNow])
            {
                [self setIsNoConnectionViewHidden:YES];
            }
        }
    }
    
    
    //set up some ui elements
    if (self.isHomeCategory) 
    {
        UIImageView *aImageView = [[UIImageView alloc] initWithImage:nil];
        aImageView.frame = CGRectMake(0, 0, 35.0f, 35.0f);
        aImageView.backgroundColor = [UIColor clearColor];
        self.navigationItem.titleView = aImageView;
    }
    else 
    {
        UIImageView *aImageView = [[UIImageView alloc] initWithImage:nil];
        aImageView.frame = CGRectMake(0, 0, 35.0f, 35.0f);
        aImageView.backgroundColor = [UIColor clearColor];
        self.navigationItem.titleView = aImageView;
    }
    
    if (self.appDelegate.shouldLoadDataForFirstRun && [self.appDelegate checkIfAppOnline]) {
        [self setIsFirstRunLoadingViewHidden:NO animated:NO];
        self.navigationController.navigationBarHidden = YES;
    }
    
    else if (self.appDelegate.shouldLoadDataForFirstRun && ![self.appDelegate checkIfAppOnline]) {
        [self setIsCouldNotLoadDataViewHidden:NO fullscreen:YES];
        self.navigationController.navigationBarHidden = NO;
    }
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

-(void)triggerLoadLatestDataIfNecessary
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    NSTimeInterval updateTimer = -1.0f * (CGFloat)kDefaultNumberOfHoursBeforeTriggeringLatestUpdate * 60.0f * 60.f;
    
    NSDate* lastUpdate = [self.appDelegate.userDefaultsManager lastUpdateDateForCategoryId:[self currentCategoryId]];
    NSTimeInterval lastUpdateInSeconds = [lastUpdate timeIntervalSinceNow];
    
    if (lastUpdateInSeconds<updateTimer) {
        DBLog(@"triggering load latest data, lastUpdateInSeconds: %f // updateTimer: %f", lastUpdateInSeconds, updateTimer);
        [self loadLatestContent];
    }
    else {
        DBLog(@"not triggering load latest data, lastUpdateInSeconds: %f // updateTimer: %f", lastUpdateInSeconds, updateTimer);
    }
}

#pragma mark - UITableView delegate & datasource

//set up the height of the given cell, taken into account the "load more posts" cell 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ( [self isIndexPathLastRow:indexPath]  ) 
    {
        return 40.0f;
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
    static NSString *CellIdentifier = @"IgnantCell2";
    static NSString *CellIdentifierLoadMore = @"LoadMoreCell2";
    static NSString *CellIdentifierLoading = @"LoadingCell2";
    
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
        }
        
        return cell;
    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ( [self isIndexPathLastRow:indexPath] && !_isLoadingMoreContent  ) 
    {
        
    }
    
    else if([self isIndexPathLastRow:indexPath] && _isLoadingMoreContent)
    {
       
    }
    
    else
    {
        BlogEntry *blogEntry = (BlogEntry*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if (blogEntry==nil)
            return;
        
        IgnantCell *aCell = (IgnantCell *)cell;

        aCell.title = [blogEntry.title uppercaseString];
        aCell.categoryName = blogEntry.categoryName;
        
        if (blogEntry.publishingDate) {
            aCell.dateString = [self.articleCellDateFormatter stringFromDate:blogEntry.publishingDate];
        }
        
        NSString* currentArticleId = blogEntry.articleId;
        NSString *encodedString = [[NSString alloc] initWithFormat:@"%@?%@=%@&%@=%@",kAdressForImageServer,kArticleId,currentArticleId,kTLReturnImageType,kTLReturnCategoryImage];
        DBLog(@"imgurl: %@", encodedString);
        NSURL* urlAtCurrentIndex = [[NSURL alloc] initWithString:encodedString];
        __block NSURL* blockUrlAtCurrentIndex = urlAtCurrentIndex;
        [aCell.cellImageView setImageWithURL:urlAtCurrentIndex
                           placeholderImage:nil 
                                     success:^(UIImage* image){
                                         
                                     } 
                                     failure:^(NSError* error){
                                     
                                         DBLog(@"imageDidNotLoad: %@", blockUrlAtCurrentIndex);
                                     }];
    
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if ([self isIndexPathLastRow:indexPath]) 
    {
        if (!_isLoadingMoreContent) 
        {
            [self loadMoreContent];
            [self.blogEntriesTableView reloadData];
        }
        else
        {
            DBLog(@"trying to load more posts, will not trigger again");
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
        
        //deselect the row
        
        [self.blogEntriesTableView deselectRowAtIndexPath:indexPath animated:YES];
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
    NSArray *sortDescriptors = @[sortDescriptorForDate];
    
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
	    DBLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

- (void)fetch 
{
    NSError *error = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    NSAssert2(success, @"Unhandled error performing fetch at IGNMasterViewController.m, line %d: %@", __LINE__, [error localizedDescription]);
    [self.blogEntriesTableView reloadData];
}
 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.blogEntriesTableView reloadData];
}
 
- (void)configureCell:(IgnantCell *)cell atIndexPath:(NSIndexPath *)indexPath
{

}

-(BOOL)isIndexPathLastRow:(NSIndexPath*)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];    
    
    if(indexPath.row >= numberOfObjects && _showLoadMoreContent)
        return YES;
    
    return NO;
}

#pragma mark - getting content from the server
-(void)loadLatestContent
{
    if (_isLoadingLatestContent) return;        
    _isLoadingLatestContent = YES;
    
    NSString *categoryId = [self currentCategoryId];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetLatestArticlesForCategory,kParameterAction,categoryId,kCurrentCategoryId, [self currentPreferredLanguage], kParameterLanguage, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
    
    DBLog(@"MASTER LOAD LATEST CONTENT encodedString go: %@",encodedString);
    
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:encodedString]];
	[request setDelegate:self];
	[request startAsynchronous]; 
}

-(void)loadMoreContent
{
    if (_isLoadingMoreContent) return;        
    _isLoadingMoreContent = YES;
    
    _numberOfActiveRequests++;
    
    DBLog(@"loading more content");
    
    //this is done to update the "loading more cell"
#warning TODO: reload only load more cell
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.blogEntriesTableView reloadData];
    });
    
    NSDate* newImplementationDateForMost = [self.appDelegate.userDefaultsManager dateForLeastRecentArticleWithCategoryId:[self currentCategoryId]];
    
    NSNumber *secondsSince1970 = [NSNumber numberWithInteger:[newImplementationDateForMost timeIntervalSince1970]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetMoreArticlesForCategory,kParameterAction,[self currentCategoryId],kCurrentCategoryId, secondsSince1970, kDateOfOldestArticle, [self currentPreferredLanguage],kParameterLanguage, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
    
    DBLog(@"encodedString go: %@",encodedString);
    
    NSURL* reqUrl = [[NSURL alloc] initWithString:encodedString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:reqUrl];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSDate *lastUpdateDateForCurrentCategoryId = [self.appDelegate.userDefaultsManager lastUpdateDateForCategoryId:[self currentCategoryId]];
    
    if (_isLoadingMoreContent) {
        
        
        
    }
    
    else if (_isLoadingLatestContent) {
        
        if (lastUpdateDateForCurrentCategoryId==nil) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setIsLoadingViewHidden:NO];
            });
            
        }
        
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (_isLoadingMoreContent) {
    
        DBLog(@"is loading more content...");
        
        __block __typeof__(self) blockSelf = self;
        
        dispatch_queue_t importerDispatchQueue = dispatch_queue_create("com.ignant.importerDispatchQueue", NULL);
        dispatch_async(importerDispatchQueue, ^{
            
            NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] init];
            backgroundContext.persistentStoreCoordinator = blockSelf.managedObjectContext.persistentStoreCoordinator;
            
            IgnantImporter* newImporter = [[IgnantImporter alloc] init];
            newImporter.delegate = blockSelf;
            newImporter.persistentStoreCoordinator = blockSelf.managedObjectContext.persistentStoreCoordinator;
            
            DBLog(@"starting importingJSONWithMorePosts..., currentCategoryId: %@", [blockSelf currentCategoryId]);
            NSString* aCategoryId = [blockSelf currentCategoryId];
            [newImporter importJSONWithMorePosts:[request responseString] forCategoryId:aCategoryId];
        });
        dispatch_release(importerDispatchQueue);
        
        _numberOfActiveRequests--;
        _showLoadMoreContent = YES;
        _isLoadingMoreContent = NO;
        
    }
    else if (_isLoadingLatestContent) {
                
        DBLog(@"is loading latest content...");
        
        __block __typeof__(self) blockSelf = self;
        
        dispatch_queue_t importerDispatchQueue = dispatch_queue_create("com.ignant.importerDispatchQueue", NULL);
        dispatch_async(importerDispatchQueue, ^{
            
            NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] init];
            backgroundContext.persistentStoreCoordinator = blockSelf.managedObjectContext.persistentStoreCoordinator;
            
            IgnantImporter* newImporter = [[IgnantImporter alloc] init];
            newImporter.delegate = blockSelf;
            newImporter.persistentStoreCoordinator = blockSelf.managedObjectContext.persistentStoreCoordinator;
            
            DBLog(@"starting importJSONWithLatestPosts...");
            [newImporter importJSONWithLatestPosts:[request responseString] forCategoryId:[self currentCategoryId]];
        });
        dispatch_release(importerDispatchQueue);
        
        _isLoadingLatestContent = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.blogEntriesTableView];
    }
}

-(IgnantImporter*)importer
{
    if (_importer==nil) {
        _importer = [[IgnantImporter alloc] init];
        _importer.persistentStoreCoordinator = self.appDelegate.persistentStoreCoordinator;
        _importer.delegate = self;
    }
    
    return _importer;
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    DBLog(@"requestFailed");
    
    if (_isLoadingMoreContent) {    
        _numberOfActiveRequests--;
        _isLoadingMoreContent = NO;
        
        //this is done to update the "loading more cell"
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.blogEntriesTableView reloadData];
        });
    }
    
    else if (_isLoadingLatestContent) {
        if ([self.appDelegate.userDefaultsManager lastUpdateDateForCategoryId:[self currentCategoryId]]==nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setIsCouldNotLoadDataViewHidden:NO];
            });
        }
        
        _isLoadingLatestContent = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.blogEntriesTableView];
    }
}

#pragma mark - IgnantImporterDelegate

-(void)didStartImportingData
{
    DBLog(@"MasterVC didStartImportingData");
    
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
    __block __typeof__(self) blockSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [blockSelf.blogEntriesTableView reloadData];
        [blockSelf setIsLoadingViewHidden:YES];
        [blockSelf.appDelegate.userDefaultsManager setLastUpdateDate:[NSDate date] forCategoryId:[blockSelf currentCategoryId]];
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
    float reload_distance = -40.0f;
    
//    DBLog(@"y: %f  h: %f h + reload_distance: %f  \n lastContentOffset.y: %f  offset.y: %f", y, h, (h + reload_distance), lastContentOffset.y, offset.y);
    
    if(y > h + reload_distance) 
    {
        if (lastContentOffset.y < offset.y) //only trigger when scroll direction is DOWN
        if (!_isLoadingMoreContent && _numberOfActiveRequests==0) 
        {
            [self loadMoreContent];
        }
    }
    
    
    lastContentOffset = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - IgnantNoInternetConnectionViewDelegate
-(void)retryToLoadData
{
    DBLog(@"retryToLoadData");
    
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


-(UIView*)couldNotLoadDataView
{
    UIView* defaultView = [super couldNotLoadDataView];
        
    if (self.appDelegate.shouldLoadDataForFirstRun && [self.appDelegate checkIfAppOnline]) {
        self.couldNotLoadDataLabel.text = NSLocalizedString(@"could_not_load_data_server_error_first_run", @"Title for the couldNotLoadDataLabel when trying to load firstRun data, but not successful because of server error");
    }
    
    else if (self.appDelegate.shouldLoadDataForFirstRun && ![self.appDelegate checkIfAppOnline]) {
        self.couldNotLoadDataLabel.text = NSLocalizedString(@"could_not_load_data_no_internet_connection_first_run", @"Title for the couldNotLoadDataLabel when trying to load firstRun data, but not successful because of no internet connection");
    }
    
    else {
        self.couldNotLoadDataLabel.text = NSLocalizedString(@"could_not_load_data", @"Title for the couldNotLoadDataLabel when trying to load data, but not successful because of some error");
    }
    
    return defaultView;
}

@end
