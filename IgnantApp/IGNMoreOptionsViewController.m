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
#import "IGNMasterViewController.h"


#import "IGNAppDelegate.h"

//temp icon for categories tempMoreCategoryIcon.png (in mainBundle)


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

-(UIImage*)iconImageForRow:(int)row;

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
    
#warning TAKE THE CATEGORIES FROM DATABASE ????
#warning localize strings
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
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpMoreOptions];
    
    //add the back-to-start button
//    UIImage *backButtonImage = [UIImage imageNamed:@"navigationButtonStart"];
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    CGFloat ratio = .5;
//    backButton.frame = CGRectMake(0, 0, 122*ratio, 57*ratio);
//    [backButton setImage:backButtonImage forState:UIControlStateNormal];
//    [backButton setImage:backButtonImage forState:UIControlStateHighlighted];
//    [backButton addTarget:self action:@selector(handleBack:) forControlEvents:UIControlEventTouchDown];
//    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self configureCell:cell atIndexPath:indexPath];

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

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    } 
    
    UIView *customBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    customBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    cell.selectedBackgroundView = customBackgroundView;
    
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
    
    AboutViewController *aboutVC = appDelegate.aboutViewController;
    IgnantTumblrFeedViewController *tumblrVC = appDelegate.tumblrFeedViewController;
    CategoriesViewController *categoriesVC = appDelegate.categoriesViewController;
    MostViewedViewController *mostViewedVC = appDelegate.mostViewedViewController;
    ContactViewController *contactVC = appDelegate.contactViewController;
    
    switch (indexPath.row) {
        case indexForAboutIgnant:
            [self.navigationController pushViewController:aboutVC animated:YES];
            break;
            
        case indexForTumblrFeed:
            tumblrVC.managedObjectContext = appDelegate.managedObjectContext;
            [self showViewController:tumblrVC];
            break;
            
        case indexForCategories:
            categoriesVC.managedObjectContext = appDelegate.managedObjectContext;
            [self showViewController:categoriesVC];
            break;
            
        case indexForMostRed:            
            mostViewedVC.managedObjectContext = appDelegate.managedObjectContext;
            [self.navigationController pushViewController:mostViewedVC animated:YES];
            break;
            
        case indexForContact:
            [self.navigationController pushViewController:contactVC animated:YES];
            break;
            
        default:
            break;
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
#define DEBUG_SHOW_HELP_COLORS FALSE
    
    CGSize imageSize = CGSizeMake(22.0f, 25.0f);
    CGFloat verticalMiddle = (cell.contentView.frame.size.height-imageSize.height)/2;
    CGFloat paddingLeft = 10.0f;
    
    //add the image icon to the category cell
    CGRect imageFrame = CGRectMake(paddingLeft, verticalMiddle, imageSize.width, imageSize.height);
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:imageFrame];
    imageView.image = [self iconImageForRow:indexPath.row];
    
#if DEBUG_SHOW_HELP_COLORS
    imageView.backgroundColor = [UIColor redColor];
#endif    
    
    [cell.contentView addSubview:imageView];
    
    
    //add the title label to the category cell
    CGFloat paddingLeftFromImageIcon = 10.0f;
    CGSize labelSize = CGSizeMake(cell.contentView.frame.size.width-imageFrame.origin.x-imageFrame.size.width-paddingLeftFromImageIcon, cell.contentView.frame.size.height);
    CGRect labelFrame = CGRectMake(imageFrame.origin.x+imageFrame.size.width+paddingLeftFromImageIcon, 0.0f , labelSize.width, labelSize.height);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
    titleLabel.font = [UIFont fontWithName:@"Georgia" size:15.0f];
    
#if DEBUG_SHOW_HELP_COLORS
    titleLabel.backgroundColor = [UIColor greenColor];
#endif
    
    titleLabel.text = [_listOfOptions objectAtIndex:indexPath.row];
    [cell.contentView addSubview:titleLabel];
    
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
        case indexForMostRed:
            returnImage = [UIImage imageNamed:@"5"];
            break;    
            
        default:
            break;
    }
    
    return returnImage;
}


@end
