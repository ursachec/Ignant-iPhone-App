//
//  IGNDetailViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import "IGNDetailViewController.h"

#import "Constants.h"

#import "BlogEntry.h"

#import "ImageSlideshowViewController.h"
#import "IGNMoreOptionsViewController.h"

#import "IgnantLoadingView.h"

#import "NSString+HTML.h"
#import "NSData+Base64.h"

//imports for ASIHTTPRequest
#import "ASIHTTPRequest.h"
#import "NSURL+stringforurl.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <MediaPlayer/MediaPlayer.h>

@interface IGNDetailViewController ()
{
    BOOL _isLoadingCurrentArticle;
 
    CGFloat lastHeightForWebView;
}

-(void)setupArticleContentViewWithRemoteDataDictionary:(NSDictionary*)articleDictionary;

-(void)setupNavigationEntries;

-(void)setupUIElementsForCurrentBlogEntryTemplate;

- (IBAction)showMercedes:(id)sender;

//social media
-(void)postToFacebook;
-(void)postToPinterest;
-(void)postToTwitter;

@property (strong, nonatomic) NSString *firstRelatedArticleId;
@property (strong, nonatomic) NSString *secondRelatedArticleId;
@property (strong, nonatomic) NSString *thirdRelatedArticleId;

//properties for navigating through remote articles
@property (strong, nonatomic) NSArray *relatedArticlesIds;

//article UI stugg
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UIButton *showPictureSlideshowButton;
@property (strong, nonatomic) IBOutlet UIButton *playVideoButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIWebView *descriptionWebView;
@property (strong, nonatomic) IBOutlet UIView *descriptionWebViewLoadingView;

@property (strong, nonatomic) IBOutlet UIImageView *entryImageView;

//properties related to the navigation
@property (strong, nonatomic) BlogEntry* nextBlogEntry;
@property (strong, nonatomic) BlogEntry* previousBlogEntry;

@property(strong, nonatomic) IGNDetailViewController* navigationDetailViewController;
@property(strong, nonatomic) UIButton *previousArticleButton;
@property(strong, nonatomic) UIButton *nextArticleButton;

@property(strong, nonatomic)NSArray *remoteImagesArray;

//cluster views
@property (strong, nonatomic) IBOutlet UIView *articleContentView;
@property (strong, nonatomic) IBOutlet UIView *relatedArticlesView;

@property(strong, nonatomic, readwrite) UILabel* couldNotLoadDataLabel;


@property (nonatomic, strong, readwrite) NSDateFormatter *articlesDateFormatter;

-(void)configureView;
-(void)setupNavigationButtons;

- (IBAction)showPictureSlideshow:(id)sender;

-(void)startLoadingSingleArticle;

-(void)setNavigationBarAndToolbarHidden:(BOOL)hidden animated:(BOOL)animated;

@end

#pragma mark - 

@implementation IGNDetailViewController

@synthesize firstRelatedArticleId = _firstRelatedArticleId;
@synthesize secondRelatedArticleId = _secondRelatedArticleId;
@synthesize thirdRelatedArticleId = _thirdRelatedArticleId;

@synthesize didLoadContentForRemoteArticle = _didLoadContentForRemoteArticle;

@synthesize currentArticleId, relatedArticlesIds;

@synthesize isShowingArticleFromLocalDatabase = _isShowingArticleFromLocalDatabase;

@synthesize shareAndMoreToolbar = _shareAndMoreToolbar;
@synthesize articleContentView = _articleContentView;
@synthesize relatedArticlesView = _relatedArticlesView;

@synthesize previousArticleButton = _previousArticleButton;
@synthesize nextArticleButton = _nextArticleButton;

@synthesize dateLabel = _dateLabel;
@synthesize categoryLabel = _categoryLabel;

@synthesize showPictureSlideshowButton = _showPictureSlideshowButton;
@synthesize playVideoButton = _playVideoButton;
@synthesize titleLabel = _titleLabel;

@synthesize descriptionWebView = _descriptionWebView;
@synthesize descriptionWebViewLoadingView = _descriptionWebViewLoadingView;
@synthesize entryImageView = _entryImageView;

@synthesize blogEntry = _blogEntry;
@synthesize nextBlogEntry = _nextBlogEntry;
@synthesize previousBlogEntry = _previousBlogEntry;

@synthesize remoteImagesArray = _remoteImagesArray;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize contentScrollView = _contentScrollView;

@synthesize navigationDetailViewController = _navigationDetailViewController;

@synthesize fetchedResults = _fetchedResults;
@synthesize firstRelatedArticleImageView = _firstRelatedArticleImageView;
@synthesize secondRelatedArticleImageView = _secondRelatedArticleImageView;
@synthesize thirdRelatedArticleImageView = _thirdRelatedArticleImageView;
@synthesize firstRelatedArticleTitleLabel = _firstRelatedArticleTitleLabel;
@synthesize secondRelatedArticleTitleLabel = _secondRelatedArticleTitleLabel;
@synthesize thirdRelatedArticleTitleLabel = _thirdRelatedArticleTitleLabel;
@synthesize thirdRelatedArticleCategoryLabel = _thirdRelatedArticleCategoryLabel;
@synthesize firstRelatedArticleCategoryLabel = _firstRelatedArticleCategoryLabel;
@synthesize secondRelatedArticleCategoryLabel = _secondRelatedArticleCategoryLabel;
@synthesize firstRelatedArticleShowDetailsButton = _firstRelatedArticleShowDetailsButton;
@synthesize secondRelatedArticleShowDetailsButton = _secondRelatedArticleShowDetailsButton;
@synthesize thirdRelatedArticleShowDetailsButton = _thirdRelatedArticleShowDetailsButton;

@synthesize currentBlogEntryIndex = _currentBlogEntryIndex;
@synthesize nextBlogEntryIndex = _nextBlogEntryIndex;
@synthesize previousBlogEntryIndex = _previousBlogEntryIndex;

@synthesize nextDetailViewController = _nextDetailViewController;

@synthesize isNavigationBarAndToolbarHidden = _isNavigationBarAndToolbarHidden;

@synthesize couldNotLoadDataLabel = _couldNotLoadDataLabel;

