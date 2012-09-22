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

#import "IGNMosaikViewController.h"

#import "IgnantImporter.h"
#import "Facebook.h"



//imports for ASIHTTPRequest
#import "ASIHTTPRequest.h"
#import "NSURL+stringforurl.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <MediaPlayer/MediaPlayer.h>



@interface IGNDetailViewController ()
{
    BOOL _isLoadingCurrentArticle;
    BOOL _isShowingLinkOptions;
    BOOL _isExecutingWebviewTapAction;
    
    NSURL* _linkOptionsUrl;
    CGFloat lastHeightForWebView;
}

-(void)setupArticleContentViewWithRemoteDataDictionary:(NSDictionary*)articleDictionary;
-(void)setupNavigationEntries;
-(void)setupUIElementsForBlogEntryTemplate:(NSString*)template;
- (IBAction)showMercedes:(id)sender;
-(IBAction) toggleLike:(id)sender;

//social media
-(void)postToFacebook;
-(void)postToPinterest;
-(void)postToTwitter;

@property (nonatomic, assign, readwrite) BOOL isShowingImageSlideshow;
@property (nonatomic, assign, readwrite) BOOL isImportingRelatedArticle;

@property (strong, nonatomic, readwrite) UITapGestureRecognizer *dtGestureRecognizer;

@property (strong, nonatomic, readwrite) NSDictionary *remoteArticleDictionary;
@property (strong, nonatomic, readwrite) NSString *remoteArticleJSONString;

@property (strong, nonatomic, readwrite) NSString *articleTitle;
@property (strong, nonatomic, readwrite) NSURL *articleWeblink;
@property (strong, nonatomic, readwrite) NSString *articleDescription;

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

@property (strong, nonatomic) IBOutlet UIImageView *entryImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *entryImageActivityIndicatorView;
@property (retain, nonatomic) IBOutlet UIButton *showSlideshowButton;

@property (nonatomic, strong, readwrite) NSNumberFormatter *numberFormatter;

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
@synthesize archiveLabel = _archiveLabel;
@synthesize showSlideshowButton = _showSlideshowButton;

@synthesize fetchedResults = _fetchedResults;
@synthesize currentArticleId, relatedArticlesIds;
@synthesize managedObjectContext = _managedObjectContext;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.firstRelatedArticleId = @"";
        self.secondRelatedArticleId = @"";
        self.thirdRelatedArticleId = @"";
        
        self.didLoadContentForRemoteArticle = NO;
        self.isShownFromMosaic = NO;
           
        self.importer = nil;
        
        self.articlesDateFormatter = [[NSDateFormatter alloc] init];
        [self.articlesDateFormatter setDateStyle:NSDateFormatterShortStyle];
        
        self.numberFormatter = [[NSNumberFormatter alloc] init];
        
        self.isImportingRelatedArticle = false;
        
        _isShowingLinkOptions = false;
        _isExecutingWebviewTapAction = false;
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
    
    self.relatedArticlesTitleLabel.text = NSLocalizedString(@"title_related_articles_detail_vc", @"Title for the label that apears on top of the related articles in the Detail View Controller");
    
	self.entryImageView.backgroundColor = IGNANT_GRAY_COLOR;
	
    self.dtGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDTViewTap:)];
    self.dtGestureRecognizer.delegate = self;
    _dtGestureRecognizer.numberOfTapsRequired = 1;
    [self.dtTextView addGestureRecognizer:_dtGestureRecognizer];
    
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
    [self setToggleLikeButton:nil];
    [self setRelatedArticlesTitleLabel:nil];
    [self setArticleVideoView:nil];
    [self setArticleVideoWebView:nil];
    [self setShowSlideshowButton:nil];
    [self setArchiveLabel:nil];
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	
	
	BOOL st = (interfaceOrientation == (UIInterfaceOrientationPortrait));
	NSLog(@"st: %@", st ? @"TRUE" : @"FALSE");
	
	
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}
#pragma mark - view methods

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSError* error = nil;
	GATrackPageView(&error, [NSString stringWithFormat:kGAPVArticleDetailView,self.currentArticleId]);
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isShownFromMosaic = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    //returning from showing the image slideshow, article detail page is already setup
    if (_isShowingImageSlideshow) {
        self.isShowingImageSlideshow = NO;
        return;
    }
    
    
    [self setNavigationBarAndToolbarHidden:_isNavigationBarAndToolbarHidden animated:animated];
   
    [self.appDelegate setIsToolbarHidden:YES animated:animated];
    
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
	
	__block __typeof__(self) blockSelf = self;
	
	
	if (self.isShownFromMosaic) {
        [self showMosaic];
		
		double delayInSeconds = .2;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[blockSelf.navigationController popViewControllerAnimated:NO];
		});
		
    }
    else
    {
        if (blockSelf.viewControllerToReturnTo) {
            [blockSelf.navigationController popToViewController:self.viewControllerToReturnTo animated:YES];
        }
        else {
            DBLog(@"WARNING! viewControllerToReturnTo not found");
            [blockSelf.navigationController popToRootViewControllerAnimated:YES];
        }
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

-(void)showLinkOptions:(NSURL*)url
{
    _isShowingLinkOptions = true;
    _linkOptionsUrl = url;
    
    UIActionSheet *linkActionSheet = nil;
    linkActionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                  delegate:self 
                                         cancelButtonTitle:NSLocalizedString(@"actionsheet_link_cancel", @"Title for the 'Cancel' button in the actionsheet when tapping on a link in the DetailVC")
                                    destructiveButtonTitle:nil 
                                         otherButtonTitles:NSLocalizedString(@"actionsheet_link_open_in_safari", @"Title for the 'Open in Safari' button in the actionsheet when tapping on a link in the DetailVC"), nil ];
    linkActionSheet.delegate = self;
    [linkActionSheet showInView:self.view];
}

