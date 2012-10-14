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
#import "ContactViewController.h"
#import "IGNMasterViewController.h"
#import "FavouritesViewController.h"

#import "MoreCell.h"


typedef enum _moreOptionsIndeces  {
    indexForAboutIgnant = 0,
    indexForTumblrFeed = 1,
    indexForCategories = 2,
    indexForFavourites = 3,
    indexForReview = 4,
    indexForContact = 5

} moreOptionsIndeces;


@interface IGNMoreOptionsViewController()
{
    NSMutableArray *_listOfOptions;
    
}
-(void)setUpMoreOptions;
-(void)handleBack:(id)sender;

-(UIImage*)iconImageForRow:(int)row;

@end

#pragma mark - 

@implementation IGNMoreOptionsViewController
@synthesize moreOptionsTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSError* error = nil;
	GATrackPageView(&error, kGAPVMoreView);
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
    
    [_listOfOptions insertObject:NSLocalizedString(@"more_options_about_ignant", @"Title of 'About Ignant' cell on More VC") atIndex:indexForAboutIgnant];
    [_listOfOptions insertObject:NSLocalizedString(@"more_options_tumblr_feed", @"Title of 'Tublr' cell on More VC") atIndex:indexForTumblrFeed];
    [_listOfOptions insertObject:NSLocalizedString(@"more_options_categories", @"Title of 'Categories' cell on More VC") atIndex:indexForCategories];
    [_listOfOptions insertObject:NSLocalizedString(@"more_options_favorites", @"Title of 'Favorites' cell on More VC") atIndex:indexForFavourites];
    [_listOfOptions insertObject:NSLocalizedString(@"more_options_write_review", @"Title of 'Write Review' cell on More VC") atIndex:indexForReview];
    [_listOfOptions insertObject:NSLocalizedString(@"more_options_contact", @"Title of 'Contact' cell on More VC") atIndex:indexForContact];
}


#pragma mark - handle back navigation

-(void)handleBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpMoreOptions];
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:self.moreOptionsTableView.frame]; 
    UIColor* backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ign_background_part.jpg"]];
    backgroundView.backgroundColor = backgroundColor;
    [self.moreOptionsTableView setBackgroundView:backgroundView];
}

- (void)viewDidUnload
{
    [self setMoreOptionsTableView:nil];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* aTitle = [_listOfOptions objectAtIndex:indexPath.row];
    UIImage* aImage = [self iconImageForRow:indexPath.row];
    
    MoreCell* mCell = (MoreCell*)cell;
    [mCell configureWithTitle:aTitle 
                        image:aImage];
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listOfOptions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = [UIDevice isIphone5] ? kMoreCellHeightIphone5 : kMoreCellHeight;
    return height;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MoreOptionsCell";
    
    MoreCell *cell = (MoreCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    } 
    
    return cell;
}

-(void)showViewController:(UIViewController*)viewController
{
    NSArray* vcs = self.navigationController.viewControllers;
    BOOL isCategoriesVCOnStack = NO;
    for (id object in vcs) {
        if ([object isKindOfClass:[viewController class]]) {
            isCategoriesVCOnStack = YES;
            break;
        }
    }
    
    if (isCategoriesVCOnStack) {
        [self.navigationController popToViewController:viewController animated:YES];
    }
    else {
        [self.navigationController pushViewController:viewController animated:YES];                
    }    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AboutViewController *aboutVC = self.appDelegate.aboutViewController;
    IgnantTumblrFeedViewController *tumblrVC = self.appDelegate.tumblrFeedViewController;
    CategoriesViewController *categoriesVC = self.appDelegate.categoriesViewController;
    ContactViewController *contactVC = self.appDelegate.contactViewController;
    FavouritesViewController *favoritesVC = self.appDelegate.favouritesViewController;

    
    switch (indexPath.row) {
        case indexForAboutIgnant:
            [self.navigationController pushViewController:aboutVC animated:YES];
            break;
            
        case indexForTumblrFeed:
            tumblrVC.managedObjectContext = self.appDelegate.managedObjectContext;
            [self showViewController:tumblrVC];
            break;
            
        case indexForCategories:
            categoriesVC.managedObjectContext = self.appDelegate.managedObjectContext;
            [self showViewController:categoriesVC];
            break;
            
        case indexForFavourites:
            favoritesVC.managedObjectContext = self.appDelegate.managedObjectContext;
            [self showViewController:favoritesVC];
            break;
            
        case indexForReview:
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString:kAdressForItunesStore]];
            break;
            
        case indexForContact:
            [self.navigationController pushViewController:contactVC animated:YES];
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(UIImage*)iconImageForRow:(int)row
{
    UIImage* returnImage = nil;

    switch (row) {
        case indexForAboutIgnant:
            returnImage = [UIImage imageNamed:@"1"];
            break;
        case indexForTumblrFeed:
            returnImage = [UIImage imageNamed:@"2"];
            break;
        case indexForCategories:
            returnImage = [UIImage imageNamed:@"3"];
            break;
        case indexForContact:
            returnImage = [UIImage imageNamed:@"4"];
            break;
        case indexForReview:    
            returnImage = [UIImage imageNamed:@"5"];
            break;
        case indexForFavourites:    
            returnImage = [UIImage imageNamed:@"6"];
            break;
        default:
            break;
    }
    
    return returnImage;
}

@end