@synthesize articlesDateFormatter = _articlesDateFormatter;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.firstRelatedArticleId = @"";
        self.secondRelatedArticleId = @"";
        self.thirdRelatedArticleId = @"";
        
        self.didLoadContentForRemoteArticle = NO;
           
        self.importer = nil;
        
        
        self.articlesDateFormatter = [[NSDateFormatter alloc] init];
        [self.articlesDateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)loadNavigationButtons
{
    CGSize sizeOfButtons = CGSizeMake(35.0f, 35.0f);
    
    //add the navigate back-forth buttons
    UIView *backAndForwardNavigationItemView = [[UIView alloc] initWithFrame:CGRectMake(320.0f-70.0f-10.0f-10.0f, 5.0f, 90.0f, 35.0f)];
    backAndForwardNavigationItemView.backgroundColor = [UIColor clearColor];
    
    //add navigate forward button
    self.nextArticleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextArticleButton.frame = CGRectMake(backAndForwardNavigationItemView.bounds.size.width-sizeOfButtons.width, 0, sizeOfButtons.width, sizeOfButtons.height);
    [_nextArticleButton addTarget:self action:@selector(navigateToNextArticle) forControlEvents:UIControlEventTouchDown];
    [_nextArticleButton setImage:[UIImage imageNamed:@"navigationButtonNextArticle"] forState:UIControlStateNormal];
    [backAndForwardNavigationItemView addSubview:_nextArticleButton];
    
    //add navigate back button
    self.previousArticleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _previousArticleButton.frame = CGRectMake(_nextArticleButton.frame.origin.x-sizeOfButtons.width-10.0f, 0, sizeOfButtons.width, sizeOfButtons.height);
    [_previousArticleButton addTarget:self action:@selector(navigateToPreviousArticle) forControlEvents:UIControlEventTouchDown];
    [_previousArticleButton setImage:[UIImage imageNamed:@"navigationButtonPreviousArticle"] forState:UIControlStateNormal];
    [backAndForwardNavigationItemView addSubview:_previousArticleButton];
    
    UIBarButtonItem *backAndForwardNavigationItem = [[UIBarButtonItem alloc] initWithCustomView:backAndForwardNavigationItemView];
    self.navigationItem.rightBarButtonItem = backAndForwardNavigationItem;
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
        
     
}

- (void)viewWillAppear:(BOOL)animated
{    
    [self setNavigationBarAndToolbarHidden:_isNavigationBarAndToolbarHidden animated:animated];
   
    [self.appDelegate setIsToolbarHidden:YES animated:YES];
    //----------------------------------------------------------------------------
    
    if (_isShowingArticleFromLocalDatabase) 
    {
        [self setupNavigationEntries];
        [self configureView];
    }
    else if(!_didLoadContentForRemoteArticle)
    {
        //check if article is already existent and only then trigger the loading
        BlogEntry* entry = nil;
        entry = [self.importer blogEntryWithId:self.currentArticleId];
        
        //blog entry with currentId was found, configure the view
        if(entry)
        {
            self.isShowingArticleFromLocalDatabase = YES;
            _isLoadingCurrentArticle = NO;
            
            self.blogEntry = entry;
            
            self.previousBlogEntryIndex = kInvalidBlogEntryIndex;
            self.nextBlogEntryIndex = kInvalidBlogEntryIndex;
            
            [self configureView];
        }
        
        //load the blog entry
        else {
            [self startLoadingSingleArticle];
        }
    }
    
    [self setUpBackButton];
}

#pragma mark - Navigation options