-(void)setupArticleContentView
{
    LOG_CURRENT_FUNCTION()
    
    [self setupArticleContentViewWithArticleTitle:[self.blogEntry title] 
                                        articleId:[self.blogEntry articleId]
                                          webLink:[NSURL URLWithString:[self.blogEntry webLink]]
                                     categoryName:[self.blogEntry categoryName] 
                                  descriptionText:[self.blogEntry descriptionText]  
                                  relatedArticles:[self.blogEntry relatedArticles]   
                                     remoteImages:[self.blogEntry remoteImages] 
                                      publishDate:[self.blogEntry publishingDate]
                                   videoEmbedCode:[self.blogEntry videoEmbedCode]
                                         template:[self.blogEntry tempate]];
    return;
}


- (void)configureView
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    
    self.archiveLabel.text = NSLocalizedString(@"title_related_articles_detail_vc", @"Archive label");
    
    
    [_contentScrollView scrollRectToVisible:CGRectMake(0, 0, 320, 10) animated:NO];
    
    //if article still needs to be loaded, show loading view
    if (_isShowingArticleFromLocalDatabase==NO && _isLoadingCurrentArticle==YES) 
    {        
        [self setIsLoadingViewHidden:NO];
        
        return;
    }
    else if(_isShowingArticleFromLocalDatabase==NO && _isLoadingCurrentArticle==NO)
    {
        DBLog(@"_isShowingArticleFromLocalDatabase= NO, _isLoadingCurrentArticle==NO");
    }
    
    //set up the view in case the article is already here
    else 
    {    
        //article already loaded,
        //set up the article content view
        [self setupArticleContentView];
    }
}

-(NSString*)wrapDTRichtext:(NSString*)richText
{
    NSString * dbFile = [[NSBundle mainBundle] pathForResource:@"DTWrapper" ofType:@"html"];
    NSString * contents = [NSString stringWithContentsOfFile:dbFile encoding:NSUTF8StringEncoding error:nil];
    return [NSString stringWithFormat:contents,richText];
}

-(void)setupUIElementsForBlogEntryTemplate:(NSString*)template
{
    if ([template compare:kFKArticleTemplateDefault]==NSOrderedSame) {
        [self.articleContentView addSubview:self.showPictureSlideshowButton];
        [self.playVideoButton removeFromSuperview];
        [self.articleVideoView removeFromSuperview];
    }
    
    /*
    else if ([self.blogEntry.tempate compare:kFKArticleTemplateIgnanTV]==NSOrderedSame) {
        [self.showPictureSlideshowButton removeFromSuperview];
        [self.articleContentView addSubview:self.playVideoButton];
        [self.articleVideoView removeFromSuperview];
    }
    
    */
    
    else if ([template compare:kFKArticleTemplateDailyBasics]==NSOrderedSame) {
        [self.showPictureSlideshowButton removeFromSuperview];
        [self.playVideoButton removeFromSuperview];
        [self.articleVideoView removeFromSuperview];
    }
    
    else if ([template compare:kFKArticleTemplateMonifaktur]==NSOrderedSame) {
        [self.showPictureSlideshowButton removeFromSuperview];
        [self.playVideoButton removeFromSuperview];
        [self.articleVideoView removeFromSuperview];
    }
    
    else if ([template compare:kFKArticleTemplateVideo]==NSOrderedSame
             || [template compare:kFKArticleTemplateIgnanTV]==NSOrderedSame) {
        [self.showPictureSlideshowButton removeFromSuperview];
        [self.playVideoButton removeFromSuperview];
        [self.articleContentView addSubview:self.articleVideoView];
    }
    
    else if ([template compare:kFKArticleTemplateAicuisine]==NSOrderedSame) {
        [self.articleContentView addSubview:self.showPictureSlideshowButton];
        [self.playVideoButton removeFromSuperview];
        [self.articleVideoView removeFromSuperview];
    }
    
    else if ([template compare:kFKArticleTemplateItravel]==NSOrderedSame) {
        [self.articleContentView addSubview:self.showPictureSlideshowButton];
        [self.playVideoButton removeFromSuperview];
        [self.articleVideoView removeFromSuperview];
    }
}

- (IBAction)showMercedes:(id)sender {
    
    NSError* error = nil;
	GATrackEvent(&error, @"IGNDetailViewController", @"showMercedes", @"", -1);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAdressForMercedesPage]];
}

