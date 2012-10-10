//
//  ArticleDetailViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 11.10.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "ArticleDetailViewController.h"

@interface ArticleDetailViewController ()

@property(strong, nonatomic) ArticleDetailViewController* navigationArticleDetailViewController;

@end

@implementation ArticleDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleRightSwipe:(id)sender
{
    LOG_CURRENT_FUNCTION()
    
    [self navigateToPreviousArticle];
}

- (IBAction)handleLeftSwipe:(id)sender
{
    LOG_CURRENT_FUNCTION()
    
    [self navigateToNextArticle];
}

-(void)navigateToNextArticle
{
    //if previous blog entry invalid, just return
    if (self.nextBlogEntryIndex==kInvalidBlogEntryIndex)
        return;
    
    if (_navigationArticleDetailViewController==nil) {
        self.navigationArticleDetailViewController = [[ArticleDetailViewController alloc] initWithNibName:@"IGNDetailViewController_iPhone" bundle:nil];
    }
    
    self.navigationArticleDetailViewController.viewControllerToReturnTo = self.viewControllerToReturnTo;
    
    self.navigationArticleDetailViewController.fetchedResults = self.fetchedResults;
    self.navigationArticleDetailViewController.currentBlogEntryIndex = self.nextBlogEntryIndex;
    self.navigationArticleDetailViewController.isShowingArticleFromLocalDatabase = YES;
    
    if (self.nextBlogEntryIndex-1>=0) {
        self.navigationArticleDetailViewController.previousBlogEntryIndex = self.nextBlogEntryIndex-1;
    }
    else{
        self.navigationArticleDetailViewController.previousBlogEntryIndex = -1;
    }
    
    if(self.nextBlogEntryIndex+1<self.fetchedResults.count)
    {
        self.navigationArticleDetailViewController.nextBlogEntryIndex = self.nextBlogEntryIndex+1;
    }
    else{
        self.navigationArticleDetailViewController.nextBlogEntryIndex = -1;
    }
    
    self.navigationArticleDetailViewController.blogEntry = self.nextBlogEntry;
    
    self.navigationArticleDetailViewController.isNavigationBarAndToolbarHidden = self.isNavigationBarAndToolbarHidden;
	
    
    [self.navigationController pushViewController:self.navigationArticleDetailViewController animated:YES];
}

-(void)navigateToPreviousArticle
{
    //if previous blog entry invalid, just return
    if (self.previousBlogEntryIndex==kInvalidBlogEntryIndex)
        return;
    
    //navigate to previous article
    if (_navigationArticleDetailViewController==nil) {
        self.navigationArticleDetailViewController = [[ArticleDetailViewController alloc] initWithNibName:@"IGNDetailViewController_iPhone" bundle:nil];
    }
    
    self.navigationArticleDetailViewController.viewControllerToReturnTo = self.viewControllerToReturnTo;
    
    self.navigationArticleDetailViewController.fetchedResults = self.fetchedResults;
    self.navigationArticleDetailViewController.currentBlogEntryIndex = self.previousBlogEntryIndex;
    self.navigationArticleDetailViewController.isShowingArticleFromLocalDatabase = YES;
    
    if (self.currentBlogEntryIndex-1>=0) {
        self.navigationArticleDetailViewController.previousBlogEntryIndex = self.previousBlogEntryIndex-1;
    }
    else{
        self.navigationArticleDetailViewController.previousBlogEntryIndex = kInvalidBlogEntryIndex;
    }
    
    if(self.currentBlogEntryIndex<self.fetchedResults.count)
    {
        self.navigationArticleDetailViewController.nextBlogEntryIndex = self.currentBlogEntryIndex;
    }
    else{
        self.navigationArticleDetailViewController.nextBlogEntryIndex = kInvalidBlogEntryIndex;
    }
    
    self.navigationArticleDetailViewController.blogEntry = self.previousBlogEntry;
    self.navigationArticleDetailViewController.isNavigationBarAndToolbarHidden = self.isNavigationBarAndToolbarHidden;
    
    //push the view controller from left to right
    NSMutableArray *vcs =  [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [vcs insertObject:self.navigationArticleDetailViewController atIndex:[vcs count]-1];
    [self.navigationController setViewControllers:vcs animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)showRelatedArticle:(id)sender
{
    NSString *articleId = nil;
    
	NSError* error = nil;
	GATrackEvent(&error, @"IGNDetailViewController", @"showRelated", self.currentArticleId, 10);
	
	    
    if ([sender tag] == kFirstRelatedArticleTag)
    {
        articleId = [[NSString alloc] initWithString:self.firstRelatedArticleId];
    }
    
    else if ([sender tag] == kSecondRelatedArticleTag)
    {
        articleId = [[NSString alloc] initWithString:self.secondRelatedArticleId];
    }
    
    else if ([sender tag] == kThirdRelatedArticleTag)
    {
        articleId = [[NSString alloc] initWithString:self.thirdRelatedArticleId];
    }
    
    //tag is falsly set
    else
    {
        DBLog(@"tag is falsly set, doing nothing");
        return;
    }
        
    BlogEntry* entry = nil;
    entry = [self.importer blogEntryWithId:articleId];
    BOOL shouldLoadBlogEntryFromRemoteServer = (entry == nil);
    
    //check for the internet connection
    if(shouldLoadBlogEntryFromRemoteServer && ![self.appDelegate checkIfAppOnline])
    {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@""
                                                     message:NSLocalizedString(@"ui_alert_message_you_need_an_internet_connection",nil)
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"ui_alert_dismiss",nil)
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    
    //blog entry to be shown is set, show the view controller loading the article data
    if (!self.nextArticleDetailViewController) {
        self.nextArticleDetailViewController = [[ArticleDetailViewController alloc] initWithNibName:@"IGNDetailViewController_iPhone" bundle:nil];
    }
    
    self.nextArticleDetailViewController.viewControllerToReturnTo = self.viewControllerToReturnTo;
	
    if(entry)
    {
        self.nextArticleDetailViewController.blogEntry = entry;
        self.nextArticleDetailViewController.isShowingArticleFromLocalDatabase = YES;
    }
    
    else
    {
        self.nextArticleDetailViewController.currentArticleId = articleId;
        self.nextArticleDetailViewController.didLoadContentForRemoteArticle = NO;
        self.nextArticleDetailViewController.isShowingArticleFromLocalDatabase = NO;
    }
    
    //reset the indexes
    self.nextArticleDetailViewController.nextBlogEntryIndex = kInvalidBlogEntryIndex;
    self.nextArticleDetailViewController.previousBlogEntryIndex = kInvalidBlogEntryIndex;
    
    //set the managedObjectContext and push the view controller
    self.nextArticleDetailViewController.managedObjectContext = self.managedObjectContext;
    self.nextArticleDetailViewController.isNavigationBarAndToolbarHidden = self.isNavigationBarAndToolbarHidden;
    [self.navigationController pushViewController:self.nextArticleDetailViewController animated:YES];
}

@end