-(void)handleBack:(id)sender
{    
    if (self.viewControllerToReturnTo) {
        [self.navigationController popToViewController:self.viewControllerToReturnTo animated:YES];
    }
    else {
        NSLog(@"WARNING! viewControllerToReturnTo not found");
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)navigateToNextArticle
{    
    //if previous blog entry invalid, just return
    if (_nextBlogEntryIndex==kInvalidBlogEntryIndex)
        return;
    
    if (_navigationDetailViewController==nil) {
        self.navigationDetailViewController = [[IGNDetailViewController alloc] initWithNibName:@"IGNDetailViewController_iPhone" bundle:nil];
    }
    
    self.navigationDetailViewController.viewControllerToReturnTo = self.viewControllerToReturnTo;
    
    self.navigationDetailViewController.fetchedResults = _fetchedResults;
    self.navigationDetailViewController.currentBlogEntryIndex = _nextBlogEntryIndex;
    self.navigationDetailViewController.isShowingArticleFromLocalDatabase = YES;
    
    if (_nextBlogEntryIndex-1>=0) {
        self.navigationDetailViewController.previousBlogEntryIndex = _nextBlogEntryIndex-1;
    } 
    else{
        self.navigationDetailViewController.previousBlogEntryIndex = -1;
    }
    
    if(_nextBlogEntryIndex+1<_fetchedResults.count)
    {
        self.navigationDetailViewController.nextBlogEntryIndex = _nextBlogEntryIndex+1;
    }
    else{
        self.navigationDetailViewController.nextBlogEntryIndex = -1;
    }
    
    _navigationDetailViewController.blogEntry = self.nextBlogEntry;
    
    self.navigationDetailViewController.isNavigationBarAndToolbarHidden = _isNavigationBarAndToolbarHidden;
    
    [self.navigationController pushViewController:_navigationDetailViewController animated:YES];
}

-(void)navigateToPreviousArticle
{
    //if previous blog entry invalid, just return
    if (_previousBlogEntryIndex==kInvalidBlogEntryIndex)
        return;
    
    //navigate to previous article
    if (_navigationDetailViewController==nil) {
        self.navigationDetailViewController = [[IGNDetailViewController alloc] initWithNibName:@"IGNDetailViewController_iPhone" bundle:nil];
    }
    
    self.navigationDetailViewController.viewControllerToReturnTo = self.viewControllerToReturnTo;
    
    self.navigationDetailViewController.fetchedResults = _fetchedResults;
    self.navigationDetailViewController.currentBlogEntryIndex = _previousBlogEntryIndex;
    self.navigationDetailViewController.isShowingArticleFromLocalDatabase = YES;
    
    if (_currentBlogEntryIndex-1>=0) {
        self.navigationDetailViewController.previousBlogEntryIndex = _previousBlogEntryIndex-1;
    } 
    else{
        self.navigationDetailViewController.previousBlogEntryIndex = kInvalidBlogEntryIndex;
    }
    
    if(_currentBlogEntryIndex<_fetchedResults.count)
    {
        self.navigationDetailViewController.nextBlogEntryIndex = _currentBlogEntryIndex;
    }
    else{
        self.navigationDetailViewController.nextBlogEntryIndex = kInvalidBlogEntryIndex;
    }
    
    self.navigationDetailViewController.blogEntry = self.previousBlogEntry;
    self.navigationDetailViewController.isNavigationBarAndToolbarHidden = _isNavigationBarAndToolbarHidden;
    
    //push the view controller from left to right
    NSMutableArray *vcs =  [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [vcs insertObject:_navigationDetailViewController atIndex:[vcs count]-1];
    [self.navigationController setViewControllers:vcs animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setupNavigationEntries
{
    //set up view for when the article is not in the local database and has to be loaded
    if (_isLoadingCurrentArticle) 
    {
        self.nextBlogEntry = nil;
        self.previousBlogEntry = nil;
        
        _nextArticleButton.alpha = 0;
        _previousArticleButton.alpha = 0;
        
        return;
    }
    
    //set up view for when article is not saved in the local database
    else if(!_isShowingArticleFromLocalDatabase)
    {
        
        
        
    }
    
    //set up view for when article is stored in the local database
    else 
    {
        //set up previousObject
        NSManagedObject *previousObject = nil;
        if (_previousBlogEntryIndex!=kInvalidBlogEntryIndex) {
            previousObject = [_fetchedResults objectAtIndex:_previousBlogEntryIndex];
        }
        self.previousBlogEntry = (BlogEntry*)previousObject;
        
        //set up nextObject
        NSManagedObject *nextObject = nil;
        if (_nextBlogEntryIndex!=kInvalidBlogEntryIndex) {
            nextObject = [_fetchedResults objectAtIndex:_nextBlogEntryIndex];
        }
        
        self.nextBlogEntry = (BlogEntry*)nextObject;
    }
}

-(void)setupNavigationButtons
{
    //set up view for when the article is not in the local database and has to be loaded
    if (_isLoadingCurrentArticle) 
    {
        self.nextBlogEntry = nil;
        self.previousBlogEntry = nil;
        
        _nextArticleButton.alpha = 0;
        _previousArticleButton.alpha = 0;
        
        return;
    }
    
    //set up view for when article is not saved in the local database
    else if(!_isShowingArticleFromLocalDatabase)
    {
    
        
        
    }
    
    //set up view for when article is stored in the local database
    else 
    {
        //set up previousObject
        NSManagedObject *previousObject = nil;
        if (_previousBlogEntryIndex!=kInvalidBlogEntryIndex) {
            previousObject = [_fetchedResults objectAtIndex:_previousBlogEntryIndex];
        }
        self.previousBlogEntry = (BlogEntry*)previousObject;
        
        //set up nextObject
        NSManagedObject *nextObject = nil;
        if (_nextBlogEntryIndex!=kInvalidBlogEntryIndex) {
            nextObject = [_fetchedResults objectAtIndex:_nextBlogEntryIndex];
        }
        self.nextBlogEntry = (BlogEntry*)nextObject;
        
        
        CGFloat alphaForInactiveButtons = 0.35;
        CGFloat alphaForActiveButtons = 1.0;
        
        //only activate the back button if the previousBlogEntry is set
        if (_previousBlogEntry==nil) 
        {
            _previousArticleButton.userInteractionEnabled = NO;
            _previousArticleButton.alpha = alphaForInactiveButtons;
        }
        else
        {
            _previousArticleButton.userInteractionEnabled = YES;
            _previousArticleButton.alpha = alphaForActiveButtons;
        }
        
        //only activate the next button if the previousBlogEntry is set
        if (_nextBlogEntry==nil) 
        {
            _nextArticleButton.userInteractionEnabled = NO;
            _nextArticleButton.alpha = alphaForInactiveButtons;
        }
        else
        {
            _nextArticleButton.userInteractionEnabled = YES;
            _nextArticleButton.alpha = alphaForActiveButtons;
        }
    }
}

#pragma mark - UIWebView delegate methods

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		NSURL *url = [request URL];	
		NSLog(@"url is: %@ ", url);
        
        
#warning TODO: define here what to do with the link
//        [[UIApplication sharedApplication] openURL:url];
        
        return NO;
	}
	
	return YES;   
}


- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    
#define PADDING_BOTTOM 0.0f 
    
    //get the content size of the webview
    CGRect frame = aWebView.frame;
    frame.size.height = 1;
    aWebView.frame = frame;
    CGSize fittingSize = [aWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    aWebView.frame = frame;
    
    NSString *output = [aWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"ContentDiv\").offsetHeight;"];
    NSLog(@"HEREHERE aWebView.frame.size.height: %f height: %@", aWebView.frame.size.height, output);
    
    //resize the webview to fit the newly loaded content
    CGRect tempRect;
    CGSize tempSize;
    
    CGSize finalSizeForArticleContentView = _articleContentView.bounds.size;
    tempSize = finalSizeForArticleContentView;
    
    _descriptionWebView.frame = CGRectMake(aWebView.frame.origin.x, aWebView.frame.origin.y, _descriptionWebView.bounds.size.width, fittingSize.height);
    finalSizeForArticleContentView = CGSizeMake(tempSize.width, tempSize.height+fittingSize.height-lastHeightForWebView);
    
    //set the frame of the article content view
    tempRect = _articleContentView.frame;
    _articleContentView.frame = CGRectMake(tempRect.origin.x, tempRect.origin.y, finalSizeForArticleContentView.width, finalSizeForArticleContentView.height);
    
    //set up the related articles view and add it to the contentScrollView
    CGPoint pointToDrawRelatedArticles = CGPointMake(0, self.articleContentView.bounds.size.height);
    CGSize nibSizeForRelatedArticles = self.relatedArticlesView.bounds.size;
    self.relatedArticlesView.frame = CGRectMake(pointToDrawRelatedArticles.x, pointToDrawRelatedArticles.y, nibSizeForRelatedArticles.width, nibSizeForRelatedArticles.height);
    [self.contentScrollView addSubview:self.relatedArticlesView];
    
    //set up the scrollView's final contentSize
    CGSize contentScrollViewFinalSize = CGSizeMake(320.0f, _relatedArticlesView.bounds.size.height+_articleContentView.bounds.size.height + PADDING_BOTTOM);
    self.contentScrollView.contentSize = contentScrollViewFinalSize;
    
    //set up the scrollView's final contentSize
    self.contentScrollView.contentSize = contentScrollViewFinalSize;
    
    [self setIsLoadingViewHidden:YES];
    
    
}

#pragma mark - setting up the view
-(void)setIsDescriptionWebViewLoadingViewHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (animated) {
        
        if (hidden) {
                        
            __block UIView* blocKDescriptionWebViewLoadingView = self.descriptionWebViewLoadingView; 
            __block UIView* blocKDescriptionWebView = self.descriptionWebView; 
            
            
            [UIView animateWithDuration:1.0f 
                             animations:
             ^{
                 [blocKDescriptionWebViewLoadingView setAlpha:0.0f];
            } 
                            completion:
             ^(BOOL finished){
                 if (finished) {
                        [blocKDescriptionWebViewLoadingView removeFromSuperview];
                 }
            }];
            
        }
        else {
            
            [self.descriptionWebView addSubview:self.descriptionWebViewLoadingView];
            
            __block UIView* blocKDescriptionWebViewLoadingView = self.descriptionWebViewLoadingView; 
            __block UIView* blocKDescriptionWebView = self.descriptionWebView; 
            
            
            [UIView animateWithDuration:1.0f 
                             animations:
             ^{
                 [blocKDescriptionWebViewLoadingView setAlpha:1.0f];
             } 
                             completion:
             ^(BOOL finished){
                 
             }];
            
        }
        
        
    }
    else {
        
        if (hidden) {
            [self.descriptionWebView removeFromSuperview];
        }
        else {
            [self.descriptionWebView addSubview:self.descriptionWebViewLoadingView];
        }
    }
}

-(UIView*)descriptionWebViewLoadingView
{
    if (_descriptionWebViewLoadingView==nil) {
        
        UIView* aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 500.0f)];     
        aView.backgroundColor = [UIColor whiteColor];
        
        CGSize indicatorViewSize = CGSizeMake(44.0f, 44.0f);
        UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.frame = CGRectMake((aView.frame.size.width-indicatorViewSize.width)/2, 0.0f, indicatorViewSize.width, indicatorViewSize.height);
//        [indicatorView startAnimating];
//        [aView addSubview:indicatorView];
        
        _descriptionWebViewLoadingView = aView;
    }
    
    return _descriptionWebViewLoadingView;
}