-(NSURL*)currentImageThumbURL
{
    NSURL* url = nil;
    
    if(self.currentArticleId!=nil)
    {
        NSString *encodedString = [[NSString alloc] initWithFormat:@"%@?%@=%@",kAdressForImageServer,kArticleId,self.currentArticleId];
        url = [[NSURL alloc] initWithString:encodedString];
    }
    
    return url;
}

-(void)setupArticleContentViewWithArticleTitle:(NSString*)title
                                     articleId:(NSString*)articleID
                                       webLink:(NSURL*)articleWebLink
                                  categoryName:(NSString*)categoryName
                               descriptionText:(NSString*)descriptionText
                               relatedArticles:(NSArray*)relatedArticles
                                  remoteImages:(NSArray*)remoteImages
                                   publishDate:(NSDate*)publishDate
                                videoEmbedCode:(NSString*)videoEmbedCode
                                      template:(NSString*)articleTemplate
{
    
#define DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW true
#define SHOW_DEBUG_COLORS false
    
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
        LOG_CURRENT_FUNCTION()
        
        
    NSLog(@"articleTemplate: %@", articleTemplate);
    [self setupUIElementsForBlogEntryTemplate:articleTemplate];
        
        
    self.currentArticleId = articleID;
    self.articleTitle = title;
    self.articleWeblink = articleWebLink;
    self.articleDescription = descriptionText;
    self.remoteImagesArray = [NSArray arrayWithArray:remoteImages];
    
    CGSize finalSizeForArticleContentView = CGSizeMake(0, 0);
    CGFloat contentViewWidth = 320.0f;
    CGRect tempRect = CGRectMake(0, 0, 0, 0);
    CGSize tempSize = CGSizeMake(0, 0);
    
    if ([videoEmbedCode length]>0) {
        
        CGFloat videoWidth = 950.0f;
        CGFloat videoHeight = 534.0f;
        CGFloat videoNewWidth = 310.0f;
        CGFloat videoNewHeight = videoNewWidth*videoHeight/videoWidth;
        NSString* videoDescriptionText = [NSString stringWithFormat:@"<html><head><title></title><style type='text/css'>*{ padding:0; margin:0; }</style></head><body><div style=\"width:%fpx; height:%fpx;\">%@</div></body></html>", videoNewWidth, videoNewHeight, videoEmbedCode];
        [self.articleVideoWebView loadHTMLString:videoDescriptionText baseURL:nil];
        CGRect oldFrame = self.articleVideoView.frame;
        self.articleVideoView.frame = CGRectMake(oldFrame.origin.x, 5.0f, oldFrame.size.width, oldFrame.size.height);
    }
    else
    {
        [self triggerLoadingDetailImageWithArticleId:self.currentArticleId
                                        forImageView:self.entryImageView];
    }
    
    //add the imageViewSize to the finalSizeForArticleContentView
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
    DBLog(@"adding the imageViewSize to the finalSizeForArticleContentView...");
    
    finalSizeForArticleContentView = CGSizeMake(contentViewWidth, _entryImageView.frame.origin.y+_entryImageView.bounds.size.height);
    
    //set up the button for showing pictures
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
    DBLog(@"setting up the button for showing pictures...");
    
    if ([remoteImages isKindOfClass:[NSArray class]]) {
        NSString *showPicturesButtonText = [NSString stringWithFormat:NSLocalizedString(@"fotos_button_title", @"Title of the 'Fotos' button on the Detail View Controller"),[remoteImages count]];
        [self.showPictureSlideshowButton setTitle:showPicturesButtonText forState:UIControlStateNormal];
    }
    
    //set up the title
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
    DBLog(@"setting up the title...");
    
    self.titleLabel.text = [title uppercaseString];
    
    //set up the date label
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
    DBLog(@"setting up the date label...");
    
    tempRect = self.dateLabel.frame;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString* publishDateString = [formatter stringFromDate:publishDate];
    CGSize publishDateSize = [publishDateString sizeWithFont:self.dateLabel.font];
    DBLog(@"publishDateSize: %@", NSStringFromCGSize(publishDateSize));
    
    self.dateLabel.frame = CGRectMake(tempRect.origin.x, tempRect.origin.y, publishDateSize.width, tempRect.size.height);
    self.dateLabel.text = publishDateString;
    
    tempRect = self.dateLabel.frame;
    
    //set up the category name
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
    DBLog(@"setting up the category name... categoryName: %@", categoryName);
    
    if (categoryName!=nil) 
    {
        NSString *category = categoryName;
        NSString *categoryName = @" ∙ "; //special characters: ∙ , ●
        
        categoryName = [categoryName stringByAppendingString:category];
        
        self.categoryLabel.text = categoryName;
        self.categoryLabel.frame = CGRectMake(tempRect.origin.x+tempRect.size.width, tempRect.origin.y, 100, tempRect.size.height);
    }
    
    //add the title, date and category labels size to the finalSizeForArticleContentView
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
    DBLog(@"adding the title, date and category labels size to the finalSizeForArticleContentView...");
    
    tempSize = finalSizeForArticleContentView;
    finalSizeForArticleContentView = CGSizeMake(tempSize.width, tempSize.height+_titleLabel.bounds.size.height+_categoryLabel.bounds.size.height+(_titleLabel.frame.origin.y-tempSize.height));
    
    if(SHOW_DEBUG_COLORS)
    {
        self.dateLabel.backgroundColor = [UIColor blueColor];
        self.titleLabel.backgroundColor = [UIColor purpleColor];
        self.categoryLabel.backgroundColor = [UIColor redColor];
    }
    
    
    NSString* finalRichText = [self wrapDTRichtext:descriptionText];
    
    // Load HTML data
	NSData *data = [finalRichText dataUsingEncoding:NSUTF8StringEncoding];
	
	// Create attributed string from HTML
	CGSize maxImageSize = CGSizeMake(self.view.bounds.size.width - 20.0, self.view.bounds.size.height - 20.0);
	
	// example for setting a willFlushCallback, that gets called before elements are written to the generated attributed string
	void (^callBackBlock)(DTHTMLElement *element) = ^(DTHTMLElement *element) {
		// if an element is larger than twice the font size put it in it's own block
		if (element.displayStyle == DTHTMLElementDisplayStyleInline && element.textAttachment.displaySize.height > 2.0 * element.fontDescriptor.pointSize)
		{
			element.displayStyle = DTHTMLElementDisplayStyleBlock;
		}
	};
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
                             @"Georgia", DTDefaultFontFamily,  @"black", DTDefaultLinkColor, callBackBlock, DTWillFlushBlockCallBack, nil];
	
	NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
    
    CGRect oldDTTextViewFrame = self.dtTextView.frame;
    
	self.dtTextView.contentView.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
	self.dtTextView.attributedString = string;
    
    CGSize oneTcontentSize = self.dtTextView.contentSize;
    
    self.dtTextView.frame = CGRectMake(oldDTTextViewFrame.origin.x, oldDTTextViewFrame.origin.y, oldDTTextViewFrame.size.width, oneTcontentSize.height);
    
    tempSize = finalSizeForArticleContentView;
    finalSizeForArticleContentView = CGSizeMake(tempSize.width, tempSize.height+self.dtTextView.frame.size.height);
    
    
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
    DBLog(@"(after decriptiontextview) finalSizeForArticleContentView: %@", NSStringFromCGSize(finalSizeForArticleContentView));
    
    //set the frame of the article content view
    if(DEBUG_ENABLE_FOR_SETUP_ARTICLE_CONTENT_VIEW)
        DBLog(@"setting the frame of the article content view...");
    
    tempRect = self.articleContentView.frame;
    CGFloat paddingBottomOfWebView = 10.0f;
    self.articleContentView.frame = CGRectMake(tempRect.origin.x, tempRect.origin.y, finalSizeForArticleContentView.width, finalSizeForArticleContentView.height+paddingBottomOfWebView);
    
    //add the articleContentView to the scrollView
    [self.contentScrollView addSubview:self.articleContentView];
    
    //setup related articles UI for presentation, don't add the view to the contentView yet
    [self setupRelatedArticlesUI:relatedArticles];
    
    
    
    
    
    
    
    CGSize finalSizeForArticleContentView2 = _articleContentView.bounds.size;
    tempSize = finalSizeForArticleContentView2;
   
    
    //set the frame of the article content view
    tempRect = _articleContentView.frame;
    _articleContentView.frame = CGRectMake(tempRect.origin.x, tempRect.origin.y, tempSize.width, tempSize.height);
    
    //set up the related articles view and add it to the contentScrollView
    CGPoint pointToDrawRelatedArticles = CGPointMake(0, self.articleContentView.bounds.size.height);
    CGSize nibSizeForRelatedArticles = self.relatedArticlesView.bounds.size;
    self.relatedArticlesView.frame = CGRectMake(pointToDrawRelatedArticles.x, pointToDrawRelatedArticles.y, nibSizeForRelatedArticles.width, nibSizeForRelatedArticles.height);
    [self.contentScrollView addSubview:self.relatedArticlesView];
    
    
