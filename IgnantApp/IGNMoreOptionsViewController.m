//
//  IGNMoreOptionsViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 03.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "IGNMoreOptionsViewController.h"


#import "AboutViewController.h"
#import "IgnantTumblrFeedViewController.h"
#import "CategoriesViewController.h"
#import "MostViewedViewController.h"
#import "SearchViewController.h"
#import "ContactViewController.h"

#import "IGNAppDelegate.h"

typedef enum _moreOptionsIndeces  {
    indexForAboutIgnant = 0,
    indexForTumblrFeed = 1,
    indexForCategories = 2,
    indexForMostRed = 3,
//    indexForSearch = 2,
    indexForContact = 4,
} moreOptionsIndeces;


@interface IGNMoreOptionsViewController()
{
    NSMutableArray *_listOfOptions;
    
    IGNAppDelegate* appDelegate;
}
-(void)setUpMoreOptions;
-(void)handleBack:(id)sender;
@end

#pragma mark - 

@implementation IGNMoreOptionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
        appDelegate = (IGNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - set up content
-(void)setUpMoreOptions
{
    _listOfOptions = [[NSMutableArray alloc] initWithCapacity:12];
    
    [_listOfOptions insertObject:@"About Ignant" atIndex:indexForAboutIgnant];
    [_listOfOptions insertObject:@"Tumblr Feed" atIndex:indexForTumblrFeed];
    [_listOfOptions insertObject:@"Kategorien" atIndex:indexForCategories];
    [_listOfOptions insertObject:@"Am meisten gelesen" atIndex:indexForMostRed];
//    [_listOfOptions insertObject:@"Suche" atIndex:indexForSearch];
    [_listOfOptions insertObject:@"Kontakt" atIndex:indexForContact];
}


#pragma mark - handle back navigation

-(void)handleBack:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpMoreOptions];
    
    //add the back-to-start button
    UIImage *backButtonImage = [UIImage imageNamed:@"navigationButtonStart.png"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat ratio = .5;
    backButton.frame = CGRectMake(0, 0, 122*ratio, 57*ratio);
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(handleBack:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
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

#pragma mark - UITableView delegate & datasource

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listOfOptions.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    } 
    
    
    UIView *customBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    customBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    cell.selectedBackgroundView = customBackgroundView;
//    [customBackgroundView release];
    
    
    
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");

    
    
    
    switch (indexPath.row) {
        case indexForAboutIgnant:
            
            NSLog(@"something");
            
            AboutViewController *aboutVC = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
            [self.navigationController pushViewController:aboutVC animated:YES];
            [aboutVC release];
            
            break;
        case indexForTumblrFeed:
            
            NSLog(@"something");
            
            IgnantTumblrFeedViewController *tumblrVC = [[IgnantTumblrFeedViewController alloc] initWithNibName:@"IgnantTumblrFeedViewController" bundle:nil];
            [self.navigationController pushViewController:tumblrVC animated:YES];
            [tumblrVC release];
            
            break;
        case indexForCategories:
            
            NSLog(@"something");
            
            
//            managedObjectContext
            CategoriesViewController *categoriesVC = [[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController" bundle:nil];
            
            categoriesVC.managedObjectContext = appDelegate.managedObjectContext;
            [self.navigationController pushViewController:categoriesVC animated:YES];
            [categoriesVC release];
            
            break;
        case indexForMostRed:
            
            NSLog(@"something");
            
            MostViewedViewController *mostViewedVC = [[MostViewedViewController alloc] initWithNibName:@"MostViewedViewController" bundle:nil];
            [self.navigationController pushViewController:mostViewedVC animated:YES];
            [mostViewedVC release];
            
            break;
//        case indexForSearch:
//            
//            NSLog(@"something");
//            
//            SearchViewController *searchVC = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
//            [self.navigationController pushViewController:searchVC animated:YES];
//            [searchVC release];
//            
//            break;
        case indexForContact:
            
            NSLog(@"something");
            
            ContactViewController *contactVC = [[ContactViewController alloc] initWithNibName:@"ContactViewController" bundle:nil];
            [self.navigationController pushViewController:contactVC animated:YES];
            [contactVC release];
            
            break;
            
        default:
            break;
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [_listOfOptions objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Georgia" size:15];
}


@end