-(void)setupArticleContentView
{
    LOG_CURRENT_FUNCTION()
    
    [self setupArticleContentViewWithArticleTitle:[self.blogEntry title] 
                                        articleId:[self.blogEntry articleId] 
                                     categoryName:[self.blogEntry categoryName] 
                                  descriptionText:[self.blogEntry descriptionText]  
                                  relatedArticles:[self.blogEntry relatedArticles]   
                                     remoteImages:[self.blogEntry remoteImages] 
                                      publishDate:[self.blogEntry publishingDate]];
    
    return;  
}


- (void)configureView
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
#define PADDING_BOTTOM 5.0f
    [_contentScrollView scrollRectToVisible:CGRectMake(0, 0, 320, 10) animated:NO];
    
    //if article still needs to be loaded, show loading view
    if (_isShowingArticleFromLocalDatabase==NO && _isLoadingCurrentArticle==YES) 
    {        
        [self setIsLoadingViewHidden:NO];
        
        return;
    }
    else if(_isShowingArticleFromLocalDatabase==NO && _isLoadingCurrentArticle==NO)
    {
        NSLog(@"_isShowingArticleFromLocalDatabase= NO, _isLoadingCurrentArticle==NO");
    }
    
    //set up the view in case the article is already here
    else 
    {    
        
        //show loading view only for specific blog entry templates
        if ([self.blogEntry.tempate compare:kFKArticleTemplateMonifaktur]==NSOrderedSame) {
            [self setIsLoadingViewHidden:NO];
        }

        
        //article already loaded,
        //set up the article content view
        [self setupArticleContentView];
    }
}


-(NSString*)wrapRichTextForArticle:(NSString*)richText
{
    NSString* style = @"body,input,textarea,a,pre { font-family: Georgia, \"Bitstream Charter\", serif; font-size:12px; } a{ color: black; text-decoration: underline; }";
    return [NSString stringWithFormat:@"<!DOCTYPE html><html><head><script type='text/javascript'>document.onload = function(){document.ontouchmove = function(e){e.preventDefault();}};</script><style type='text/css'>%@</style></head><body style='margin: 0; padding: 0; border:0px;'><div style='width: 310px;' id='ContentDiv'>%@</div></body></html>",style,richText];
}

-(void)setupUIElementsForCurrentBlogEntryTemplate
{
    
    if ([self.blogEntry.tempate compare:kFKArticleTemplateDefault]==NSOrderedSame) {
        [self.articleContentView addSubview:self.showPictureSlideshowButton];
        [self.playVideoButton removeFromSuperview];
    }
    
    else if ([self.blogEntry.tempate compare:kFKArticleTemplateArticle]==NSOrderedSame) {
        [self.playVideoButton removeFromSuperview];
    }
    
    else if ([self.blogEntry.tempate compare:kFKArticleTemplateMonifaktur]==NSOrderedSame) {
        [self.showPictureSlideshowButton removeFromSuperview];
        [self.playVideoButton removeFromSuperview];
    }
    
    else if ([self.blogEntry.tempate compare:kFKArticleTemplateVideo]==NSOrderedSame) {
        [self.showPictureSlideshowButton removeFromSuperview];
        [self.articleContentView addSubview:self.playVideoButton];
    }
    
    else if ([self.blogEntry.tempate compare:kFKArticleTemplateAicuisine]==NSOrderedSame) {
        [self.showPictureSlideshowButton removeFromSuperview];
        [self.playVideoButton removeFromSuperview];
    }
    
    else if ([self.blogEntry.tempate compare:kFKArticleTemplateItravel]==NSOrderedSame) {
        [self.showPictureSlideshowButton removeFromSuperview];
        [self.playVideoButton removeFromSuperview];
    }
}

- (IBAction)showMercedes:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAdressForMercedesPage]];
}

