//
//  MostViewedViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 04.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "MostViewedViewController.h"
#import "IgnantImporter.h"


#import "Constants.h"

@interface MostViewedViewController()

@property (assign, readwrite) BOOL isHomeCategory;

@end

@implementation MostViewedViewController
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize isHomeCategory = _isHomeCategory;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil category:nil];
    if (self) {
        // Custom initialization
        
        self.isHomeCategory = NO;        
        
        self.title = @"Am meisten gelesen";
        
        self.importer = nil;
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


-(NSString*)currentCategoryId
{
    NSString* categoryId = [NSString stringWithFormat:@"%d",kCategoryIndexForMosaik];
    return categoryId;
}

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UILabel *someLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150.0f, 40.0f)];
#warning TODO: localize text
    someLabel.text = [@"Am meisten gelesen" uppercaseString];
    someLabel.textAlignment = UITextAlignmentCenter;
    someLabel.font = [UIFont fontWithName:@"Georgia" size:10.0f];
    self.navigationItem.titleView = someLabel;
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
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BlogEntry" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptorForNumberOfViews = [[NSSortDescriptor alloc] initWithKey:@"numberOfViews" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorForNumberOfViews, nil];
    
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
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}  




@end
