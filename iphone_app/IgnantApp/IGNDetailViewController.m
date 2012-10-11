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
    BOOL _isExecutingWebviewTapAction;
    CGFloat lastHeightForWebView;
}

-(void)setupArticleContentViewWithRemoteDataDictionary:(NSDictionary*)articleDictionary;
-(void)setupNavigationEntries;
-(void)setupUIElementsForBlogEntryTemplate:(NSString*)template;
- (IBAction)showMercedes:(id)sender;
-(IBAction) toggleLike:(id)sender;


@property(assign) CGSize lastDTTextViewSize;
@property(assign) CGFloat lastDTViewHeight;
@property(assign) BOOL isLoadingCurrentArticle;


@property (nonatomic, assign, readwrite) BOOL isShowingImageSlideshow;
@property (nonatomic, assign, readwrite) BOOL isImportingRelatedArticle;

@property (strong, nonatomic, readwrite) UITapGestureRecognizer *dtGestureRecognizer;

@property (strong, nonatomic, readwrite) NSDictionary *remoteArticleDictionary;
@property (strong, nonatomic, readwrite) NSString *remoteArticleJSONString;

//properties for navigating through remote articles
@property (strong, nonatomic) NSArray *relatedArticlesIds;

//article UI stugg
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UIButton *showPictureSlideshowButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UIImageView *entryImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *entryImageActivityIndicatorView;
@property (retain, nonatomic) IBOutlet UIButton *showSlideshowButton;

@property (nonatomic, strong, readwrite) NSNumberFormatter *numberFormatter;

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
        return;
    }
    //set up view for when article is stored in the local database
    else if(_isShowingArticleFromLocalDatabase)
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

-(void)showLinkOptions:(NSURL*)url
{
    self.isShowingLinkOptions = true;
    self.linkOptionsUrl = url;
    
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

-(void)setupUIElementsForBlogEntryTemplate:(NSString*)template
{
	//add/remove video view
	if ([template compare:kFKArticleTemplateVideo]==NSOrderedSame
		|| [template compare:kFKArticleTemplateIgnanTV]==NSOrderedSame) {
        [self.articleContentView addSubview:self.articleVideoView];
    }
	else{
        [self.articleVideoView removeFromSuperview];
	}
	
	//add/remove pictureSlideshowButton
    if ([template compare:kFKArticleTemplateDefault]==NSOrderedSame
		|| [template compare:kFKArticleTemplateAicuisine]==NSOrderedSame
		|| [template compare:kFKArticleTemplateItravel]==NSOrderedSame) {
        [self.articleContentView addSubview:self.showPictureSlideshowButton];
    }
    
    else if ([template compare:kFKArticleTemplateDailyBasics]==NSOrderedSame
			 || [template compare:kFKArticleTemplateMonifaktur]==NSOrderedSame
			 || [template compare:kFKArticleTemplateVideo]==NSOrderedSame
			 || [template compare:kFKArticleTemplateIgnanTV]==NSOrderedSame) {
        [self.showPictureSlideshowButton removeFromSuperview];
    }
}

- (IBAction)showMercedes:(id)sender {
    NSError* error = nil;
	GATrackEvent(&error, @"IGNDetailViewController", @"showMercedes", @"", -1);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAdressForMercedesPage]];
}

