//
//  FavouritesViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 01.07.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "FavouritesViewController.h"
#import "IgnantImporter.h"
#import "IGNAppDelegate.h"

@interface FavouritesViewController ()

@property (nonatomic, strong, readwrite) IgnantImporter *importer;
@property (nonatomic, strong, readwrite) UIView* noFavouritesView;
@property (assign, readwrite) BOOL isHomeCategory;

@end


@implementation FavouritesViewController
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize isHomeCategory = _isHomeCategory;
@synthesize importer = _importer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isHomeCategory = NO;
    }
    return self;
}

-(UIView*)noFavouritesView
{
    if (_noFavouritesView==nil) {
        
        UIView* aView = [[UIView alloc] initWithFrame:self.blogEntriesTableView.frame];
        aView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5f];
        
        UILabel *aLabel = [[UILabel alloc] initWithFrame:aView.frame];
        aLabel.text = NSLocalizedString(@"info_no_favorites", @"text shown when no favorites set");
        aLabel.numberOfLines = 4;
        aLabel.font = [UIFont fontWithName:@"Georgia" size:11.0f];
        aLabel.textAlignment = UITextAlignmentCenter;
        [aView addSubview:aLabel];
        
        _noFavouritesView = aView;
    }
    
    return _noFavouritesView;
}

-(void)createImporter
{
    //use the importer from the appDelegate
    IGNAppDelegate *appDelegate = (IGNAppDelegate*)[[UIApplication sharedApplication] delegate];        
    _importer = [[IgnantImporter alloc] init];
    _importer.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
    _importer.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [_refreshHeaderView removeFromSuperview];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    self.fetchedResultsController = nil;
    [self fetch];
    
    int section = 0;
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    NSInteger numberOfFavourites = [sectionInfo numberOfObjects];
    
    if (numberOfFavourites<1) {
        [self.view addSubview:self.noFavouritesView];
    }
    else{
        [self.noFavouritesView removeFromSuperview];
    }
    
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSError* error = nil;
	GATrackPageView(&error, kGAPVFavoritesView);
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -

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
    NSSortDescriptor *sortDescriptorForNumberOfViews = [[NSSortDescriptor alloc] initWithKey:@"numberOfViews" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptorForNumberOfViews];
    
    [fetchRequest setSortDescriptors:sortDescriptors];

    //create the predicates
    NSMutableArray* predicates = [[NSMutableArray alloc] initWithCapacity:1];
    
    
    //get the current favourites
    NSMutableArray* currentFavourites = self.appDelegate.userDefaultsManager.currentFavouriteBlogEntries;
    for (NSString* articleId in currentFavourites) {
        DBLog(@"articleId: %@", articleId);
        NSPredicate *p = [NSPredicate predicateWithFormat:@"articleId == %@", articleId];
        [predicates addObject:p];
    }
    
    //create the compound predicate
    NSPredicate *compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    [fetchRequest setPredicate:compoundPredicate];
    
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


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
}

@end