-(void)setupArticleContentViewWithArticleTitle:(NSString*)title
                                     articleId:(NSString*)articleID
                                  categoryName:(NSString*)categoryName
                               descriptionText:(NSString*)descriptionText
                               relatedArticles:(NSArray*)relatedArticles
                                  remoteImages:(NSArray*)remoteImages
                                   publishDate:(NSDate*)publishDate
{

#define DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW true
    
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
    LOG_CURRENT_FUNCTION()
    
    self.remoteImagesArray = [NSArray arrayWithArray:remoteImages];
    
    CGSize finalSizeForArticleContentView = CGSizeMake(0, 0); 
    CGFloat contentViewWidth = 320.0f;
    CGRect tempRect = CGRectMake(0, 0, 0, 0);
    CGSize tempSize = CGSizeMake(0, 0);
    
    
    //set up the blog entry imageview
//    /////////////////////////// handle the thumb image image
#warning TODO: trigger loading the imageview with thumb image
#warning TODO: do something if the image was not loaded
    NSString *encodedString = [[NSString alloc] initWithFormat:@"%@?%@=%@",kAdressForImageServer,kArticleId,articleID];
    NSURL* thumbURL = [[NSURL alloc] initWithString:encodedString];
    __block NSURL* blockThumbURL = thumbURL;
    
    [self.entryImageView setImageWithURL:thumbURL 
                        placeholderImage:nil 
                                 success:^(UIImage* image){
                                     NSLog(@"loaded _entryImageView: %@", blockThumbURL);
                                 } 
                                 failure:^(NSError* aError){
                                     NSLog(@"could NOT load _entryImageView: %@", blockThumbURL);
                                 }];
    
    //add the imageViewSize to the finalSizeForArticleContentView
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
    NSLog(@"adding the imageViewSize to the finalSizeForArticleContentView...");
    
    finalSizeForArticleContentView = CGSizeMake(contentViewWidth, _entryImageView.frame.origin.y+_entryImageView.bounds.size.height);
    
    //set up the button for showing pictures
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
    NSLog(@"setting up the button for showing pictures...");
    
    if ([remoteImages isKindOfClass:[NSArray class]]) {
        
#warning TODO: localize
        NSString *showPicturesButtonText = [NSString stringWithFormat:@"%d Fotos",[remoteImages count]];
        [self.showPictureSlideshowButton setTitle:showPicturesButtonText forState:UIControlStateNormal];
    }
    
    //set up the title
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
    NSLog(@"setting up the title...");
    
    self.titleLabel.text = [title uppercaseString];
    
    //set up the date label
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
    NSLog(@"setting up the date label...");
    
    tempRect = self.dateLabel.frame;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    self.dateLabel.text = [formatter stringFromDate:publishDate];
    
    
    //set up the category name
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
    NSLog(@"setting up the category name...");
    
    if (categoryName!=nil) 
    {
        NSString *category = categoryName;
        NSString *categoryName = @"∙ "; //special characters: ∙ , ●
        
        categoryName = [categoryName stringByAppendingString:category];
        
        self.categoryLabel.text = categoryName;
        self.categoryLabel.frame = CGRectMake(tempRect.origin.x+tempRect.size.width, tempRect.origin.y, 100, tempRect.size.height);
    }
    
    //add the title, date and category labels size to the finalSizeForArticleContentView
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
    NSLog(@"adding the title, date and category labels size to the finalSizeForArticleContentView...");
    
    tempSize = finalSizeForArticleContentView;
    finalSizeForArticleContentView = CGSizeMake(tempSize.width, tempSize.height+_titleLabel.bounds.size.height+_categoryLabel.bounds.size.height+(_titleLabel.frame.origin.y-tempSize.height));
    
    
    //set up the description textview
    //set up the user interface for the current objects    
    CGFloat marginTop = 5.0f;
    
    //start setting up the uiwebview 
    NSString* finalRichText = [self wrapRichTextForArticle:descriptionText];
    
    [self.descriptionWebView loadHTMLString:finalRichText baseURL:nil];    
    self.descriptionWebView.delegate = self;
    
    CGRect frame = _descriptionWebView.frame;
    CGSize fittingSize = [_descriptionWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    _descriptionWebView.frame = frame;
    
    CGRect descriptionWebViewFrame = _descriptionWebView.frame;
    CGSize descriptionTextContentSize = descriptionWebViewFrame.size;
    
    _descriptionWebView.frame = CGRectMake(descriptionWebViewFrame.origin.x, finalSizeForArticleContentView.height+marginTop, descriptionWebViewFrame.size.width, descriptionTextContentSize.height);
    
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
    NSLog(@"_descriptionWebView.frame: %@", NSStringFromCGRect(_descriptionWebView.frame));
    
    lastHeightForWebView = descriptionTextContentSize.height;
    
    //add the description textview size to the finalSizeForArticleContentView
    tempSize = finalSizeForArticleContentView;
    finalSizeForArticleContentView = CGSizeMake(tempSize.width, tempSize.height+descriptionTextContentSize.height);
    
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
    NSLog(@"(after decriptiontextview) finalSizeForArticleContentView: %@", NSStringFromCGSize(finalSizeForArticleContentView));
    
    //set the frame of the article content view
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
        NSLog(@"setting the frame of the article content view...");
    
    tempRect = self.articleContentView.frame;
    self.articleContentView.frame = CGRectMake(tempRect.origin.x, tempRect.origin.y, finalSizeForArticleContentView.width, finalSizeForArticleContentView.height+10.0f);
    
    
    //add the articleContentView to the scrollView
    [self.contentScrollView addSubview:self.articleContentView];
    
    //setup related articles UI for presentation, don't add the view to the contentView yet
    [self setupRelatedArticlesUI:relatedArticles];
    
    //setup ui elements for current blogentry template
    [self setupUIElementsForCurrentBlogEntryTemplate];
}

-(void)setupRelatedArticlesUI:(NSArray*)relatedArticles
{
    #define DEBUG_ENABLE_FOR_SETUP_RELATED_ARTICLES_UI true
    
    if(DEBUG_ENABLE_FOR_SETUP_RELATED_ARTICLES_UI)
    LOG_CURRENT_FUNCTION()
    
    if ([relatedArticles count]<3)
        return;
        
    NSDictionary* firstRelatedArticle = [relatedArticles objectAtIndex:0];
    NSDictionary* secondRelatedArticle = [relatedArticles objectAtIndex:1];
    NSDictionary* thirdRelatedArticle = [relatedArticles objectAtIndex:2];
    
    //set up first related article
    if(DEBUG_ENABLE_FOR_SETUP_RELATED_ARTICLES_UI)
    NSLog(@"setting up first related article...");
    
    if (firstRelatedArticle!=nil) {
        self.firstRelatedArticleTitleLabel.text = [firstRelatedArticle objectForKey:kFKArticleTitle];
        self.firstRelatedArticleCategoryLabel.text = [firstRelatedArticle objectForKey:kFKRelatedArticleCategoryText];
        
        NSString* imageBase64String =  [firstRelatedArticle objectForKey:kFKRelatedArticleBase64Thumbnail];
        UIImage *someImage = [[UIImage alloc] initWithData:[NSData dataFromBase64String:imageBase64String]];
        self.firstRelatedArticleImageView.image = someImage;   
        
        self.firstRelatedArticleId = (NSString*)[firstRelatedArticle objectForKey:kFKArticleId];
    }
    
    //set up second related article
    if(DEBUG_ENABLE_FOR_SETUP_RELATED_ARTICLES_UI)
    NSLog(@"setting up second related article...");
    
    if (secondRelatedArticle!=nil) {
        self.secondRelatedArticleTitleLabel.text = [secondRelatedArticle objectForKey:kFKArticleTitle];
        self.secondRelatedArticleCategoryLabel.text = [secondRelatedArticle objectForKey:kFKRelatedArticleCategoryText];
        
        NSString* imageBase64String =  [secondRelatedArticle objectForKey:kFKRelatedArticleBase64Thumbnail];
        UIImage *someImage = [[UIImage alloc] initWithData:[NSData dataFromBase64String:imageBase64String]];
        self.secondRelatedArticleImageView.image = someImage;
        
        self.secondRelatedArticleId = (NSString*)[secondRelatedArticle objectForKey:kFKArticleId];
    }
    
    //set up third related article
    if(DEBUG_ENABLE_FOR_SETUP_RELATED_ARTICLES_UI)
    NSLog(@"setting up third related article...");
    
    if (thirdRelatedArticle!=nil) {
        self.thirdRelatedArticleTitleLabel.text = [thirdRelatedArticle objectForKey:kFKArticleTitle];
        self.thirdRelatedArticleCategoryLabel.text = [thirdRelatedArticle objectForKey:kFKRelatedArticleCategoryText];
        
        NSString* imageBase64String =  [thirdRelatedArticle objectForKey:kFKRelatedArticleBase64Thumbnail];
        UIImage *someImage = [[UIImage alloc] initWithData:[NSData dataFromBase64String:imageBase64String]];
        self.thirdRelatedArticleImageView.image = someImage;
        
        self.thirdRelatedArticleId = (NSString*)[thirdRelatedArticle objectForKey:kFKArticleId];
    }
    
    if(DEBUG_ENABLE_FOR_SETUP_RELATED_ARTICLES_UI)
    NSLog(@"finished setting up related articles!");
}



-(void)setupArticleContentViewWithRemoteDataDictionary:(NSDictionary*)articleDictionary
{
    LOG_CURRENT_FUNCTION()
    
    NSString *remoteContentArticleTitle = [articleDictionary objectForKey:kFKArticleTitle];
    NSString *remoteContentArticleID = [articleDictionary objectForKey:kFKArticleId];
    NSString *remoteContentCategoryName = [articleDictionary objectForKey:kFKArticleCategoryName];
    NSString *remoteContentArticleDescriptionText = [articleDictionary objectForKey:kFKArticleDescriptionText];
    NSArray *remoteContentRelatedArticles = [articleDictionary objectForKey:kFKArticleRelatedArticles];
    NSArray *remoteContentRemoteImages = [articleDictionary objectForKey:kFKArticleRemoteImages];
    NSString *remoteContentBlogEntryPublishDate = [articleDictionary objectForKey:kFKArticlePublishingDate];
        
    
    NSDate *fDate = [self.articlesDateFormatter dateFromString:remoteContentBlogEntryPublishDate];
    
    [self setupArticleContentViewWithArticleTitle:remoteContentArticleTitle
                                        articleId:remoteContentArticleID
                                     categoryName:remoteContentCategoryName
                                  descriptionText:remoteContentArticleDescriptionText
                                  relatedArticles:remoteContentRelatedArticles
                                     remoteImages:remoteContentRemoteImages
                                      publishDate:fDate];
    return;    
}


#pragma mark - picture slideshow

- (IBAction)showPictureSlideshow:(id)sender 
{
    ImageSlideshowViewController *slideshowVC = [[ImageSlideshowViewController alloc] initWithNibName:@"ImageSlideshowViewController" bundle:nil];
    
    //set up the slideshowVC
    slideshowVC.remoteImagesArray = _remoteImagesArray;
    
    //show the slideshowVC
    slideshowVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentModalViewController:slideshowVC animated:YES];

}
- (IBAction)tapAction:(id)sender 
{
    if (self.navigationController.navigationBar.isHidden) 
    {
        [self setNavigationBarAndToolbarHidden:NO animated:YES];
    }
    else
    {
        [self setNavigationBarAndToolbarHidden:YES animated:YES];
    }
}