#pragma mark - drawing methods

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
    
	
//	descriptionText = @"Das Dreieck definiert sich in drei Punkten (die nicht auf einer Geraden liegen), welche durch drei Seiten verbunden werden. Gleichschenklige und spitze Dreiecke bestechen mit Sexyness, stumpfwinklige kommen eher plump daher und öffnen beim Nachdenken ein wenig den Mund. Im Christentum steht das Dreieck als Symbol für die Dreifaltigkeit. <!--more-->In Polen ist ein auf der Spitze stehendes Dreieck das Symbol für die Herrentoilette. Es unterliegt dem Viereck um eine Ecke, tritt aber trotz alledem besonders selbstsicher und häufig in der Mathematik, in der Straßenbeschilderungs-Szene und im Grafik-Design auf.\" <img src=\"http://www.ignant.de/wp-content/uploads/2010/12/monja_gentschow_dreieck_01.jpg\" alt=\"\" width=\"320px\" /><img src=\"http://www.ignant.de/wp-content/uploads/2010/12/monja_gentschow_dreieck_02.jpg\" alt=\"aaa\" width=\"320px\" /><img src=\"http://www.ignant.de/wp-content/uploads/2010/12/monja_gentschow_dreieck_03.jpg\" alt=\"\" width=\"320px\" />Diese Dreiecksgeschichten und vieles mehr könnt ihr heute Abend bei der Eröffnung des <a href=\"http://www.undplus.com/\" target=\"_blank\">UNDPLUS Urban Gallery Store N°4</a> sehen. Ab 19 Uhr in der Torstraße 66, Berlin-Mitte.<br />Der Tapir, ein schwerfälliges Tier mit charakteristischem Rüssel, ein Säugetier und Unpaarhufer zugleich. Im Gegensatz zu den Paarhufern sind Unpaarhufer mit einer ungeraden Anzahl von Zehen charakterisiert. Äußerlich Schweineähnlich, ist es jedoch durch seine Hufigkeit am nächsten mit den Pferden und Nashörnern verwandt. <!--more--><img src=\"http://www.ignant.de/wp-content/uploads/2011/05/Tapir-logo-Monja-Gentschow.jpg\" alt=\"\" title=\"Tapir-logo-Monja-Gentschow\" width=\"720\" height=\"501\" class=\"alignnone size-full wp-image-21841\" /><img src=\"http://www.ignant.de/wp-content/uploads/2011/05/Tapir-eins-Monja-Gentschow.jpg\" width=\"720\" height=\"611\" class=\"alignnone size-full wp-image-21833\" /><img src=\"http://www.ignant.de/wp-content/uploads/2011/05/Tapir-galopp-Monja-Gentschow.gif\" title=\"Tapir-galopp-Monja-Gentschow\" width=\"720\" height=\"448\" class=\"alignnone size-full wp-image-21834\" />";
	
    [self setupUIElementsForBlogEntryTemplate:articleTemplate];
    self.currentArticleId = articleID;
    self.articleWeblink = articleWebLink;
	self.articleDescription = descriptionText;
	self.currentRelatedArticles = relatedArticles;
	
    if ([videoEmbedCode length]>0) {
		[self setupVideoViewWithContent:videoEmbedCode];
    }
    else
    {
        [self triggerLoadingDetailImageWithArticleId:self.currentArticleId
                                        forImageView:self.entryImageView];
    }
    
	[self drawArticleImageView];
	[self drawSlideShowButtonForImages:remoteImages];
    [self drawLabelsForTitle:title
					category:categoryName
			  publishingDate:publishDate];
	[self.contentScrollView addSubview:self.articleContentView];
	
	[self drawDTViewWithRichtext:descriptionText];
	self.articleDescription = descriptionText;
	[self redrawArticleContentViewWithNewDTViewHeight:self.dtTextView.bounds.size.height];    
	
    [self setIsLoadingViewHidden:YES];
}

-(void)redrawArticleContentViewWithNewDTViewHeight:(CGFloat)newDTViewHeight
{
	if (self.lastDTViewHeight==newDTViewHeight) {
		return;
	}
	self.lastDTViewHeight = newDTViewHeight;
		
	[self.dtTextView removeFromSuperview];
	
	CGRect oldDTTextViewFrame = self.dtTextView.frame;
	CGSize oneTcontentSize = self.dtTextView.contentSize;
    
    self.dtTextView.frame = CGRectMake(oldDTTextViewFrame.origin.x, oldDTTextViewFrame.origin.y, oldDTTextViewFrame.size.width, oneTcontentSize.height);
	
	CGPoint pointToDraw = CGPointMake(0, self.articleContentView.bounds.size.height);
    CGSize nibSize = self.dtTextView.bounds.size;
    self.dtTextView.frame = CGRectMake(pointToDraw.x, pointToDraw.y, nibSize.width, nibSize.height);
    [self.contentScrollView addSubview:self.dtTextView];
	
	[self drawRelatedArticlesView:self.currentRelatedArticles];
	[self resizeContentScrollViewForCurrentSubviews];
}

-(void)setupVideoViewWithContent:(NSString*)videoEmbedCode
{
	CGFloat videoWidth = 950.0f;
	CGFloat videoHeight = 534.0f;
	CGFloat videoNewWidth = 310.0f;
	CGFloat videoNewHeight = videoNewWidth*videoHeight/videoWidth;
	NSString* videoDescriptionText = [NSString stringWithFormat:@"<html><head><title></title><style type='text/css'>*{ padding:0; margin:0; }</style></head><body><div style=\"width:%fpx; height:%fpx;\">%@</div></body></html>", videoNewWidth, videoNewHeight, videoEmbedCode];
	[self.articleVideoWebView loadHTMLString:videoDescriptionText baseURL:nil];
	CGRect oldFrame = self.articleVideoView.frame;
	self.articleVideoView.frame = CGRectMake(oldFrame.origin.x, 5.0f, oldFrame.size.width, oldFrame.size.height);
}