#define WEBVIEW_PADDING_BOTTOM 0
    //set up the scrollView's final contentSize
    CGSize contentScrollViewFinalSize = CGSizeMake(320.0f, _relatedArticlesView.bounds.size.height+_articleContentView.bounds.size.height + WEBVIEW_PADDING_BOTTOM);
    self.contentScrollView.contentSize = contentScrollViewFinalSize;
    
    //set up the scrollView's final contentSize
    self.contentScrollView.contentSize = contentScrollViewFinalSize;
    
    
    [self setIsLoadingViewHidden:YES];
    
}

-(void)triggerLoadingRelatedImageWithArticleId:(NSString*)articleId forImageView:(UIImageView*)imageView
{
    NSString *encodedString = [[NSString alloc] initWithFormat:@"%@?%@=%@&%@=%@",kAdressForImageServer,kArticleId,articleId,kTLReturnImageType,kTLReturnRelatedArticleImage];
    NSURL* thumbURL = [[NSURL alloc] initWithString:encodedString];
    [self triggerLoadingImageAtURL:thumbURL forImageView:imageView];
}

-(void)triggerLoadingDetailImageWithArticleId:(NSString*)articleId forImageView:(UIImageView*)imageView
{
    NSString *encodedString = [[NSString alloc] initWithFormat:@"%@?%@=%@&%@=%@",kAdressForImageServer,kArticleId,articleId,kTLReturnImageType,kTLReturnDetailImage];
    NSURL* thumbURL = [[NSURL alloc] initWithString:encodedString];
    [self triggerLoadingImageAtURL:thumbURL forImageView:imageView];
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
    DBLog(@"setting up first related article...");
    
    if (firstRelatedArticle!=nil) {
        self.firstRelatedArticleTitleLabel.text = [firstRelatedArticle objectForKey:kFKArticleTitle];
        self.firstRelatedArticleCategoryLabel.text = [firstRelatedArticle objectForKey:kFKRelatedArticleCategoryText];
        self.firstRelatedArticleId = (NSString*)[firstRelatedArticle objectForKey:kFKArticleId];
        
        [self triggerLoadingRelatedImageWithArticleId:self.firstRelatedArticleId
                                         forImageView:self.firstRelatedArticleImageView];
    }
    
    //set up second related article
    if(DEBUG_ENABLE_FOR_SETUP_RELATED_ARTICLES_UI)
    DBLog(@"setting up second related article...");
    
    if (secondRelatedArticle!=nil) {
        self.secondRelatedArticleTitleLabel.text = [secondRelatedArticle objectForKey:kFKArticleTitle];
        self.secondRelatedArticleCategoryLabel.text = [secondRelatedArticle objectForKey:kFKRelatedArticleCategoryText];
        self.secondRelatedArticleId = (NSString*)[secondRelatedArticle objectForKey:kFKArticleId];
        
        [self triggerLoadingRelatedImageWithArticleId:self.secondRelatedArticleId
                                         forImageView:self.secondRelatedArticleImageView];
        
    }
    
    //set up third related article
    if(DEBUG_ENABLE_FOR_SETUP_RELATED_ARTICLES_UI)
    DBLog(@"setting up third related article...");
    
    if (thirdRelatedArticle!=nil) {
        self.thirdRelatedArticleTitleLabel.text = [thirdRelatedArticle objectForKey:kFKArticleTitle];
        self.thirdRelatedArticleCategoryLabel.text = [thirdRelatedArticle objectForKey:kFKRelatedArticleCategoryText];
        self.thirdRelatedArticleId = (NSString*)[thirdRelatedArticle objectForKey:kFKArticleId];
        
        [self triggerLoadingRelatedImageWithArticleId:self.thirdRelatedArticleId
                                         forImageView:self.thirdRelatedArticleImageView];
    }
    
    if(DEBUG_ENABLE_FOR_SETUP_RELATED_ARTICLES_UI)
    DBLog(@"finished setting up related articles!");
    
    //set the appropriate title for the toggle like button
    [self updateToggleLikeButtonTitle];
}

