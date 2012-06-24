//
//  IGNViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 04.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "IGNViewController.h"

#import "Constants.h"

#import "IGNAppDelegate.h"

@interface IGNViewController ()
{

}

@property(nonatomic, strong, readwrite) UIView* firstRunLoadingView;
@property(nonatomic, strong, readwrite) UIView* loadingView;
@property(nonatomic, strong, readwrite) UILabel* loadingViewLabel;
@property(nonatomic, strong, readwrite) UIView* noInternetConnectionView;
@property(nonatomic, strong, readwrite) UIView* couldNotLoadDataView;
@property(nonatomic, strong, readwrite) UILabel* couldNotLoadDataLabel;

@end

@implementation IGNViewController
@synthesize firstRunLoadingView =_firstRunLoadingView;
@synthesize loadingView = _loadingView;
@synthesize loadingViewLabel = _loadingViewLabel;
@synthesize noInternetConnectionView = _noInternetConnectionView;
@synthesize couldNotLoadDataView = _couldNotLoadDataView;
@synthesize couldNotLoadDataLabel = _couldNotLoadDataLabel;

@synthesize viewControllerToReturnTo;

@synthesize appDelegate = _appDelegate;

@synthesize importer = _importer;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
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

-(IgnantImporter*)importer
{
    NSLog(@"init importer");
    
    if (_importer==nil) {        
        _importer = [[IgnantImporter alloc] init];
        _importer.persistentStoreCoordinator = self.appDelegate.persistentStoreCoordinator;
        _importer.delegate = self;
    }
    
    return _importer;
}

-(IGNAppDelegate*)appDelegate
{
    if (_appDelegate==nil) {
        _appDelegate = (IGNAppDelegate*)[[UIApplication sharedApplication] delegate];
    }

    return _appDelegate;
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

    [self setUpBackButton];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.loadingView = nil;
    self.noInternetConnectionView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - special views

-(UIView*)couldNotLoadDataView
{
    
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    if (_couldNotLoadDataView==nil) {
        
        //set up the no internet connection view
        CGRect noInternetConnectionViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        UIView* someView = [[UIView alloc] initWithFrame:noInternetConnectionViewFrame];
        someView.backgroundColor = [UIColor whiteColor];
        someView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        //set up the label
        CGSize labelSize = CGSizeMake(280.0f, 40.0f);
        CGRect someLabelFrame = CGRectMake((CGRectGetWidth(self.view.frame)-labelSize.width)/2, (CGRectGetHeight(self.view.frame)-labelSize.height)/2, labelSize.width, labelSize.height);
        UILabel* someLabel = [[UILabel alloc] initWithFrame:someLabelFrame];
        someLabel.textAlignment = UITextAlignmentCenter;
        someLabel.numberOfLines = 2;
#warning find better text!
#warning add fonts to constants    
        someLabel.text = @"Sorry, but you need an internet connection to load this data"; 
        someLabel.font = [UIFont fontWithName:@"Georgia" size:14.0f];
        someLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.couldNotLoadDataLabel = someLabel;
        [someView addSubview:someLabel];
        
        _couldNotLoadDataView = someView;
    }
    
    return _couldNotLoadDataView;
}

-(void)setIsCouldNotLoadDataViewHidden:(BOOL)hidden
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    if (hidden) {
        [_couldNotLoadDataView removeFromSuperview];
    }
    else {
        CGRect newFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.couldNotLoadDataView.frame = newFrame;
        [self.view addSubview:self.couldNotLoadDataView];        
        
        
        NSLog(@" is couldnotloaddataview nil: %@", (_couldNotLoadDataView == nil) ? @"TRUE" : @"FALSE");
        
        [self setIsLoadingViewHidden:YES];
        [self setIsNoConnectionViewHidden:YES];
        
    }
}