-(NSString*)wrapDTRichtext:(NSString*)richText
{
    NSString * dbFile = [[NSBundle mainBundle] pathForResource:@"DTWrapper" ofType:@"html"];
    NSString * contents = [NSString stringWithContentsOfFile:dbFile encoding:NSUTF8StringEncoding error:nil];
    return [NSString stringWithFormat:contents,richText];
}

-(void)drawArticleImageView
{
	CGSize sizeAfterEntryImageView = CGSizeMake(320.0f, _entryImageView.frame.origin.y+_entryImageView.bounds.size.height);
	CGRect oldFrameAfterEntryImageView = self.articleContentView.frame;
	CGRect frameAfterEntryImageView = CGRectMake(oldFrameAfterEntryImageView.origin.x, oldFrameAfterEntryImageView.origin.y, sizeAfterEntryImageView.width, sizeAfterEntryImageView.height);
	self.articleContentView.frame = frameAfterEntryImageView;
}

-(void)drawSlideShowButtonForImages:(id)images
{
	self.remoteImagesArray = [NSArray arrayWithArray:images];
	
    if ([images isKindOfClass:[NSArray class]]) {
        NSString *showPicturesButtonText = [NSString stringWithFormat:NSLocalizedString(@"fotos_button_title", @"Title of the 'Fotos' button on the Detail View Controller"),[images count]];
        [self.showPictureSlideshowButton setTitle:showPicturesButtonText forState:UIControlStateNormal];
    }
}

-(void)drawLabelsForTitle:(NSString *) title
				 category:(NSString *) categoryName
			publishingDate:(NSDate *) date
{
	self.articleTitle = title;
	
    self.titleLabel.text = [title uppercaseString];
    
    //set up the date label
    CGRect tempRect = self.dateLabel.frame;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString* publishDateString = [formatter stringFromDate:date];
    CGSize publishDateSize = [publishDateString sizeWithFont:self.dateLabel.font];
    DBLog(@"publishDateSize: %@", NSStringFromCGSize(publishDateSize));
    
    self.dateLabel.frame = CGRectMake(tempRect.origin.x, tempRect.origin.y, publishDateSize.width, tempRect.size.height);
    self.dateLabel.text = publishDateString;
    
    tempRect = self.dateLabel.frame;
    
    //set up the category name    
    if (categoryName!=nil)
    {
        NSString *category = categoryName;
        NSString *categoryName = @" ∙ "; //special characters: ∙ , ●
        
        categoryName = [categoryName stringByAppendingString:category];
        
        self.categoryLabel.text = categoryName;
        self.categoryLabel.frame = CGRectMake(tempRect.origin.x+tempRect.size.width, tempRect.origin.y, 100, tempRect.size.height);
    }
    
    //add the title, date and category labels size to the finalSizeForArticleContentView
	
    CGSize sizeBeforeTitleAndCategoryLabel = self.articleContentView.bounds.size;
	CGRect oldFrame = self.articleContentView.frame;
	CGSize sizeAfterTitleAndCategoryLavel = CGSizeMake(sizeBeforeTitleAndCategoryLabel.width, sizeBeforeTitleAndCategoryLabel.height+_titleLabel.bounds.size.height+_categoryLabel.bounds.size.height+(_titleLabel.frame.origin.y-sizeBeforeTitleAndCategoryLabel.height));
	self.articleContentView.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, sizeAfterTitleAndCategoryLavel.width, sizeAfterTitleAndCategoryLavel.height);
}

-(void)drawDTViewWithRichtext:(NSString*)descriptionText
{	
	NSString* finalRichText = [self wrapDTRichtext:descriptionText];
	NSData *data = [finalRichText dataUsingEncoding:NSUTF8StringEncoding];
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
	self.dtTextView.contentView.edgeInsets = UIEdgeInsetsMake(0,5.0f, 0, 2.0f);
	self.dtTextView.attributedString = string;

}

-(void)drawRelatedArticlesView:(NSArray*)relatedArticles
{
    [self setupRelatedArticlesUI:relatedArticles];
	
    CGPoint pointToDraw = CGPointMake(0, self.articleContentView.bounds.size.height+self.dtTextView.bounds.size.height);
    CGSize nibSize = self.relatedArticlesView.bounds.size;
    self.relatedArticlesView.frame = CGRectMake(pointToDraw.x, pointToDraw.y, nibSize.width, nibSize.height);
    [self.contentScrollView addSubview:self.relatedArticlesView];
}