-(void)setNavigationBarAndToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
#define IGNANT_TOOLBAR_HEIGHT 50.0f
#define IGNANT_GRADIENT_HEIGHT 4.0f
#define ANIMATION_DURATION UINavigationControllerHideShowBarDuration
    
    LOG_CURRENT_FUNCTION()
    
    //hide/show the toolbar    
    BOOL isCurrentlyHidden = self.navigationController.isNavigationBarHidden;
        
    //don't change anything if state hasn't change
    if (hidden==isCurrentlyHidden)
    return;
    
    //hide/show the navigation bar
    [self.navigationController setNavigationBarHidden:hidden animated:animated];
    
    self.isNavigationBarAndToolbarHidden = hidden;
    self.contentScrollView.autoresizingMask = UIViewAutoresizingNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    __block UIView* blockReadyShareAndMoreToolBar = self.shareAndMoreToolbar;
    __block UIView* blockReadyGradientView = self.appDelegate.toolbarGradientView;
    __block UIScrollView* blockReadyContentScrollView = self.contentScrollView;
    
    __block UIView* blockSelfView = self.view;
    
    CGFloat navigationBarHeight = 44.0f;
    CGFloat scrollViewHeight = 366.0f;
    CGFloat statusBarHeight = 20.0f;
    CGFloat shareAndMoreToolbarHeight = 50.0f;
    
    void (^toolbarblock)(void);
    toolbarblock = ^{
        
        //move the gradient on/off the screen
        CGRect gradientFrame = blockReadyGradientView.frame;
        CGRect newGradientFrame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
        if (hidden) {
            newGradientFrame = CGRectMake(0.0f, -(statusBarHeight+navigationBarHeight), gradientFrame.size.width, gradientFrame.size.height);
        }
        else {
            newGradientFrame = CGRectMake(0.0f, statusBarHeight+navigationBarHeight, gradientFrame.size.width, gradientFrame.size.height);
        }
        [blockReadyGradientView setFrame:newGradientFrame];

        //move the toolbar out of the screen
        CGRect currentShareAndMoreToolbarFrame = blockReadyShareAndMoreToolBar.frame; 
        CGRect newShareAndMoreToolbarFrame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
        if (hidden) {
            newShareAndMoreToolbarFrame = CGRectMake(0.0f, blockSelfView.frame.size.height+shareAndMoreToolbarHeight, currentShareAndMoreToolbarFrame.size.width, currentShareAndMoreToolbarFrame.size.height);
        }
        else {
            newShareAndMoreToolbarFrame = CGRectMake(0.0f, blockSelfView.frame.size.height-shareAndMoreToolbarHeight, currentShareAndMoreToolbarFrame.size.width, currentShareAndMoreToolbarFrame.size.height);
        }
        [blockReadyShareAndMoreToolBar setFrame:newShareAndMoreToolbarFrame];
        
        //resize the scroll view
        CGRect currentScrollViewFrame = blockReadyContentScrollView.frame;
        CGRect newScrollViewFrame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
        if (hidden) {
            newScrollViewFrame = CGRectMake(0.0f, 0.0f, currentScrollViewFrame.size.width, scrollViewHeight+navigationBarHeight+shareAndMoreToolbarHeight);
        }
        else {
            newScrollViewFrame = CGRectMake(0.0f, 0.0f, currentScrollViewFrame.size.width, scrollViewHeight);
        }
        
        [blockReadyContentScrollView setFrame:newScrollViewFrame];
        
        NSLog(@"newScrollViewFrame: %@ shareAndMoreToolbarHeight: %f scrollViewHeight: %f", NSStringFromCGRect(newScrollViewFrame), shareAndMoreToolbarHeight, scrollViewHeight);
        
    };
    
    //execute show/hide
    if (!animated) 
    {
        toolbarblock();
    }
    else 
    {        
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration 
                              delay:0.0f 
                            options:UIViewAnimationCurveEaseInOut 
                         animations:toolbarblock 
                         completion:^(BOOL finished){
                             
                         }];
    }
}

