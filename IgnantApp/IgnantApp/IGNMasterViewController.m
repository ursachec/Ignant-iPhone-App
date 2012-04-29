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
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    
    
    CGFloat _rotatingAngle;
    BOOL _animate;
    
    BOOL _showLoadMorePosts;
    
    BOOL _loadingMorePosts;
    
    
    BOOL _tempNumberOfTimesLoadedMorePosts;
    
}
-(BOOL)isIndexPathLastRow:(NSIndexPath*)indexPath;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)startGettingMorePosts;

@property (nonatomic, strong) HJObjManager *hjObjectManager;
@property (nonatomic, retain) UIView *spinningLoadingView;
@property (nonatomic, retain) UIImageView *spinningImageView;

@property (nonatomic, retain) IgnantImporter *importer;

@property (assign, readwrite) BOOL isHomeCategory;


@property (retain, nonatomic, readwrite) Category* currentCategory;

@end

#pragma mark -

@implementation IGNMasterViewController

@synthesize blogEntriesTableView = _blogEntriesTableView;
@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize hjObjectManager = _hjObjectManager;

@synthesize spinningLoadingView = _spinningLoadingView;
@synthesize spinningImageView = _spinningImageView;

@synthesize importer = _importer;

@synthesize isHomeCategory = _isHomeCategory;

@synthesize currentCategory = _currentCategory;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil category:(Category*)category
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _showLoadMorePosts = YES;
        _loadingMorePosts = NO;
        
        
        self.currentCategory = category;
        self.isHomeCategory = (category==nil) ? TRUE : FALSE;
        
        
#warning just temp, delete afterwards
        _tempNumberOfTimesLoadedMorePosts = 0;
        
        
        //use the importer from the appDelegate
        
        IGNAppDelegate *appDelegate = (IGNAppDelegate*)[[UIApplication sharedApplication] delegate];        
        _importer = [[IgnantImporter alloc] init];
        _importer.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
        _importer.delegate = self;
    
        
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - show mosaik / more
- (IBAction)showMosaik:(id)sender {
    
    IGNMosaikViewController *mosaikVC = [[IGNMosaikViewController alloc] initWithNibName:@"IGNMosaikViewController" bundle:nil];
    mosaikVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentModalViewController:mosaikVC animated:YES];
    [mosaikVC release];

}

- (IBAction)showMore:(id)sender {
        
    IGNMoreOptionsViewController *moreOptionsVC = [[IGNMoreOptionsViewController alloc] initWithNibName:@"IGNMoreOptionsViewController" bundle:nil];
    [self.navigationController pushViewController:moreOptionsVC animated:YES];
    [moreOptionsVC release];
}

- (IBAction)showTumblr:(id)sender {
    
    IgnantTumblrFeedViewController *tumblrVC = [[IgnantTumblrFeedViewController alloc] initWithNibName:@"IgnantTumblrFeedViewController" bundle:nil];
    [self.navigationController pushViewController:tumblrVC animated:YES];
    [tumblrVC release];
    

}

#pragma mark - spinning animation
-(void)startAnimation
{
    NSLog(@"startAnimation");
}


#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
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
    
    
    //adding spinning lloading view
//    _spinningLoadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
//    _spinningLoadingView.backgroundColor = [UIColor whiteColor];
//    
//    UIButton *someButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [someButton addTarget:self action:@selector(startAnimation) forControlEvents:UIControlEventTouchDown];
//    someButton.frame = CGRectMake(50, 50, 100, 100);
//    [_spinningLoadingView addSubview:someButton];
//    
//    
//    _spinningImageView = [[UIImageView alloc] initWithFrame:CGRectMake(85, 150, 150, 150)];
//    _spinningImageView.image = [UIImage imageNamed:@"Icon"];
//    [_spinningLoadingView addSubview:_spinningImageView];
//
//    
//    [self.navigationController.view addSubview:_spinningLoadingView];
//    [self.navigationController.view bringSubviewToFront:_spinningLoadingView];
    
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
        return 107.0f;
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
    return [sectionInfo numberOfObjects] + _showLoadMorePosts;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"IgnantCell";
    static NSString *CellIdentifierLoadMore = @"LoadMoreCell";
    static NSString *CellIdentifierLoading = @"LoadingCell";
    
    
    if ( [self isIndexPathLastRow:indexPath] && !_loadingMorePosts  ) 
    {
        
        IgnantLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierLoadMore];
        if (cell == nil) {
            cell = [[[IgnantLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLoadMore] autorelease];
            
        }
        
        
        return cell;
        
    }
    else if([self isIndexPathLastRow:indexPath] && _loadingMorePosts)
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




////////////////////////////////////////////////////////////
//managing cells with asynchronous images