-(void)resizeContentScrollViewForCurrentSubviews
{
	CGFloat heightForDTTextView = 0.0f;
	if (self.dtTextView.superview!=nil) {
		heightForDTTextView = self.dtTextView.bounds.size.height;
	}
	
	CGFloat heightForRelatedArticles = 0.0f;
	if (self.relatedArticlesView.superview!=nil) {
		heightForRelatedArticles = self.relatedArticlesView.bounds.size.height;
	}
	
	CGSize contentScrollViewFinalSize = CGSizeMake(320.0f, heightForDTTextView+heightForRelatedArticles+self.articleContentView.bounds.size.height);
    self.contentScrollView.contentSize = contentScrollViewFinalSize;
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
    if ([relatedArticles count]<3)
        return;
        
    NSDictionary* firstRelatedArticle = [relatedArticles objectAtIndex:0];
    NSDictionary* secondRelatedArticle = [relatedArticles objectAtIndex:1];
    NSDictionary* thirdRelatedArticle = [relatedArticles objectAtIndex:2];
    
    //set up first related article
    if (firstRelatedArticle!=nil) {
        self.firstRelatedArticleTitleLabel.text = [firstRelatedArticle objectForKey:kFKArticleTitle];
        self.firstRelatedArticleCategoryLabel.text = [firstRelatedArticle objectForKey:kFKRelatedArticleCategoryText];
        self.firstRelatedArticleId = (NSString*)[firstRelatedArticle objectForKey:kFKArticleId];
        
        [self triggerLoadingRelatedImageWithArticleId:self.firstRelatedArticleId
                                         forImageView:self.firstRelatedArticleImageView];
    }
    
    //set up second related article
    if (secondRelatedArticle!=nil) {
        self.secondRelatedArticleTitleLabel.text = [secondRelatedArticle objectForKey:kFKArticleTitle];
        self.secondRelatedArticleCategoryLabel.text = [secondRelatedArticle objectForKey:kFKRelatedArticleCategoryText];
        self.secondRelatedArticleId = (NSString*)[secondRelatedArticle objectForKey:kFKArticleId];
        
        [self triggerLoadingRelatedImageWithArticleId:self.secondRelatedArticleId
                                         forImageView:self.secondRelatedArticleImageView];
        
    }
    
    //set up third related article    
    if (thirdRelatedArticle!=nil) {
        self.thirdRelatedArticleTitleLabel.text = [thirdRelatedArticle objectForKey:kFKArticleTitle];
        self.thirdRelatedArticleCategoryLabel.text = [thirdRelatedArticle objectForKey:kFKRelatedArticleCategoryText];
        self.thirdRelatedArticleId = (NSString*)[thirdRelatedArticle objectForKey:kFKArticleId];
        
        [self triggerLoadingRelatedImageWithArticleId:self.thirdRelatedArticleId
                                         forImageView:self.thirdRelatedArticleImageView];
    }
        
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
    
    NSString *remoteContentArticleWeblinkString = [articleDictionary objectForKey:kFKArticleWebLink];
    NSURL* remoteContentArticleWeblink = [NSURL URLWithString:remoteContentArticleWeblinkString];
    
    NSString *remoteContentArticleDescriptionTextBase64 = [articleDictionary objectForKey:kFKArticleDescriptionText];
    NSString *remoteContentArticleDescriptionText = [[NSString alloc] initWithData:[NSData dataFromBase64String:remoteContentArticleDescriptionTextBase64] encoding:NSUTF8StringEncoding];
    
    NSString *remoteContentArticleVideoEmbedCodeBase64 = [articleDictionary objectForKey:kFKArticleVideoEmbedCode];
    NSString *remoteContentArticleVideoEmbedCode = [[NSString alloc] initWithData:[NSData dataFromBase64String:remoteContentArticleVideoEmbedCodeBase64] encoding:NSUTF8StringEncoding];

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
    
    [self setupArticleContentViewWithArticleTitle:articleDictionary[kFKArticleTitle]
                                        articleId:articleDictionary[kFKArticleId]
                                          webLink:remoteContentArticleWeblink
                                     categoryName:articleDictionary[kFKArticleCategoryName]
                                  descriptionText:remoteContentArticleDescriptionText
                                  relatedArticles:articleDictionary[kFKArticleRelatedArticles]
                                     remoteImages:articleDictionary[kFKArticleRemoteImages]
                                      publishDate:fDate
                                   videoEmbedCode:remoteContentArticleVideoEmbedCode
                                         template:articleDictionary[kFKArticleTemplate]];
    return;
}