#pragma mark - social media
-(void)postToFacebook
{

    //initialize facebook in case not yet done
    [self.appDelegate initializeFacebook];
    
    //get details for current selected blogentry
    BlogEntry* currentBlogEntry = self.blogEntry;
    
#warning add the relevant live information
    
    NSString* infoLinkToArticleMainPage = currentBlogEntry.webLink;
    NSString* infoNameOfArticle = currentBlogEntry.title;
    NSString* infoDescriptionForArticle = currentBlogEntry.descriptionText;
    NSString* substringInfoDescriptionForArticle = [infoDescriptionForArticle isKindOfClass:[NSString class]] ? [infoDescriptionForArticle substringWithRange:NSMakeRange(0, 200)] : @"";
    substringInfoDescriptionForArticle = [substringInfoDescriptionForArticle stringByAppendingFormat:@"..."];
    
    //IDEA: as an improvement, add server-side script to create small thumbs specific for the facebook app
    //REBUTAL: no, you shouldn't, because the article may be posted on the facebook wall where it is important to have some quality in the picture
    NSString* infoLinkToThumbForArticle = @"http://www.ignant.de/wp-content/uploads/2012/06/housec_pre2.jpg";
    NSString* infoCaptionForArticle = @"";
    
    
    //show the facebok dialogue for posting to wall
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   kFacebookAppId, @"app_id",
                                   infoLinkToArticleMainPage, @"link",
                                   infoLinkToThumbForArticle, @"picture",
                                   infoNameOfArticle, @"name", 
                                   infoCaptionForArticle, @"caption",
                                   substringInfoDescriptionForArticle, @"description",
                                   nil];
    
    [self.appDelegate.facebook dialog:@"feed" andParams:params andDelegate:self];
}


-(void)postToPinterest
{
   NSLog(@"should post to pinterest");
}

-(void)postToTwitter
{
    BOOL canTweet = [TWTweetComposeViewController canSendTweet];
    
    if (!canTweet) {
        
#warning TODO: show this in a better way

        
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"" 
                                                     message:NSLocalizedString(@"ui_alert_message_you_need_to_be_logged_in_with_twitter", nil)
                                                    delegate:self 
                                           cancelButtonTitle:NSLocalizedString(@"ui_alert_dismiss", nil)
                                           otherButtonTitles:nil];
        [av show];
        
        return;
        
    }
    else {
        
#warning TODO: if link not set, dismiss and show error (or something)
        
        NSString* title = self.blogEntry.title;
        NSString* link = self.blogEntry.webLink;
        
        NSString* tweet = [NSString stringWithFormat:@"☞ %@ | %@ via @ignantblog",title, link];
        
        TWTweetComposeViewController *tweetVC = [[TWTweetComposeViewController alloc] init];
        [tweetVC setInitialText:tweet];
        [tweetVC addImage:self.entryImageView.image];
        
        [tweetVC setCompletionHandler:^(TWTweetComposeViewControllerResult result){
            NSString* output;
            
            
            switch (result) {
                case TWTweetComposeViewControllerResultCancelled:
                    output = @"tweet canceled";
                    break;
                case TWTweetComposeViewControllerResultDone:
                    output = @"tweet done";
                    break;    
                default:
                    break;
            }
        
            
            NSLog(@"output: %@", output);
            
            //dismiss the tweet composition view controller modally
            [self dismissModalViewControllerAnimated:YES];
        
        }];
        
        
        [self presentModalViewController:tweetVC animated:YES];
    }
    
    NSLog(@"canTweet: %@", canTweet ? @"TRUE" : @"FALSE");
    
    NSLog(@"should post to twitter"); 
}