-(void)updateToggleLikeButtonTitle
{
    BOOL isFavourite = [self.appDelegate.userDefaultsManager isBlogEntryFavourite:[self currentArticleId]];
    NSString *likeTitle = isFavourite ? NSLocalizedString(@"button_title_unlike", @"Title of the 'Unlike' button on the Detail View Controller") : NSLocalizedString(@"button_title_like", @"Title of the 'Like' button on the Detail View Controller");
    [self.toggleLikeButton setTitle:likeTitle forState:UIControlStateNormal];
}

-(void)setupArticleContentViewWithRemoteDataDictionary:(NSDictionary*)articleDictionary
{
    LOG_CURRENT_FUNCTION()
    
    
    self.remoteArticleDictionary = articleDictionary;
    
    
    NSString *remoteContentArticleTitle = [articleDictionary objectForKey:kFKArticleTitle];
    NSString *remoteContentArticleWeblinkString = [articleDictionary objectForKey:kFKArticleWebLink];
    NSURL* remoteContentArticleWeblink = [NSURL URLWithString:remoteContentArticleWeblinkString];
    NSString *remoteContentArticleID = [articleDictionary objectForKey:kFKArticleId];
    NSString *remoteContentCategoryName = [articleDictionary objectForKey:kFKArticleCategoryName];
    NSString *remoteContentTemplate = [articleDictionary objectForKey:kFKArticleTemplate];
    
    
    NSString *remoteContentArticleDescriptionTextBase64 = [articleDictionary objectForKey:kFKArticleDescriptionText];
    NSString *remoteContentArticleDescriptionText = [[NSString alloc] initWithData:[NSData dataFromBase64String:remoteContentArticleDescriptionTextBase64] encoding:NSUTF8StringEncoding];
    
    NSString *remoteContentArticleVideoEmbedCodeBase64 = [articleDictionary objectForKey:kFKArticleVideoEmbedCode];
    NSString *remoteContentArticleVideoEmbedCode = [[NSString alloc] initWithData:[NSData dataFromBase64String:remoteContentArticleVideoEmbedCodeBase64] encoding:NSUTF8StringEncoding];
    
    NSArray *remoteContentRelatedArticles = [articleDictionary objectForKey:kFKArticleRelatedArticles];
    NSArray *remoteContentRemoteImages = [articleDictionary objectForKey:kFKArticleRemoteImages];
    id unconvertedBlogEntryPublishDate = [articleDictionary objectForKey:kFKArticlePublishingDate];
    
    NSNumber *blogEntryPublishDateSecondsSince1970 = nil;
    if ([unconvertedBlogEntryPublishDate isKindOfClass:[NSString class]])
    {
        [self.numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
        blogEntryPublishDateSecondsSince1970 = [self.numberFormatter numberFromString:unconvertedBlogEntryPublishDate];
    }
    else
    {
        blogEntryPublishDateSecondsSince1970 = unconvertedBlogEntryPublishDate;
    }
    
    NSDate *fDate = [NSDate dateWithTimeIntervalSince1970:[blogEntryPublishDateSecondsSince1970 floatValue]];
    
    [self setupArticleContentViewWithArticleTitle:remoteContentArticleTitle
                                        articleId:remoteContentArticleID
                                          webLink:remoteContentArticleWeblink
                                     categoryName:remoteContentCategoryName
                                  descriptionText:remoteContentArticleDescriptionText
                                  relatedArticles:remoteContentRelatedArticles
                                     remoteImages:remoteContentRemoteImages
                                      publishDate:fDate
                                   videoEmbedCode:remoteContentArticleVideoEmbedCode
                                         template:remoteContentTemplate];
    return;
}

#pragma mark - picture slideshow

- (IBAction)showPictureSlideshow:(id)sender
{
    self.isShowingImageSlideshow = YES;
    
    ImageSlideshowViewController *slideshowVC = [[ImageSlideshowViewController alloc] initWithNibName:@"ImageSlideshowViewController" bundle:nil];
    
    //set up the slideshowVC
    slideshowVC.remoteImagesArray = _remoteImagesArray;
    
    //show the slideshowVC
    slideshowVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentModalViewController:slideshowVC animated:YES];

}