//
//// Customize the appearance of table view cells.
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    
//    HJManagedImageV* mi;
//    IgnantCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[IgnantCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//        
//        //Create a managed image view and add it to the cell (layout is very naieve)
//        
//
//        CGFloat ratio = 375.0f/245.0f;
//        CGFloat width = 147.0f;
//        
//		mi = [[[HJManagedImageV alloc] initWithFrame:CGRectMake(5.0f,0.0f,width,width/ratio)] autorelease];
//        mi.tag = 999;
//		[cell addSubview:mi];
//        
//        cell.managedImage = mi;
//        
//    } else {
//		//Get a reference to the managed image view that was already in the recycled cell, and clear it
//		mi = (HJManagedImageV*)[cell viewWithTag:999];
//		[mi clear];
//	}
//    
//    
//    BlogEntry *blogEntry = (BlogEntry*)[self.fetchedResultsController objectAtIndexPath:indexPath];
//    
//    
//    //set the URL that we want the managed image view to load
////	mi.url = [NSURL URLWithString:[FlickrSearchRes image75pxUrl:searchRes]];
//
//#ifdef DEBUG
//#warning REMOVE THIS BEFORE RELEASE
//    NSArray *tempImageArray = [[NSArray alloc] initWithObjects:@"http://www.ignant.de/wp-content/uploads/2012/01/Of-Ar_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2012/01/Agnespre2.jpg",@"http://www.ignant.de/wp-content/uploads/2012/01/toledano_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2012/01/sang-pre.jpg",@"http://www.ignant.de/wp-content/uploads/2012/01/more-light_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2012/01/allandale_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2012/01/nova_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2012/01/Guy_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2012/01/hake_hol_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2012/01/Julien-Legrand_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2012/01/temp_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2012/01/gravinese_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2012/01/haus_w_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2012/01/jooney_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2012/01/timmelsjoch_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2011/12/prepre.jpg",@"http://www.ignant.de/wp-content/uploads/2011/12/soustitre_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2011/12/major_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2011/12/lis_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2011/12/landscape_pre.jpg",@"http://www.ignant.de/wp-content/uploads/2011/03/dmig.jpg",@"http://www.ignant.de/wp-content/uploads/2011/03/arcedemi.jpg",@"http://www.ignant.de/wp-content/uploads/2011/08/SHOP-klein.jpg", nil];
//
//    mi.url = [NSURL URLWithString:[tempImageArray objectAtIndex:indexPath.row]];
//#else
//    mi.url = [NSURL URLWithString:blogEntry.thumbImageFilename];
//#endif
//    
//    
//    
//	//tell the object manager to manage the managed image view, 
//	//this causes the cached image to display, or the image to be loaded, cached, and displayed
//	[_hjObjectManager manage:mi];
//    
//
//    [self configureCell:cell atIndexPath:indexPath];
//    return cell;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if ([self isIndexPathLastRow:indexPath]) 
    {
        if (!_loadingMorePosts) 
        {
            [self startGettingMorePosts];       
            _loadingMorePosts = YES;
            
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
            self.detailViewController.previousBlogEntryIndex = -1;
        }
        
        if(indexPath.row+1<fetchedResultsArray.count)
        {
            self.detailViewController.nextBlogEntryIndex = indexPath.row+1;
        }
        else{
            self.detailViewController.nextBlogEntryIndex = -1;
        }
        
        //set the managedObjectContext and push the view controller
        self.detailViewController.managedObjectContext = self.managedObjectContext;
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

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.blogEntriesTableView beginUpdates];
//    
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
//{
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.blogEntriesTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.blogEntriesTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath
//{
//    UITableView *tableView = self.blogEntriesTableView;
//    
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.blogEntriesTableView endUpdates];
//}


// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
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

#pragma mark -
-(BOOL)isIndexPathLastRow:(NSIndexPath*)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
    
    
    if(indexPath.row >= numberOfObjects && _showLoadMorePosts)
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - getting content from the server
-(void)startGettingMorePosts
{
    NSDate* lastImportDateForMainPageArticle = (NSDate*) [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsLastImportDateForMainPageArticle];
    
    NSLog(@"lastImportDateForMainPageArticle: %@", lastImportDateForMainPageArticle);
    
    NSNumber *secondsSince1970 = [NSNumber numberWithInteger:[lastImportDateForMainPageArticle timeIntervalSince1970]];
    
    // Test default delegate methods
    
    //set the relevant categoryId
    NSString *categoryId = @"";
    
    if (self.isHomeCategory) 
    {
        categoryId = @"-1";
    }
    else 
    {
        categoryId = [self.currentCategory categoryId];
    }
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetMorePosts,kParameterAction,categoryId,kCategoryId, secondsSince1970, kDateOfOldestArticle, nil];
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
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    _showLoadMorePosts = YES;
    _loadingMorePosts = NO;
    
    [self.importer importJSONStringWithMorePosts:[request responseString]];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"requestFailed");
}


#pragma mark - IgnantImporterDelegate

-(void)didStartImportingRSSData
{
    NSLog(@"MasterVC didStartImportingRSSData");
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        [self showLoadingViewAnimated:YES];
//    
//    });
}

-(void)didFinishImportingRSSData
{
//    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetch];
        [self.blogEntriesTableView reloadData];
//    });
}

- (void)importerDidSave:(NSNotification *)saveNotification {
    IGNAppDelegate *appDelegate = (IGNAppDelegate*)[[UIApplication sharedApplication] delegate];  
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
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


@end