#pragma mark - show mosaik / more
- (IBAction)showShare:(id)sender {
    
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Twitter",@"Facebook", nil ];
    
    [shareActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //TODO: maybe put this constants somewhere else
    int twitterButtonIndex = 0;
    int facebookButtonIndex = 1;
    
    if (buttonIndex==facebookButtonIndex) {
        [self postToFacebook];
    }
    
    else if (buttonIndex==twitterButtonIndex) {
        [self postToTwitter];
    }
}

- (IBAction)showMore:(id)sender {
    IGNMoreOptionsViewController *moreOptionsVC = self.appDelegate.moreOptionsViewController;
    [self.navigationController pushViewController:moreOptionsVC animated:YES];
}

#pragma mark - related articles
-(void)showRelatedArticle:(id)sender
{
    NSString *articleId = nil;
    
    if ([sender tag] == kFirstRelatedArticleTag) 
    {
        articleId = [[NSString alloc] initWithString:_firstRelatedArticleId];
    }
    
    else if ([sender tag] == kSecondRelatedArticleTag) 
    {
        articleId = [[NSString alloc] initWithString:_secondRelatedArticleId];
    } 
    
    else if ([sender tag] == kThirdRelatedArticleTag) 
    {
        articleId = [[NSString alloc] initWithString:_thirdRelatedArticleId];
    }
    
    //tag is falsly set
    else
    {
        NSLog(@"tag is falsly set, doing nothing");
        return;
    }
    
    NSLog(@"articleId: %@", articleId);
    
    
    BlogEntry* entry = nil;
    entry = [self.importer blogEntryWithId:articleId];
    BOOL shouldLoadBlogEntryFromRemoteServer = (entry == nil);
    
    //check for the internet connection 
    if(shouldLoadBlogEntryFromRemoteServer && ![self.appDelegate checkIfAppOnline])
    {
    
#warning TODO: show this in a better way
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"" 
                                                     message:NSLocalizedString(@"ui_alert_message_you_need_an_internet_connection",nil)  
                                                    delegate:self 
                                           cancelButtonTitle:NSLocalizedString(@"ui_alert_dismiss",nil)
                                           otherButtonTitles:nil];
        [av show];
        
        
        
        return;
    }
    
    //blog entry to be shown is set, show the view controller loading the article data
    if (!self.nextDetailViewController) {
        self.nextDetailViewController = [[IGNDetailViewController alloc] initWithNibName:@"IGNDetailViewController_iPhone" bundle:nil];
    }
    
    NSLog(@"articleIdChosen: %@", articleId);
    self.nextDetailViewController.viewControllerToReturnTo = self.viewControllerToReturnTo;
    
    
    if(entry)
    {
        NSLog(@"entry exists, do not load");
        self.nextDetailViewController.blogEntry = entry;
        self.nextDetailViewController.isShowingArticleFromLocalDatabase = YES;        
    }
    
    else 
    {
        NSLog(@"entry DOES NOT exist, DO! load, :%@", articleId);
        self.nextDetailViewController.currentArticleId = articleId;
        self.nextDetailViewController.didLoadContentForRemoteArticle = NO;
        self.nextDetailViewController.isShowingArticleFromLocalDatabase = NO;
    }
    
    //reset the indexes
    self.nextDetailViewController.nextBlogEntryIndex = kInvalidBlogEntryIndex;
    self.nextDetailViewController.previousBlogEntryIndex = kInvalidBlogEntryIndex;
    
    //set the managedObjectContext and push the view controller
    self.nextDetailViewController.managedObjectContext = self.managedObjectContext;
    self.nextDetailViewController.isNavigationBarAndToolbarHidden = _isNavigationBarAndToolbarHidden;
    [self.navigationController pushViewController:self.nextDetailViewController animated:YES];
}

#pragma mark - getting content from the server
-(void)startLoadingSingleArticle
{    
    _isLoadingCurrentArticle = YES;
    
    [self configureView];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetSingleArticle,kParameterAction,self.currentArticleId,kArticleId, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
    
    NSLog(@"DETAIL encodedString go: %@",encodedString);
    
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
    _isLoadingCurrentArticle = NO;
    
    
    NSLog(@"[request responseString]: %@", [request responseString]);
    
#warning todo: handle errors
    [self.importer importJSONStringForSingleArticle:[request responseString]];    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
#warning TODO: do something with the request
    NSLog(@"requestFailed");
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    _isLoadingCurrentArticle = NO;
        
    [self setIsCouldNotLoadDataViewHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


#pragma mark - IgnantImporterDelegate

-(void)importerDidStartParsingSingleArticle:(IgnantImporter*)importer
{
    NSLog(@"importerDidStartParsingSingleArticle");
}

-(void)importer:(IgnantImporter*)importer didFinishParsingSingleArticleWithDictionary:(NSDictionary*)articleDictionary
{
    
#warning TODO: show something if article with id is not found    

    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    _didLoadContentForRemoteArticle = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [self setupArticleContentViewWithRemoteDataDictionary:articleDictionary];
        
        [self configureView];
        
        NSLog(@"(1) before");
        [self setIsLoadingViewHidden:YES];
    });
}

-(void)importer:(IgnantImporter*)importer didFailParsingSingleArticleWithDictionary:(NSDictionary*)articleDictionary
{
    NSLog(@"didFailParsingSingleArticleWithDictionary");
    
#warning TODO: stop showing loading view and return to the master view controlle
}

#pragma mark - UIGestureRecognizer delegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer 
       shouldReceiveTouch:(UITouch *)touch
{
    
    //check if touch on video button
    if (self.playVideoButton.superview !=nil ) {
        if ([touch.view isDescendantOfView:self.playVideoButton]) {
            return NO;
        }
    }
    
    //check if touch on show fotos button
    if (self.showPictureSlideshowButton.superview !=nil ) {
        if ([touch.view isDescendantOfView:self.showPictureSlideshowButton]) {
            return NO;
        }
    }
    
    //check if touch on show related articles button
    if (self.firstRelatedArticleShowDetailsButton.superview !=nil
        || self.secondRelatedArticleShowDetailsButton.superview !=nil
        || self.thirdRelatedArticleShowDetailsButton.superview !=nil) {
        
        if ([touch.view isDescendantOfView:self.firstRelatedArticleShowDetailsButton]
            || [touch.view isDescendantOfView:self.secondRelatedArticleShowDetailsButton]
            || [touch.view isDescendantOfView:self.thirdRelatedArticleShowDetailsButton]) {
            return NO;
        }
    }
    
    
    return YES;
}

#pragma mark - swipe UIGestureRecognizer



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

#pragma mark - custom special views
-(UIView *)couldNotLoadDataView
{
    UIView* defaultView = [super couldNotLoadDataView];
    self.couldNotLoadDataLabel.text = @"Could not load data for this article";
    return defaultView;
}


-(IBAction)playVideo:(id)sender
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    NSString *encodedString = [[NSString alloc] initWithFormat:@"%@?%@=%@",kAdressForVideoServer,kArticleId,self.blogEntry.articleId];
    NSURL* videoUrl = [[NSURL alloc] initWithString:encodedString];
    
    MPMoviePlayerViewController *moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoUrl];        
    [self presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
    
    NSLog(@"start playing video: %@", videoUrl);
}

@end
