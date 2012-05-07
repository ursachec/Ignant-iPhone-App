//
//  MostViewedViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 04.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "MostViewedViewController.h"
#import "IgnantImporter.h"
#import "IGNAppDelegate.h"

@interface MostViewedViewController()

@property (nonatomic, retain, readwrite) IgnantImporter *importer;
@property (assign, readwrite) BOOL isHomeCategory;

@end

@implementation MostViewedViewController
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize isHomeCategory = _isHomeCategory;
@synthesize importer = _importer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil category:nil];
    if (self) {
        // Custom initialization
        
        self.isHomeCategory = NO;        
        
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)createImporter
{
    //use the importer from the appDelegate
    IGNAppDelegate *appDelegate = (IGNAppDelegate*)[[UIApplication sharedApplication] delegate];        
    _importer = [[IgnantImporter alloc] init];
    _importer.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
    _importer.delegate = self;
}

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    
    
    UILabel *someLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150.0f, 40.0f)];
    someLabel.text = @"Am meisten gelesen";
    someLabel.textAlignment = UITextAlignmentCenter;
    someLabel.font = [UIFont fontWithName:@"Georgia" size:14.0f];
    self.navigationItem.titleView = someLabel;
    [someLabel release];
    

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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

#pragma mark -

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
    NSSortDescriptor *sortDescriptorForNumberOfViews = [[[NSSortDescriptor alloc] initWithKey:@"numberOfViews" ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorForNumberOfViews, nil];
    
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




@end
