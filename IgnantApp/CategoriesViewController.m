//
//  CategoriesViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 04.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "CategoriesViewController.h"

#import "IGNMasterViewController.h"

#import "IGNAppDelegate.h"

#import "Category.h"

@interface CategoriesViewController()

@property (strong, nonatomic, readwrite) UIView* gradientView;

@end

@implementation CategoriesViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize categoriesTableView = _categoriesTableView;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize fetchedResultsController = __fetchedResultsController;

@synthesize gradientView = _gradientView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:self.categoriesTableView.frame]; 
    UIColor* backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ign_background_part.jpg"]];
    backgroundView.backgroundColor = backgroundColor;
    [self.categoriesTableView setBackgroundView:backgroundView];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.categoriesTableView addSubview:self.gradientView];
}

- (void)viewDidUnload
{
    [self setCategoriesTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView delegate & datasource

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    int numberOfObjects = [sectionInfo numberOfObjects];
    
    return numberOfObjects;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    } 
    
    //configure the cell
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    Category *category = (Category*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    IGNMasterViewController *categoryVC = self.appDelegate.categoryViewController;
    categoryVC.managedObjectContext = self.appDelegate.managedObjectContext;
    [categoryVC forceSetCurrentCategory:category];
    [self.navigationController pushViewController:categoryVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //add a custom background view
    UIView *customBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    customBackgroundView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    cell.backgroundView = customBackgroundView;
    
    //add a custom selected background view
    UIView *customSelectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    customSelectedBackgroundView.backgroundColor = [UIColor colorWithRed:.0f green:.0f blue:.0f alpha:.5f];
    cell.selectedBackgroundView = customSelectedBackgroundView;
    
    
    Category *category = (Category*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = category.name;
    cell.textLabel.font = [UIFont fontWithName:@"Georgia" size:13.0f];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptorForDate = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    //    NSSortDescriptor *sortDescriptorForTitle = [[[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorForDate, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
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
    [self.categoriesTableView reloadData];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.categoriesTableView reloadData];
}

#pragma mark - custom views
-(UIView*)gradientView
{
    if (_gradientView==nil) {
        CGSize gradientSize = CGSizeMake(320.0f, 4.f);
        _gradientView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, gradientSize.width, gradientSize.height)];
        _gradientView.backgroundColor = [UIColor clearColor];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = _gradientView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:223.0f/255.0f green:223.0f/255.0f blue:223.0f/255.0f alpha:.5f] CGColor], (id)[[UIColor colorWithRed:223.0f/255.0f green:223.0f/255.0f blue:223.0f/255.0f alpha:0.f] CGColor], nil];
        [_gradientView.layer insertSublayer:gradient atIndex:0];
        
    }
    
    return _gradientView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	    
    //move the gradient view
    CGRect tableBounds = self.categoriesTableView.bounds; // gets content offset
    CGRect frameForStillView = self.gradientView.frame; 
    frameForStillView.origin.y = tableBounds.origin.y; // offsets the rects y origin by the content offset
    self.gradientView.frame = frameForStillView; // set the frame to the new calculation
}

@end
