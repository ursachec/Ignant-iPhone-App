//
//  IGNDetailViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import "IGNDetailViewController.h"

#import "Constants.h"

#import "HJObjManager.h"
#import "HJManagedImageV.h"

#import "BlogEntry.h"
#import "Image.h"

#import "ImageSlideshowViewController.h"

#import "IGNMoreOptionsViewController.h"

#import "RelatedArticleViewController.h"

#import "IgnantLoadingView.h"

#import "IgnantImporter.h"
#import "NSString+HTML.h"
#import "NSData+Base64.h"


#import "IGNAppDelegate.h"

//imports for ASIHTTPRequest
#import "ASIHTTPRequest.h"
#import "NSURL+stringforurl.h"


@interface IGNDetailViewController ()
{
    NSArray *_remoteImagesArray;
    BOOL _isLoadingCurrentArticle;
    
    NSString *_firstRelatedArticleId;
    NSString *_secondRelatedArticleId;
    NSString *_thirdRelatedArticleId;
}

-(void)setupArticleContentViewWithRemoteDataDictionary:(NSDictionary*)articleDictionary;

@property (nonatomic, retain) NSString *firstRelatedArticleId;
@property (nonatomic, retain) NSString *secondRelatedArticleId;
@property (nonatomic, retain) NSString *thirdRelatedArticleId;


@property (nonatomic, retain) IgnantImporter *importer;

//properties for navigating through remote articles
@property (strong, nonatomic) NSArray *relatedArticlesIds;


//article UI stugg
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UIButton *showPictureSlideshowButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (retain, nonatomic) IBOutlet UIImageView *entryImageView;

//properties related to the navigation
@property (strong, nonatomic) BlogEntry* nextBlogEntry;
@property (strong, nonatomic) BlogEntry* previousBlogEntry;

@property(retain, nonatomic) IGNDetailViewController* navigationDetailViewController;
@property(retain, nonatomic) UIButton *previousArticleButton;
@property(retain, nonatomic) UIButton *nextArticleButton;

@property(retain, nonatomic)NSArray *remoteImagesArray;

//cluster views
@property (retain, nonatomic) IBOutlet UIView *articleContentView;
@property (retain, nonatomic) IBOutlet UIView *relatedArticlesView;


//loading view
@property (retain, nonatomic) IBOutlet UIView *loadingView;


-(void)configureView;
-(void)setupNavigationButtons;

- (IBAction)showPictureSlideshow:(id)sender;

-(void)setupLoadingView;

-(void)startLoadingSingleArticle;

@end

#pragma mark - 

@implementation IGNDetailViewController
@synthesize importer = _importer;

@synthesize firstRelatedArticleId = _firstRelatedArticleId;
@synthesize secondRelatedArticleId = _secondRelatedArticleId;
@synthesize thirdRelatedArticleId = _thirdRelatedArticleId;

@synthesize didLoadContentForRemoteArticle = _didLoadContentForRemoteArticle;

@synthesize currentArticleId, relatedArticlesIds;

@synthesize isShowingArticleFromLocalDatabase = _isShowingArticleFromLocalDatabase;

@synthesize shareAndMoreToolbar = _shareAndMoreToolbar;
@synthesize descriptionWebView = _descriptionWebView;
@synthesize articleContentView = _articleContentView;
@synthesize relatedArticlesView = _relatedArticlesView;

@synthesize previousArticleButton = _previousArticleButton;
@synthesize nextArticleButton = _nextArticleButton;

@synthesize dateLabel = _dateLabel;
@synthesize categoryLabel = _categoryLabel;

@synthesize showPictureSlideshowButton = _showPictureSlideshowButton;
@synthesize titleLabel = _titleLabel;

@synthesize descriptionTextView = _descriptionTextView;
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

@synthesize loadingView = _loadingView;

@synthesize currentBlogEntryIndex = _currentBlogEntryIndex;
@synthesize nextBlogEntryIndex = _nextBlogEntryIndex;
@synthesize previousBlogEntryIndex = _previousBlogEntryIndex;


@synthesize nextDetailViewController = _nextDetailViewController;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        self.firstRelatedArticleId = @"";
        self.secondRelatedArticleId = @"";
        self.thirdRelatedArticleId = @"";
        
        
        _didLoadContentForRemoteArticle = NO;
        
        IGNAppDelegate *appDelegate = (IGNAppDelegate*)[[UIApplication sharedApplication] delegate];        
        _importer = [[IgnantImporter alloc] init];
        _importer.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
        _importer.delegate = self;
        
        
    }
    return self;
}