-(void)handleDTViewTap:(id)sender
{
    DBLog(@"handleDTViewTap");
    
    [self tapAction:sender];
}

-(IBAction)tapAction:(id)sender
{
    DBLog(@"tapAction ");
    
    __block __typeof__(self) blockSelf = self;
    double delayInSeconds = .1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if(_isShowingLinkOptions)
            return;
        
        if (blockSelf.navigationController.navigationBar.isHidden)
        {
            [blockSelf setNavigationBarAndToolbarHidden:NO animated:YES];
        }
        else
        {
            [blockSelf setNavigationBarAndToolbarHidden:YES animated:YES];
        }
        
    });
}

-(void)setNavigationBarAndToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
#define IGNANT_TOOLBAR_HEIGHT 50.0f
#define IGNANT_GRADIENT_HEIGHT 4.0f
#define ANIMATION_DURATION UINavigationControllerHideShowBarDuration
    
    LOG_CURRENT_FUNCTION()
    
        
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
    CGFloat statusBarHeight = 20.0f;
    CGFloat shareAndMoreToolbarHeight = 50.0f;
	CGFloat scrollViewHeight = DeviceHeight-navigationBarHeight-statusBarHeight-shareAndMoreToolbarHeight;
    
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
        
        DBLog(@"newScrollViewFrame: %@ shareAndMoreToolbarHeight: %f scrollViewHeight: %f", NSStringFromCGRect(newScrollViewFrame), shareAndMoreToolbarHeight, scrollViewHeight);
        
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
    if (![self.appDelegate.facebook isSessionValid]) {
        DBLog(@"facebook: session NOT valid");
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_likes",
                                @"read_stream",
                                nil];
        [self.appDelegate.facebook authorize:permissions];
        return;
    }
    
    NSString* infoLinkToArticleMainPage = [self.articleWeblink absoluteString];
    NSString* infoNameOfArticle = self.articleTitle;
    NSString* infoDescriptionForArticle = self.articleDescription;
    NSString* substringInfoDescriptionForArticle = [infoDescriptionForArticle isKindOfClass:[NSString class]] ? [infoDescriptionForArticle substringWithRange:NSMakeRange(0, 200)] : @"";
    substringInfoDescriptionForArticle = [substringInfoDescriptionForArticle stringByAppendingFormat:@"..."];
    
    NSString* infoLinkToThumbForArticle = [[self currentImageThumbURL] absoluteString];
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
    
    NSError* error = nil;
	GATrackEvent(&error, @"IGNDetailViewController", @"postToFacebook", self.currentArticleId, -1);
	
}

-(void)postToPinterest
{
   DBLog(@"should post to pinterest");
}