-(void)setUpBackButton
{
#define DEBUG_SHOW_COLORS false
    
    NSString* titleOfReturningToViewController = self.viewControllerToReturnTo.title;
    
#warning TODO: localize! better text
    if (titleOfReturningToViewController==nil) {
        titleOfReturningToViewController = @"back";
    }
    
#define PADDING_TOP 1.0f
    
    //back button
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect backButtonFrame = CGRectMake(0, 0, 100.0f, 57.0f);
    backButton.frame = backButtonFrame;
    backButton.backgroundColor = DEBUG_SHOW_COLORS ? [UIColor blueColor] : [UIColor clearColor];
    [backButton addTarget:self action:@selector(handleBack:) forControlEvents:UIControlEventTouchDown];
    
    //arrow
    CGFloat arrowRatio = .5f;
    CGSize backArrowSize = CGSizeMake(28.0f*arrowRatio, 28.0f*arrowRatio);
    CGRect backArrowFrame = CGRectMake(backButtonFrame.origin.x, (backButtonFrame.size.height-backArrowSize.height)/2+PADDING_TOP, backArrowSize.width, backArrowSize.height);
    UIImageView* backArrowView = [[UIImageView alloc] initWithFrame:backArrowFrame];
    backArrowView.image = [UIImage imageNamed:@"arrow_back"];
    backArrowView.backgroundColor = DEBUG_SHOW_COLORS ? [UIColor redColor] : [UIColor clearColor];
    [backButton addSubview:backArrowView];
    
    //back button title
    NSString* categoryName = [titleOfReturningToViewController uppercaseString];
    UIFont* font = [UIFont fontWithName:@"Georgia" size:10.0f];
    CGSize textSize = [categoryName sizeWithFont:font];
    CGFloat paddingLeft = 5.0f;
    CGSize someLabelSize = CGSizeMake(textSize.width, textSize.height);
    CGRect someLabelFrame = CGRectMake(backArrowFrame.origin.x+backArrowFrame.size.width+paddingLeft, (backButtonFrame.size.height-someLabelSize.height)/2+PADDING_TOP, someLabelSize.width, someLabelSize.height);
    UILabel* someLabel = [[UILabel alloc] initWithFrame:someLabelFrame];
    someLabel.text = categoryName;
    someLabel.backgroundColor = DEBUG_SHOW_COLORS ? [UIColor greenColor] : [UIColor clearColor];
    someLabel.font = font;
    [backButton addSubview:someLabel];
    
    //resize the frame
    backButtonFrame = CGRectMake(backButtonFrame.origin.x, backButtonFrame.origin.y, backArrowSize.width+paddingLeft+someLabelSize.width, backButtonFrame.size.height);
    backButton.frame = backButtonFrame;
    
    //setup the buttonItem
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}


-(UIView*)firstRunLoadingView
{
    if (_firstRunLoadingView==nil) {
        
        //set up the loading view
        CGRect loadingViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        UIView* aView = [[UIView alloc] initWithFrame:loadingViewFrame];
        aView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        aView.backgroundColor = [UIColor redColor];
        
        CGRect imageViewRect = CGRectMake(0.0f, 0.0f, loadingViewFrame.size.width, 480.0f-20.0f);
        UIImageView* aImageView = [[UIImageView alloc] initWithFrame:imageViewRect];
        aImageView.image = [UIImage imageNamed:@"loading_mercedes_k.png"];
        [aView addSubview:aImageView];
        
        CGSize aiSize = CGSizeMake(21.0f, 21.0f);
        CGFloat scalingFactor = 0.8;
        UIActivityIndicatorView *aiV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        aiV.frame = CGRectMake((self.view.frame.size.width-aiSize.width)/2, 265.0f, aiSize.width*scalingFactor, aiSize.height*scalingFactor);
        [aView addSubview:aiV];
        [aiV startAnimating];
        
         [aiV.layer setValue:[NSNumber numberWithFloat:scalingFactor] forKeyPath:@"transform.scale"];
        
        _firstRunLoadingView = aView;
        
    }

    return _firstRunLoadingView;
}


-(void)setIsFirstRunLoadingViewHidden:(BOOL)hidden animated:(BOOL)animated
{
    
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    if (hidden) {
        [self.firstRunLoadingView removeFromSuperview];
    }
    else {
        CGRect newFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.firstRunLoadingView.frame = newFrame;
        [self.view addSubview:self.firstRunLoadingView];   
        [self setIsLoadingViewHidden:YES];
        [self setIsCouldNotLoadDataViewHidden:YES];
        [self setIsNoConnectionViewHidden:YES];
    }
}