#pragma mark - picture slideshow

- (IBAction)showPictureSlideshow:(id)sender
{
    self.isShowingImageSlideshow = YES;
    ImageSlideshowViewController *slideshowVC = [[ImageSlideshowViewController alloc] initWithNibName:@"ImageSlideshowViewController" bundle:nil];
    slideshowVC.remoteImagesArray = _remoteImagesArray;
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

#pragma mark - show mosaik / more
-(void)showMosaic
{
    IGNMosaikViewController *mosaikVC = self.appDelegate.mosaikViewController;
    mosaikVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    mosaikVC.parentNavigationController = self.navigationController;
    [self.navigationController presentModalViewController:mosaikVC animated:YES];
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
    
	NSArray* cancelingViews = @[self.showSlideshowButton,self.showPictureSlideshowButton,
	self.firstRelatedArticleShowDetailsButton,self.secondRelatedArticleShowDetailsButton,
	self.thirdRelatedArticleShowDetailsButton];
	for (UIView* singleView in cancelingViews) {
		if (singleView.superview!=nil && [touch.view isDescendantOfView:singleView]) {
			return NO;
		}
	}
	
    if ([touch.view isKindOfClass:[DTLinkButton class]]) {
        return NO;
    }
    
    return YES;
}


#pragma mark - swipe UIGestureRecognizer

- (IBAction)handleRightSwipe:(id)sender 
{
    LOG_CURRENT_FUNCTION()
}

- (IBAction)handleLeftSwipe:(id)sender 
{
    LOG_CURRENT_FUNCTION()
    
}

#pragma mark - custom special views
-(UIView *)couldNotLoadDataView
{
    UIView* defaultView = [super couldNotLoadDataView];
    self.couldNotLoadDataLabel.text =  NSLocalizedString(@"could_not_load_data_for_this_article", @"Title of the 'couldNotLoadDataLabel'");
    return defaultView;
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


- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame
{

	if (attachment.contentType == DTTextAttachmentTypeImage)
	{
		// if the attachment has a hyperlinkURL then this is currently ignored
		DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
		imageView.delegate = self;
		if (attachment.contents)
		{
			imageView.image = attachment.contents;
		}
		
		// url for deferred loading
		imageView.url = attachment.contentURL;
		
		// if there is a hyperlink then add a link button on top of this image
		if (attachment.hyperLinkURL)
		{
			// NOTE: this is a hack, you probably want to use your own image view and touch handling
			// also, this treats an image with a hyperlink by itself because we don't have the GUID of the link parts
			imageView.userInteractionEnabled = YES;
			DTLinkButton *button = (DTLinkButton *)[self attributedTextContentView:attributedTextContentView viewForLink:attachment.hyperLinkURL identifier:attachment.hyperLinkGUID frame:imageView.bounds];
			[imageView addSubview:button];
		}
		
		return imageView;
	}
	
	return nil;
}


#pragma mark - DTLazyImageViewDelegate

- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
	NSURL *url = lazyImageView.url;
	CGSize imageSize = CGSizeMake(310.0f, size.height*310.0f/size.width);
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
	
	// update all attachments that matchin this URL (possibly multiple images with same size)
	for (DTTextAttachment *oneAttachment in [self.dtTextView.contentView.layoutFrame textAttachmentsWithPredicate:pred])
	{
		oneAttachment.originalSize = imageSize;
		
//		if (!CGSizeEqualToSize(imageSize, oneAttachment.displaySize))
//		{
//			oneAttachment.displaySize = imageSize;
//		}
	}
	
	// redo layout
	// here we're layouting the entire string, might be more efficient to only relayout the paragraphs that contain these attachments
	[self.dtTextView.contentView relayoutText];
	
	if (self.dtTextView.contentView.bounds.size.height != self.lastDTTextViewSize.height) {
		
		[self redrawArticleContentViewWithNewDTViewHeight:self.dtTextView.contentView.bounds.size.height];
		self.lastDTTextViewSize = self.dtTextView.contentView.bounds.size;
		NSLog(@"trigger reload");
	}

	NSLog(@"self.dtTextView.contentView.bounds.size: %@", NSStringFromCGSize(self.dtTextView.contentView.bounds.size));
	
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
        [self showLinkOptions:URL];
	}
}

@end