-(void)postToTwitter
{
    BOOL canTweet = [TWTweetComposeViewController canSendTweet];
    
    if (!canTweet) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"" 
                                                     message:NSLocalizedString(@"ui_alert_message_you_need_to_be_logged_in_with_twitter", nil)
                                                    delegate:self 
                                           cancelButtonTitle:NSLocalizedString(@"ui_alert_dismiss", nil)
                                           otherButtonTitles:nil];
        [av show];
        
        return;
    }
    else {
		
        __block __typeof__(self) blockSelf = self;
		
		if ([blockSelf.articleTitle length]==0 || [[blockSelf.articleWeblink absoluteString] length]==0) {
			DBLog(@"articleTitle or articleWeblink is nil");
			return;
		}
		
        NSString* tweet = [NSString stringWithFormat:@"☞ %@ | %@ via @ignantblog", blockSelf.articleTitle, blockSelf.articleWeblink];
        
        TWTweetComposeViewController *tweetVC = [[TWTweetComposeViewController alloc] init];
        [tweetVC setInitialText:tweet];        
        [tweetVC setCompletionHandler:^(TWTweetComposeViewControllerResult result){
			
            switch (result) {
                case TWTweetComposeViewControllerResultCancelled:
                {
                    break;
                }
                case TWTweetComposeViewControllerResultDone:
                {
                    NSError* error = nil;
					GATrackEvent(&error, @"IGNDetailViewController", @"postToTwitter", blockSelf.currentArticleId, -1);
                    break;
                }
                default:
                    break;
            }
            
            //dismiss the tweet composition view controller modally
            [blockSelf dismissModalViewControllerAnimated:YES];
        }];
        
        
        [self presentModalViewController:tweetVC animated:YES];
    }
    
    DBLog(@"canTweet: %@", canTweet ? @"TRUE" : @"FALSE");
    
    DBLog(@"should post to twitter"); 
}

#pragma mark - show mosaik / more
-(void)showMosaic
{
    IGNMosaikViewController *mosaikVC = self.appDelegate.mosaikViewController;
    mosaikVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    mosaikVC.parentNavigationController = self.navigationController;
    
	
    [self.navigationController presentModalViewController:mosaikVC animated:YES];
    
}

- (IBAction)showShare:(id)sender {
    
    
    NSError* error = nil;
	GATrackEvent(&error, @"IGNDetailViewController", @"showShare", self.currentArticleId, -1);
    
    
    UIActionSheet *shareActionSheet = nil;
    
    if ([IGNAppDelegate isIOS5]) {
        shareActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"actionsheet_share_cancel", @"Title of the 'Cancel' button in the actionsheet when tapping on share") 
                                         destructiveButtonTitle:nil 
                                              otherButtonTitles:NSLocalizedString(@"actionsheet_share_facebook", @"Title of the 'Facebook' button in the actionsheet when tapping on share"),NSLocalizedString(@"actionsheet_share_twitter", @"Title of the 'Twitter' button in the actionsheet when tapping on share"), nil ];
    }
    else {
        shareActionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"actionsheet_share_cancel", @"Title of the 'Cancel' button in the actionsheet when tapping on share") 
                                         destructiveButtonTitle:nil 
                                              otherButtonTitles:NSLocalizedString(@"actionsheet_share_facebook", @"Title of the 'Facebook' button in the actionsheet when tapping on share"), nil ];
    }
    [shareActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    _isShowingLinkOptions = false;
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    _isShowingLinkOptions = false;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(_isShowingLinkOptions){
        int openInSafariButtonIndex = 0;
        if (buttonIndex==openInSafariButtonIndex) {
            
            NSError* error = nil;
			GATrackEvent(&error, @"IGNDetailViewController", @"openInSafari", [_linkOptionsUrl absoluteString], 10);
            
            DBLog(@"openInSafari: %@", _linkOptionsUrl);
            [[UIApplication sharedApplication] openURL:_linkOptionsUrl];
        }
    }
    else
    if ([IGNAppDelegate isIOS5]) {
        int facebookButtonIndex = 0;
        int twitterButtonIndex = 1;
        
        if (buttonIndex==facebookButtonIndex) {
            [self postToFacebook];
        }
        
        else if (buttonIndex==twitterButtonIndex) {
            [self postToTwitter];
        }
    }
    else {
        int facebookButtonIndex = 0;
        
        if (buttonIndex==facebookButtonIndex) {
            [self postToFacebook];
        }
    }
    
    _isShowingLinkOptions = false;
}

- (IBAction)showMore:(id)sender {
    IGNMoreOptionsViewController *moreOptionsVC = self.appDelegate.moreOptionsViewController;
    [self.navigationController pushViewController:moreOptionsVC animated:YES];
}


-(void)importRemoteArticleDictionary
{
    LOG_CURRENT_FUNCTION()
    
    self.isImportingRelatedArticle = true;
    [self.importer importOneArticleFromDictionary:self.remoteArticleDictionary forceSave:YES];
}

-(IBAction)toggleLike:(id)sender {
    
	
	NSError* error = nil;
	
	GATrackEvent(&error, @"IGNDetailViewController", @"toggleLike", self.currentArticleId, 10);
	
    //if the article is shown with remote data, trigger importing it if necessary
    if(!self.isShowingArticleFromLocalDatabase)
    {
        [self importRemoteArticleDictionary];
    }
    
    [self.appDelegate.userDefaultsManager toggleIsFavouriteBlogEntry:[self currentArticleId]];
    [self updateToggleLikeButtonTitle];
}