-(UIView*)loadingView
{
    if (_loadingView==nil) {
        
        //set up the loading view
        CGRect loadingViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        UIView* aView = [[UIView alloc] initWithFrame:loadingViewFrame];
        aView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        aView.backgroundColor = [UIColor whiteColor];
        
        
        //set up the label
        CGSize labelSize = CGSizeMake(280.0f, 20.0f);
        CGRect someLabelFrame = CGRectMake((CGRectGetWidth(self.view.frame)-labelSize.width)/2, (CGRectGetHeight(self.view.frame)-labelSize.height)/2, labelSize.width, labelSize.height);
        UILabel* someLabel = [[UILabel alloc] initWithFrame:someLabelFrame];
        someLabel.textAlignment = UITextAlignmentCenter;
        someLabel.numberOfLines = 2;
#warning find better text!
#warning add fonts to constants    
        someLabel.text = @"loading"; 
        someLabel.font = [UIFont fontWithName:@"Georgia" size:12.0f];
        someLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.loadingViewLabel = someLabel;
        
        [aView addSubview:someLabel];
        
        
        //set up the activity indicator
        CGFloat paddingTop = .0f;
        CGSize activityIndicatorSize = CGSizeMake(44.0f, 44.0f);
        CGRect activityIndicatorFrame = CGRectMake((loadingViewFrame.size.width-activityIndicatorSize.width)/2, someLabelFrame.origin.y+someLabelFrame.size.height+paddingTop, activityIndicatorSize.width, activityIndicatorSize.height);
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.frame = activityIndicatorFrame;
        activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [aView addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        _loadingView = aView;
    }

    return _loadingView;
}


-(void)setIsLoadingViewHidden:(BOOL)hidden
{
    [self setIsLoadingViewHidden:hidden animated:NO];
}

-(void)setIsLoadingViewHidden:(BOOL)hidden animated:(BOOL)animated
{
    
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    if (hidden) {
        [self.loadingView removeFromSuperview];
    }
    else {
        CGRect newFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.loadingView.frame = newFrame;
        [self.view addSubview:self.loadingView];   
        [self setIsCouldNotLoadDataViewHidden:YES];
        [self setIsNoConnectionViewHidden:YES];
        [self setIsFirstRunLoadingViewHidden:YES animated:NO];
    }
}

-(UIView*)noInternetConnectionView
{
    if (_noInternetConnectionView==nil) {
        
        //set up the no internet connection view
        CGRect noInternetConnectionViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        UIView* someView = [[UIView alloc] initWithFrame:noInternetConnectionViewFrame];
        someView.backgroundColor = [UIColor whiteColor];
        
        //set up the label
        CGSize labelSize = CGSizeMake(280.0f, 40.0f);
        CGRect someLabelFrame = CGRectMake((CGRectGetWidth(self.view.frame)-labelSize.width)/2, (CGRectGetHeight(self.view.frame)-labelSize.height)/2, labelSize.width, labelSize.height);
        UILabel* someLabel = [[UILabel alloc] initWithFrame:someLabelFrame];
        someLabel.textAlignment = UITextAlignmentCenter;
        someLabel.numberOfLines = 2;
        someLabel.text = @"Sorry, but you need an internet connection to view this tumblr feed"; 
#warning find better text!
#warning add fonts to constants    
        someLabel.font = [UIFont fontWithName:@"Georgia" size:14.0f];
        
        [someView addSubview:someLabel];
        
        _noInternetConnectionView = someView;
    }
    
    return _noInternetConnectionView;
}


-(void)setIsNoConnectionViewHidden:(BOOL)hidden
{     
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    if (hidden) {
        [_noInternetConnectionView removeFromSuperview];
    }
    else {
        CGRect newFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.noInternetConnectionView.frame = newFrame;
        [self.view addSubview:_noInternetConnectionView];     
        [self setIsCouldNotLoadDataViewHidden:YES];
        [self setIsLoadingViewHidden:YES];
        [self setIsFirstRunLoadingViewHidden:YES animated:NO];
    }
}

-(void)setUpForOfflineUse
{
    [self setIsNoConnectionViewHidden:NO];
}

-(void)setUpForOnlineUse
{
    [self setIsNoConnectionViewHidden:YES];    
}


#pragma mark - IgnantImporter delegate

-(void)didStartImportingData
{

}

-(void)didFailImportingData
{
    
}

-(void)didFinishImportingData
{
    
}

-(void)importerDidStartParsingSingleArticle:(IgnantImporter*)importer
{
    
}
-(void)importer:(IgnantImporter*)importer didFinishParsingSingleArticleWithDictionary:(NSDictionary*)articleDictionary
{
    
}
-(void)importer:(IgnantImporter*)importer didFailParsingSingleArticleWithDictionary:(NSDictionary*)articleDictionary
{
    
}


@end