- (void)dealloc
{
#warning IMPLEMENT dealloc
    [_titleLabel release];
    [_categoryLabel release];
    [_dateLabel release];
    [_entryImageView release];
    [_articleContentView release];
    [_contentScrollView release];
    [_relatedArticlesView release];
    [_shareAndMoreToolbar release];
    [_descriptionWebView release];
    [_firstRelatedArticleImageView release];
    [_secondRelatedArticleImageView release];
    [_thirdRelatedArticleImageView release];
    [_firstRelatedArticleTitleLabel release];
    [_secondRelatedArticleTitleLabel release];
    [_thirdRelatedArticleTitleLabel release];
    [_firstRelatedArticleCategoryLabel release];
    [_secondRelatedArticleCategoryLabel release];
    [_thirdRelatedArticleCategoryLabel release];
    [super dealloc];
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

    
    CGSize sizeOfButtons = CGSizeMake(35.0f, 35.0f);
    
    //add the back-to-start button
    UIImage *backButtonImage = [UIImage imageNamed:@"navigationButtonStart.png"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat ratio = .5;
    backButton.frame = CGRectMake(0, 0, 122*ratio, 57*ratio);
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(handleBack:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
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
    self.dateLabel = nil;
    self.categoryLabel = nil;
    self.titleLabel = nil;
    
    [self setEntryImageView:nil];
    [self setArticleContentView:nil];
    [self setContentScrollView:nil];
    [self setRelatedArticlesView:nil];
    [self setShareAndMoreToolbar:nil];
    [self setDescriptionWebView:nil];
    [self setFirstRelatedArticleImageView:nil];
    [self setSecondRelatedArticleImageView:nil];
    [self setThirdRelatedArticleImageView:nil];
    [self setFirstRelatedArticleTitleLabel:nil];
    [self setSecondRelatedArticleTitleLabel:nil];
    [self setThirdRelatedArticleTitleLabel:nil];
    [self setFirstRelatedArticleCategoryLabel:nil];
    [self setSecondRelatedArticleCategoryLabel:nil];
    [self setThirdRelatedArticleCategoryLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if (_isShowingArticleFromLocalDatabase) 
    {
            [self configureView];
    }
    else if(!_didLoadContentForRemoteArticle)
    {
        [self startLoadingSingleArticle];
    }
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


#pragma mark - Navigation options

-(void)handleBack:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)navigateToNextArticle
{    
    if (_navigationDetailViewController==nil) {
        self.navigationDetailViewController = [[[IGNDetailViewController alloc] initWithNibName:@"IGNDetailViewController_iPhone" bundle:nil] autorelease];
    }
    
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
    
    [self.navigationController pushViewController:_navigationDetailViewController animated:YES];
}

-(void)navigateToPreviousArticle
{

    if (_navigationDetailViewController==nil) {
        self.navigationDetailViewController = [[[IGNDetailViewController alloc] initWithNibName:@"IGNDetailViewController_iPhone" bundle:nil] autorelease];
    }
    
    self.navigationDetailViewController.fetchedResults = _fetchedResults;
    self.navigationDetailViewController.currentBlogEntryIndex = _previousBlogEntryIndex;
    self.navigationDetailViewController.isShowingArticleFromLocalDatabase = YES;
    
    if (_currentBlogEntryIndex-1>=0) {
        self.navigationDetailViewController.previousBlogEntryIndex = _previousBlogEntryIndex-1;
    } 
    else{
        self.navigationDetailViewController.previousBlogEntryIndex = -1;
    }
    
    
    if(_currentBlogEntryIndex<_fetchedResults.count)
    {
        self.navigationDetailViewController.nextBlogEntryIndex = _currentBlogEntryIndex;
    }
    else{
        self.navigationDetailViewController.nextBlogEntryIndex = -1;
    }
    
    
    self.navigationDetailViewController.blogEntry = self.previousBlogEntry;
    
    [self.navigationController pushViewController:_navigationDetailViewController animated:YES];
}


-(void)setupNavigationButtons
{
    
    //set up view for when the article is not in the local database and has to be loaded
    if (_isLoadingCurrentArticle) {
        
        
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
        if (_previousBlogEntryIndex!=-1) {
            previousObject = [_fetchedResults objectAtIndex:_previousBlogEntryIndex];
        }
        self.previousBlogEntry = (BlogEntry*)previousObject;
        
        //set up nextObject
        NSManagedObject *nextObject = nil;
        if (_nextBlogEntryIndex!=-1) {
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





- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    
    CGRect frame = aWebView.frame;
    frame.size.height = 1;
    aWebView.frame = frame;
    CGSize fittingSize = [aWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    aWebView.frame = frame;
    
    
//    CGSize fittingSizeNumberTwo = [_descriptionWebView sizeThatFits:CGSizeZero];
    
    NSLog(@"fittingSize; %@", NSStringFromCGSize(fittingSize));
    
//    CGRect tempRect;
//    CGSize tempSize;
//    
//    CGFloat marginTopForDescriptionWebView = 5.0f;
//    CGSize finalSizeForArticleContentView = _articleContentView.bounds.size;
//    
//    
//    _descriptionWebView.frame = CGRectMake(aWebView.frame.origin.x, finalSizeForArticleContentView.height+marginTopForDescriptionWebView, _descriptionWebView.bounds.size.width, fittingSize.height+10);
//    
//    //add the description webview size to the finalSizeForArticleContentView
//    tempSize = finalSizeForArticleContentView;
//    finalSizeForArticleContentView = CGSizeMake(tempSize.width, tempSize.height+fittingSize.height);
//    
//    
//    NSLog(@"(final webview) finalSizeForArticleContentView: %@", NSStringFromCGSize(finalSizeForArticleContentView));
//    
//    
//    
//    //set the frame of the article content view
//    tempRect = _articleContentView.frame;
//    _articleContentView.frame = CGRectMake(tempRect.origin.x, tempRect.origin.y, finalSizeForArticleContentView.width, finalSizeForArticleContentView.height+10.0f);
//    
//    //add the articleContentView to the scrollView
//    [self.contentScrollView addSubview:self.articleContentView];

}

#pragma mark - setting up the view

-(void)setupArticleContentView
{
    CGSize finalSizeForArticleContentView = CGSizeMake(0, 0); 
    CGFloat contentViewWidth = 320.0f;
    CGRect tempRect = CGRectMake(0, 0, 0, 0);
    CGSize tempSize = CGSizeMake(0, 0);
    
    //set up the blog entry imageview
    NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    applicationDocumentsDir = [applicationDocumentsDir stringByAppendingFormat:@"thumbs/"];
    NSString *storePath = [applicationDocumentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg",self.blogEntry.thumbIdentifier]];
    UIImage *someImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:storePath]];
    _entryImageView.image = someImage;
    
    
    //add the imageViewSize to the finalSizeForArticleContentView
    finalSizeForArticleContentView = CGSizeMake(contentViewWidth, _entryImageView.frame.origin.y+_entryImageView.bounds.size.height);
    NSLog(@"(imageView) finalSizeForArticleContentView: %@", NSStringFromCGSize(finalSizeForArticleContentView));    
    
    //set up the button for showing pictures
    NSString *showPicturesButtonText = [NSString stringWithFormat:@"%d Fotos",_remoteImagesArray.count];
    [self.showPictureSlideshowButton setTitle:showPicturesButtonText forState:UIControlStateNormal];
    
    //set up the title, date and category labels
    _titleLabel.text = [_blogEntry.title uppercaseString];
    
    tempRect = _dateLabel.frame;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    _dateLabel.text = [formatter stringFromDate:_blogEntry.publishingDate];
    [formatter release];
    
#warning LOAD category by using live data!
    
    
    NSString *category = _blogEntry.categoryName;
    
    NSString *categoryName = @"∙ "; //special characters: ∙ , ●
    
    categoryName = [categoryName stringByAppendingString:category];
    
    _categoryLabel.text = categoryName;
    _categoryLabel.frame = CGRectMake(tempRect.origin.x+tempRect.size.width, tempRect.origin.y, 100, tempRect.size.height);
    
    
    //add the title, date and category labels size to the finalSizeForArticleContentView
    tempSize = finalSizeForArticleContentView;
    finalSizeForArticleContentView = CGSizeMake(tempSize.width, tempSize.height+_titleLabel.bounds.size.height+_categoryLabel.bounds.size.height+(_titleLabel.frame.origin.y-tempSize.height));
    NSLog(@"(title, date, category) finalSizeForArticleContentView: %@", NSStringFromCGSize(finalSizeForArticleContentView));
    
    
    //set up the description textview
    //set up the user interface for the current objects    
    CGFloat marginTop = 5.0f;
    _descriptionTextView.text = _blogEntry.descriptionText;
    CGSize descriptionTextContentSize = _descriptionTextView.contentSize;
    CGRect descriptionTextviewFrame = _descriptionTextView.bounds;
    
    _descriptionTextView.frame = CGRectMake(descriptionTextviewFrame.origin.x, finalSizeForArticleContentView.height+marginTop, descriptionTextviewFrame.size.width, descriptionTextContentSize.height+10);
    
    //add the description textview size to the finalSizeForArticleContentView
    tempSize = finalSizeForArticleContentView;
    finalSizeForArticleContentView = CGSizeMake(tempSize.width, tempSize.height+descriptionTextContentSize.height);
    
    NSLog(@"(final) finalSizeForArticleContentView: %@", NSStringFromCGSize(finalSizeForArticleContentView));
    
    
    //set the frame of the article content view
    tempRect = _articleContentView.frame;
    _articleContentView.frame = CGRectMake(tempRect.origin.x, tempRect.origin.y, finalSizeForArticleContentView.width, finalSizeForArticleContentView.height+10.0f);
    
    //add the articleContentView to the scrollView
    [self.contentScrollView addSubview:self.articleContentView];
    
    
    
    
    
    
    //#############################################################################################
    //------------------------------------------------
    //---------------- RELATED ARTICLES --------------
    //------------------------------------------------
    
    
    NSArray *remoteContentRelatedArticles = _blogEntry.relatedArticles;
    

    
    if (remoteContentRelatedArticles == nil || [remoteContentRelatedArticles count]!=3) {
        return;
    }
    
 
    
   
    
    
    
    NSDictionary* firstRelatedArticle = [remoteContentRelatedArticles objectAtIndex:0];
    NSDictionary* secondRelatedArticle = [remoteContentRelatedArticles objectAtIndex:1];
    NSDictionary* thirdRelatedArticle = [remoteContentRelatedArticles objectAtIndex:2];
    
    //set up first related article
    if (firstRelatedArticle!=nil) {
        self.firstRelatedArticleTitleLabel.text = [firstRelatedArticle objectForKey:kFKArticleTitle];
        self.firstRelatedArticleCategoryLabel.text = [firstRelatedArticle objectForKey:kFKRelatedArticleCategoryText];
        
        NSString* imageBase64String =  [firstRelatedArticle objectForKey:kFKRelatedArticleBase64Thumbnail];
        UIImage *someImage = [[UIImage alloc] initWithData:[NSData dataFromBase64String:imageBase64String]];
        self.firstRelatedArticleImageView.image = someImage;   
        
      
        self.firstRelatedArticleId = (NSString*)[firstRelatedArticle objectForKey:kFKArticleId];
        
    }
    
    //set up second related article
    if (secondRelatedArticle!=nil) {
        self.secondRelatedArticleTitleLabel.text = [secondRelatedArticle objectForKey:kFKArticleTitle];
        self.secondRelatedArticleCategoryLabel.text = [secondRelatedArticle objectForKey:kFKRelatedArticleCategoryText];
        
        NSString* imageBase64String =  [secondRelatedArticle objectForKey:kFKRelatedArticleBase64Thumbnail];
        UIImage *someImage = [[UIImage alloc] initWithData:[NSData dataFromBase64String:imageBase64String]];
        self.secondRelatedArticleImageView.image = someImage;
        
        
        self.secondRelatedArticleId = (NSString*)[secondRelatedArticle objectForKey:kFKArticleId];
        
    }
    
    //set up third related article
    if (thirdRelatedArticle!=nil) {
        self.thirdRelatedArticleTitleLabel.text = [thirdRelatedArticle objectForKey:kFKArticleTitle];
        self.thirdRelatedArticleCategoryLabel.text = [thirdRelatedArticle objectForKey:kFKRelatedArticleCategoryText];
        
        NSString* imageBase64String =  [thirdRelatedArticle objectForKey:kFKRelatedArticleBase64Thumbnail];
        UIImage *someImage = [[UIImage alloc] initWithData:[NSData dataFromBase64String:imageBase64String]];
        self.thirdRelatedArticleImageView.image = someImage;
        
        self.thirdRelatedArticleId = (NSString*)[thirdRelatedArticle objectForKey:kFKArticleId];
    }
    
    
    
    
    //    //set up current frame for the article content view
    //    tempRect = _articleContentView.frame;
    //    _articleContentView.frame = CGRectMake(tempRect.origin.x, tempRect.origin.y, finalSizeForArticleContentView.width, finalSizeForArticleContentView.height);
    
    
    //    //set up web view with article description
    //    NSString *content = @"<html><head></head><body style='background-color: red; width: 320px; height: 50px; margin: 0; padding: 0; border:4px solid red;'><div id='ContentDiv'>Content Here</div></body></html>";
    //    [_descriptionWebView loadHTMLString:content baseURL:nil];
    //    _descriptionWebView.delegate = self;
    //    CGRect frame = _descriptionWebView.frame;
    //    CGSize fittingSize = [_descriptionWebView sizeThatFits:CGSizeZero];
    //    frame.size = fittingSize;
    //    _descriptionWebView.frame = frame;
    
    
}

-(void)setupLoadingView
{
    IgnantLoadingView *someView = [[IgnantLoadingView alloc] initWithFrame:self.view.frame];
    self.loadingView = someView;
    [someView release];
    
    [self.view addSubview:self.loadingView];    
}

- (void)configureView
{
    
    
#define PADDING_BOTTOM 20.0f
    [_contentScrollView scrollRectToVisible:CGRectMake(0, 0, 320, 10) animated:NO];
    
    
    //set up the navigation buttons
    [self setupNavigationButtons];
    
    
    //if article still needs to be loaded, show loading view
    if (_isShowingArticleFromLocalDatabase==NO && _isLoadingCurrentArticle==YES) 
    {
        //setup the loading view
        [self setupLoadingView];
        
        return;
    }
    else if(_isShowingArticleFromLocalDatabase==NO && _isLoadingCurrentArticle==NO)
    {
    
    }
    
    //set up the view in case the article is already here
    else 
    {
        //set up the remote pictures array
        self.remoteImagesArray = self.blogEntry.remoteImages;
        
    
        //article already loaded,
        //set up the article content view
        [self setupArticleContentView];
        
        
    }
    
    //set up the related articles view and add it to the contentScrollView
    CGPoint pointToDrawRelatedArticles = CGPointMake(0, self.articleContentView.bounds.size.height);
    CGSize nibSizeForRelatedArticles = self.relatedArticlesView.bounds.size;
    self.relatedArticlesView.frame = CGRectMake(pointToDrawRelatedArticles.x, pointToDrawRelatedArticles.y, nibSizeForRelatedArticles.width, nibSizeForRelatedArticles.height);
    [self.contentScrollView addSubview:self.relatedArticlesView];
    
    //set up the scrollView's final contentSize
    CGSize contentScrollViewFinalSize = CGSizeMake(320, _relatedArticlesView.bounds.size.height+_articleContentView.bounds.size.height + PADDING_BOTTOM);
    self.contentScrollView.contentSize = contentScrollViewFinalSize;
    
   
    
    
    
    
    
    
    //---------------------------------------------------------------------
    
    //    //get the images for the blogEntry
    //    NSManagedObjectContext *context = _managedObjectContext;
    //    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //    NSEntityDescription* imageEntity = [[NSEntityDescription entityForName:@"Image" inManagedObjectContext:_managedObjectContext] retain];
    //    [request setEntity:imageEntity];
    //    [request setIncludesSubentities:YES];
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:
    //                              @"entry == %@", blogEntry];
    //    [request setPredicate:predicate];
    //    NSError *error;
    //    NSArray *imagesToBeLoadedObjects = [context executeFetchRequest:request error:&error];
    //    [request release];
    //    
    //    
    //    //save the urls of the images in a mutableArray
    //    NSMutableArray *urlsForImagesToBeLoaded = [[NSMutableArray alloc] initWithCapacity:imagesToBeLoadedObjects.count];
    //    for (Image *i in imagesToBeLoadedObjects) {
    //        [urlsForImagesToBeLoaded addObject:i.url];
    //    }
    
    //    NSLog(@"imagesToBeLoadedObjects count: %d , blogEntryTitle: %@", [imagesToBeLoadedObjects count], blogEntry.title);
    
    //    [self setUpScrollViewWithImages:urlsForImagesToBeLoaded];
        
    
}

-(void)setupArticleContentViewWithRemoteDataDictionary:(NSDictionary*)articleDictionary
{
    
    NSString *remoteContentArticleTitle = [articleDictionary objectForKey:kFKArticleTitle];
    NSString *remoteContentArticleID = [articleDictionary objectForKey:kFKArticleId];
    NSString *remoteContentCategoryName = [articleDictionary objectForKey:kFKArticleCategoryName];
    NSString *remoteContentArticleDescriptionText = [articleDictionary objectForKey:kFKArticleDescriptionText];
    NSArray *remoteContentRelatedArticles = [articleDictionary objectForKey:kFKArticleRelatedArticles];
    
    NSArray *remoteContentRemoteImages = [articleDictionary objectForKey:kFKArticleRemoteImages];
    
    
    NSString *remoteContentBlogEntryPublishDate = [articleDictionary objectForKey:kFKArticlePublishingDate];
    
    self.remoteImagesArray = [NSArray arrayWithArray:remoteContentRemoteImages];
    
    
    CGSize finalSizeForArticleContentView = CGSizeMake(0, 0); 
    CGFloat contentViewWidth = 320.0f;
    CGRect tempRect = CGRectMake(0, 0, 0, 0);
    CGSize tempSize = CGSizeMake(0, 0);
    
    
    //set up the blog entry imageview
    /////////////////////////// handle the thumb image image
    NSDictionary *remoteContentAImageDictionary = [articleDictionary objectForKey:kFKArticleThumbImage];
    if (remoteContentAImageDictionary!=nil) 
    {
        NSString* imageIdentifier = [remoteContentAImageDictionary objectForKey:kFKImageId];
        NSString* imageCaption = [remoteContentAImageDictionary objectForKey:kFKImageDescription];
        NSString* imageBase64String =  [remoteContentAImageDictionary objectForKey:kFKImageBase64Representation];
        UIImage *someImage = [[UIImage alloc] initWithData:[NSData dataFromBase64String:imageBase64String]];
        
        _entryImageView.image = someImage;
    }
    
    
    //add the imageViewSize to the finalSizeForArticleContentView
    finalSizeForArticleContentView = CGSizeMake(contentViewWidth, _entryImageView.frame.origin.y+_entryImageView.bounds.size.height);
    
    
    //set up the button for showing pictures
    if ([remoteContentRemoteImages isKindOfClass:[NSArray class]]) {
        NSString *showPicturesButtonText = [NSString stringWithFormat:@"%d Fotos",remoteContentRemoteImages.count];
        [self.showPictureSlideshowButton setTitle:showPicturesButtonText forState:UIControlStateNormal];
    }
    
    //set up the title, date and category labels
    _titleLabel.text = [remoteContentArticleTitle uppercaseString];
    
    
#warning fix date to take GMT into consideration
    //2012-03-02T00:00:00+00:00
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate *remoteContentFormatedDate = [df dateFromString:remoteContentBlogEntryPublishDate];
    
    tempRect = _dateLabel.frame;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    _dateLabel.text = [formatter stringFromDate:remoteContentFormatedDate];
    [formatter release];
    
    
    if (remoteContentCategoryName!=nil) 
    {
        NSString *category = remoteContentCategoryName;
        NSString *categoryName = @"∙ "; //special characters: ∙ , ●
        
        categoryName = [categoryName stringByAppendingString:category];
        
        _categoryLabel.text = categoryName;
        _categoryLabel.frame = CGRectMake(tempRect.origin.x+tempRect.size.width, tempRect.origin.y, 100, tempRect.size.height);
    }
    
    //add the title, date and category labels size to the finalSizeForArticleContentView
    tempSize = finalSizeForArticleContentView;
    finalSizeForArticleContentView = CGSizeMake(tempSize.width, tempSize.height+_titleLabel.bounds.size.height+_categoryLabel.bounds.size.height+(_titleLabel.frame.origin.y-tempSize.height));
    NSLog(@"(title, date, category) finalSizeForArticleContentView: %@", NSStringFromCGSize(finalSizeForArticleContentView));
    
    
    //set up the description textview
    //set up the user interface for the current objects    
    CGFloat marginTop = 5.0f;
    _descriptionTextView.text = remoteContentArticleDescriptionText;
    CGSize descriptionTextContentSize = _descriptionTextView.contentSize;
    CGRect descriptionTextviewFrame = _descriptionTextView.bounds;
    
    _descriptionTextView.frame = CGRectMake(descriptionTextviewFrame.origin.x, finalSizeForArticleContentView.height+marginTop, descriptionTextviewFrame.size.width, descriptionTextContentSize.height+10);
    
    //add the description textview size to the finalSizeForArticleContentView
    tempSize = finalSizeForArticleContentView;
    finalSizeForArticleContentView = CGSizeMake(tempSize.width, tempSize.height+descriptionTextContentSize.height);
    
    NSLog(@"(final) finalSizeForArticleContentView: %@", NSStringFromCGSize(finalSizeForArticleContentView));
    
    
    //set the frame of the article content view
    tempRect = _articleContentView.frame;
    _articleContentView.frame = CGRectMake(tempRect.origin.x, tempRect.origin.y, finalSizeForArticleContentView.width, finalSizeForArticleContentView.height+10.0f);
    
    
    
    //add the articleContentView to the scrollView
    [self.contentScrollView addSubview:self.articleContentView];
    
    
    
    
    //#############################################################################################
    //------------------------------------------------
    //---------------- RELATED ARTICLES --------------
    //------------------------------------------------
    
    NSDictionary* firstRelatedArticle = [remoteContentRelatedArticles objectAtIndex:0];
    NSDictionary* secondRelatedArticle = [remoteContentRelatedArticles objectAtIndex:1];
    NSDictionary* thirdRelatedArticle = [remoteContentRelatedArticles objectAtIndex:2];
    
    //set up first related article
    if (firstRelatedArticle!=nil) {
        self.firstRelatedArticleTitleLabel.text = [firstRelatedArticle objectForKey:kFKArticleTitle];
        self.firstRelatedArticleCategoryLabel.text = [firstRelatedArticle objectForKey:kFKRelatedArticleCategoryText];
        
        NSString* imageBase64String =  [firstRelatedArticle objectForKey:kFKRelatedArticleBase64Thumbnail];
        UIImage *someImage = [[UIImage alloc] initWithData:[NSData dataFromBase64String:imageBase64String]];
        self.firstRelatedArticleImageView.image = someImage;   
    }
    
    //set up second related article
    if (secondRelatedArticle!=nil) {
        self.secondRelatedArticleTitleLabel.text = [secondRelatedArticle objectForKey:kFKArticleTitle];
        self.secondRelatedArticleCategoryLabel.text = [secondRelatedArticle objectForKey:kFKRelatedArticleCategoryText];
        
        NSString* imageBase64String =  [secondRelatedArticle objectForKey:kFKRelatedArticleBase64Thumbnail];
        UIImage *someImage = [[UIImage alloc] initWithData:[NSData dataFromBase64String:imageBase64String]];
        self.secondRelatedArticleImageView.image = someImage;
    }
    
    //set up third related article
    if (thirdRelatedArticle!=nil) {
        self.thirdRelatedArticleTitleLabel.text = [thirdRelatedArticle objectForKey:kFKArticleTitle];
        self.thirdRelatedArticleCategoryLabel.text = [thirdRelatedArticle objectForKey:kFKRelatedArticleCategoryText];
        
        NSString* imageBase64String =  [thirdRelatedArticle objectForKey:kFKRelatedArticleBase64Thumbnail];
        UIImage *someImage = [[UIImage alloc] initWithData:[NSData dataFromBase64String:imageBase64String]];
        self.thirdRelatedArticleImageView.image = someImage;
    }
    
    
    
    //    //set up current frame for the article content view
    //    tempRect = _articleContentView.frame;
    //    _articleContentView.frame = CGRectMake(tempRect.origin.x, tempRect.origin.y, finalSizeForArticleContentView.width, finalSizeForArticleContentView.height);
    
    
    //    //set up web view with article description
    //    NSString *content = @"<html><head></head><body style='background-color: red; width: 320px; height: 50px; margin: 0; padding: 0; border:4px solid red;'><div id='ContentDiv'>Content Here</div></body></html>";
    //    [_descriptionWebView loadHTMLString:content baseURL:nil];
    //    _descriptionWebView.delegate = self;
    //    CGRect frame = _descriptionWebView.frame;
    //    CGSize fittingSize = [_descriptionWebView sizeThatFits:CGSizeZero];
    //    frame.size = fittingSize;
    //    _descriptionWebView.frame = frame;
}


#pragma mark - picture slideshow

- (IBAction)showPictureSlideshow:(id)sender {
    
    ImageSlideshowViewController *slideshowVC = [[ImageSlideshowViewController alloc] initWithNibName:@"ImageSlideshowViewController" bundle:nil];
    
    //set up the slideshowVC
    slideshowVC.remoteImagesArray = _remoteImagesArray;
    
    //show the slideshowVC
    slideshowVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentModalViewController:slideshowVC animated:YES];
    [slideshowVC release];

}
- (IBAction)tapAction:(id)sender {
    
#define IGNANT_TOOLBAR_HEIGHT 50.0f
#define ANIMATION_DURATION 0.2f
    
    if (self.navigationController.navigationBar.isHidden) {
        
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        [UIView animateWithDuration:ANIMATION_DURATION 
                         animations:^{
                             
                             //move the toolbar out of the screen
                             CGRect currentShareAndMoreToolbarFrame = _shareAndMoreToolbar.frame; 
                             _shareAndMoreToolbar.frame = CGRectMake(currentShareAndMoreToolbarFrame.origin.x, currentShareAndMoreToolbarFrame.origin.y-IGNANT_TOOLBAR_HEIGHT*2, currentShareAndMoreToolbarFrame.size.width, currentShareAndMoreToolbarFrame.size.height);
                             
                             //resize the scroll view
                             CGRect currentScrollViewFrame = _contentScrollView.frame;
                             _contentScrollView.frame = CGRectMake(0, 0, currentScrollViewFrame.size.width, currentScrollViewFrame.size.height-IGNANT_TOOLBAR_HEIGHT);
                            } 
                         completion:^(BOOL finished){
                             NSLog(@"animation completed");
                         }];
    }
    else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        
        [UIView animateWithDuration:ANIMATION_DURATION
                         animations:^{
                             
                             //move the toolbar out of the screen
                             CGRect currentShareAndMoreToolbarFrame = _shareAndMoreToolbar.frame; 
                             _shareAndMoreToolbar.frame = CGRectMake(currentShareAndMoreToolbarFrame.origin.x, currentShareAndMoreToolbarFrame.origin.y+2*IGNANT_TOOLBAR_HEIGHT, currentShareAndMoreToolbarFrame.size.width, currentShareAndMoreToolbarFrame.size.height);
                             
                             //resize the scroll view
                             CGRect currentScrollViewFrame = _contentScrollView.frame;
                             _contentScrollView.frame = CGRectMake(0, 0, currentScrollViewFrame.size.width, currentScrollViewFrame.size.height+IGNANT_TOOLBAR_HEIGHT);
                             
                         } 
                         completion:^(BOOL finished){
                             NSLog(@"animation completed");
                         }];
    }
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"clickedButtonAtIndex");
}

#pragma mark - show mosaik / more
- (IBAction)showShare:(id)sender {
    
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook",@"Twitter", nil ];
    
    [shareActionSheet showInView:self.view];
    [shareActionSheet release];
   
    NSLog(@"showShare!");
}


- (IBAction)showMore:(id)sender {
    
    IGNMoreOptionsViewController *moreOptionsVC = [[IGNMoreOptionsViewController alloc] initWithNibName:@"IGNMoreOptionsViewController" bundle:nil];
    [self.navigationController pushViewController:moreOptionsVC animated:YES];
    [moreOptionsVC release];
}


#pragma mark - related articles
-(void)showRelatedArticle:(id)sender
{
 
    NSString *articleId = nil;
    
    if ([sender tag] == kFirstRelatedArticleTag) 
    {
        articleId = [NSString stringWithString:_firstRelatedArticleId];
    }
    
    else if ([sender tag] == kSecondRelatedArticleTag) 
    {
        articleId = [NSString stringWithString:_secondRelatedArticleId];
    } 
    
    else if ([sender tag] == kThirdRelatedArticleTag) 
    {
        articleId = [NSString stringWithString:_thirdRelatedArticleId];
    }
    
    //tag is falsly set
    else
    {
        NSLog(@"tag is falsly set, doing nothing");
        return;
    }
    
    
    //blog entry to be shown is set, show the view controller loading the article data
    if (!self.nextDetailViewController) {
        self.nextDetailViewController = [[[IGNDetailViewController alloc] initWithNibName:@"IGNDetailViewController_iPhone" bundle:nil] autorelease];
    }
    
    NSLog(@"articleIdChosen: %@", articleId);
    
    self.nextDetailViewController.currentArticleId = articleId;
    self.nextDetailViewController.didLoadContentForRemoteArticle = NO;
    self.nextDetailViewController.isShowingArticleFromLocalDatabase = NO;
    
    //reset the indexes
    self.nextDetailViewController.nextBlogEntryIndex = kInvalidBlogEntryIndex;
    self.nextDetailViewController.previousBlogEntryIndex = kInvalidBlogEntryIndex;
    
//    
//    //set up the selected object and previous/next objects
//    NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//    self.detailViewController.blogEntry = (BlogEntry*)selectedObject;
//    
//    NSArray *fetchedResultsArray = self.fetchedResultsController.fetchedObjects;
//    self.detailViewController.fetchedResults = fetchedResultsArray;
//    self.detailViewController.currentBlogEntryIndex = indexPath.row;
//    
//    
    //set the managedObjectContext and push the view controller
    self.nextDetailViewController.managedObjectContext = self.managedObjectContext;
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
    
    NSLog(@"encodedString go: %@",encodedString);
    
    
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
    
    [self configureView];
    
#warning todo: handle errors
    [self.importer importJSONStringForSingleArticle:[request responseString]];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
#warning TODO: do something with the request
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    _isLoadingCurrentArticle = NO;
}


#pragma mark - IgnantImporterDelegate

-(void)importerDidStartParsingSingleArticle:(IgnantImporter*)importer
{
    NSLog(@"importerDidStartParsingSingleArticle");
}

-(void)importer:(IgnantImporter*)importer didFinishParsingSingleArticleWithDictionary:(NSDictionary*)articleDictionary
{

    NSLog(@"didFinishParsingSingleArticleWithDictionary:");    
    
    _didLoadContentForRemoteArticle = YES;
    
    
    //set up the remote articles ids
    NSArray *remoteContentRelatedArticles = [articleDictionary objectForKey:kFKArticleRelatedArticles];
    NSDictionary *firstRelatedArticle = [remoteContentRelatedArticles objectAtIndex:0];
    NSDictionary *secondRelatedArticle = [remoteContentRelatedArticles objectAtIndex:1];
    NSDictionary *thirdRelatedArticle = [remoteContentRelatedArticles objectAtIndex:2];
    
    if (firstRelatedArticle!=nil) {
        self.firstRelatedArticleId = (NSString*)[firstRelatedArticle objectForKey:kFKArticleId];
    }
    if (secondRelatedArticle!=nil) {
        self.secondRelatedArticleId = (NSString*)[secondRelatedArticle objectForKey:kFKArticleId];
    }
    if (thirdRelatedArticle!=nil) {
        self.thirdRelatedArticleId = (NSString*)[thirdRelatedArticle objectForKey:kFKArticleId];
    }
   
    
    
    [self setupArticleContentViewWithRemoteDataDictionary:articleDictionary];
    
    
    [self configureView];
    
    
    [self.loadingView removeFromSuperview];
    
}

-(void)importer:(IgnantImporter*)importer didFailParsingSingleArticleWithDictionary:(NSDictionary*)articleDictionary
{
    NSLog(@"didFailParsingSingleArticleWithDictionary");
    
#warning TODO: stop showing loading view and return to the master view controller
    
    
}





@end