-(void)showRelatedArticle:(id)sender
{
    NSString *articleId = nil;
    
	NSError* error = nil;
	GATrackEvent(&error, @"IGNDetailViewController", @"showRelated", self.currentArticleId, 10);
	
	
    DBLog(@"trying to showRelatedArticle: %d", [sender tag]);
    
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
    
    DBLog(@"articleId: %@", articleId);
    
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
    if (!self.nextDetailViewController) {
        self.nextDetailViewController = [[IGNDetailViewController alloc] initWithNibName:@"IGNDetailViewController_iPhone" bundle:nil];
    }
    
    DBLog(@"articleIdChosen: %@", articleId);
    self.nextDetailViewController.viewControllerToReturnTo = self.viewControllerToReturnTo;
    
    if(entry)
    {
        DBLog(@"entry exists, do not load");
        self.nextDetailViewController.blogEntry = entry;
        self.nextDetailViewController.isShowingArticleFromLocalDatabase = YES;        
    }
    
    else 
    {
        DBLog(@"entry DOES NOT exist, DO! load, :%@", articleId);
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
    
    NSString* lang = [self currentPreferredLanguage];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetSingleArticle,kParameterAction,self.currentArticleId,kArticleId, lang,kParameterLanguage, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
    
    DBLog(@"DETAIL encodedString go: %@ language: %@",encodedString, lang);
    
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:encodedString]];
	[request setDelegate:self];
	[request startAsynchronous];
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    DBLog(@"requestStarted");
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    _isLoadingCurrentArticle = NO;
    self.remoteArticleJSONString = [request responseString];
    
    DBLog(@"[request responseString]: %@", [request responseString]);
    [self.importer importJSONStringForSingleArticle:[request responseString] forceSave:NO];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    _isLoadingCurrentArticle = NO;
        
    [self setIsCouldNotLoadDataViewHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - IgnantImporterDelegate

-(void)importerDidStartParsingSingleArticle:(IgnantImporter*)importer
{
    DBLog(@"importerDidStartParsingSingleArticle");
    
    __block __typeof__(self) blockSelf = self;
    if(blockSelf.isImportingRelatedArticle)
    {
        DBLog(@"failed importing for favorite");
    }
    else
    {
        DBLog(@"failed  importing related article");
    }
}

-(void)importer:(IgnantImporter*)importer didFinishParsingSingleArticleWithDictionary:(NSDictionary*)articleDictionary
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    __block __typeof__(self) blockSelf = self;
    if(blockSelf.isImportingRelatedArticle)
    {
        DBLog(@"finished importing related article");
        blockSelf.isImportingRelatedArticle = false;
    }
    else
    {
        _didLoadContentForRemoteArticle = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [blockSelf setupArticleContentViewWithRemoteDataDictionary:articleDictionary];
            [blockSelf configureView];
        });
    }
}

-(void)importer:(IgnantImporter*)importer didFailParsingSingleArticleWithDictionary:(NSDictionary*)articleDictionary
{
    DBLog(@"didFailParsingSingleArticleWithDictionary");
    
#warning TODO: handle failing parsing the single article dictionary
	
    __block __typeof__(self) blockSelf = self;
    if(blockSelf.isImportingRelatedArticle)
    {
        DBLog(@"failed importing for favorite");
        blockSelf.isImportingRelatedArticle = false;
    }
    else
    {
       DBLog(@"failed  importing related article");
    }
}

#pragma mark - UIGestureRecognizer delegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    
    if ([touch.view isKindOfClass:[DTLinkButton class]]) {
        return NO;
    }
    
    if (self.showSlideshowButton.superview !=nil ) {
        if ([touch.view isDescendantOfView:self.showSlideshowButton]) {
            return NO;
        }
    }
    
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
    self.couldNotLoadDataLabel.text =  NSLocalizedString(@"could_not_load_data_for_this_article", @"Title of the 'couldNotLoadDataLabel'");
    return defaultView;
}


-(IBAction)playVideo:(id)sender
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    NSString *encodedString = [[NSString alloc] initWithFormat:@"%@?%@=%@",kAdressForVideoServer,kArticleId,self.currentArticleId];
    NSURL* videoUrl = [[NSURL alloc] initWithString:encodedString];
    [self.playVideoButton removeFromSuperview];
    
    MPMoviePlayerViewController *moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoUrl];        
    [self presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
    
    DBLog(@"start playing video: %@", videoUrl);
}

#pragma mark - Custom Views on Text
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame
{
	DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
	button.URL = url;
	button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
	button.GUID = identifier;
	
	// use normal push action for opening URL
	[button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}

-(UIColor*)newRandomColor
{
    UIColor* c = [[UIColor alloc] initWithRed:arc4random()%255/255 green:arc4random()%255/255 blue:arc4random()%255/255 alpha:1.0f];
    
    return c;
}

- (BOOL)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView shouldDrawBackgroundForTextBlock:(DTTextBlock *)textBlock frame:(CGRect)frame context:(CGContextRef)context forLayoutFrame:(DTCoreTextLayoutFrame *)layoutFrame
{
	UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:10];
    
	CGColorRef color = [textBlock.backgroundColor CGColor];
	if (color)
	{
		CGContextSetFillColorWithColor(context, color);
		CGContextAddPath(context, [roundedRect CGPath]);
		CGContextFillPath(context);
		
		CGContextAddPath(context, [roundedRect CGPath]);
		CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
		CGContextStrokePath(context);
		return NO;
	}
	
	return YES;
}

- (void)linkPushed:(DTLinkButton *)button
{
	NSURL *URL = button.URL;
	
	if ([[UIApplication sharedApplication] canOpenURL:[URL absoluteURL]])
	{
        DBLog(@"show link options");
        [self showLinkOptions:URL];
	}
}

@end
