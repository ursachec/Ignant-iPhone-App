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

@property(nonatomic, strong, readwrite) UIView* specificNavigationBar;
@property(nonatomic, strong, readwrite) UIView* specificToolbar;

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

@synthesize specificNavigationBar = _specificNavigationBar;
@synthesize specificToolbar = _specificToolbar;


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
    DBLog(@"init importer");
    
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
-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
		
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	   
    [self.appDelegate setIsToolbarHidden:NO animated:YES];
}

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

#pragma mark - specific navigation bar
-(void)toggleShowSpecificNavigationBarAnimated:(BOOL)animated
{    
    if (self.specificNavigationBar.alpha==0) {
        [self setIsSpecificNavigationBarHidden:NO animated:animated];
    }
    else {
        [self setIsSpecificNavigationBarHidden:YES animated:animated];
    }
}

-(void)setIsSpecificNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    CGFloat activeAlpha = 1.0f;
    CGFloat animationDuration = 0.3f;
    
    if (!animated) {
        if (hidden) {
            self.specificNavigationBar.alpha = 0.0;
            self.specificNavigationBar.userInteractionEnabled = NO;
        }
        else {
            self.specificNavigationBar.alpha = activeAlpha;
            self.specificNavigationBar.userInteractionEnabled = YES;
        }
    }
    else {
        
        __block UIView* blockSpecificNavigationBar = self.specificNavigationBar;
        
        if (blockSpecificNavigationBar.alpha==0.0f) {
            
            [UIView animateWithDuration:animationDuration 
                             animations:^{
                                 blockSpecificNavigationBar.alpha = activeAlpha;
                             } 
                             completion:^(BOOL finished){ 
                                 blockSpecificNavigationBar.userInteractionEnabled = YES;
                                 
                             }];
        }
        else {
            
            [UIView animateWithDuration:animationDuration 
                             animations:^{
                                 blockSpecificNavigationBar.alpha = .0f;
                             } 
                             completion:^(BOOL finished){ 
                                 blockSpecificNavigationBar.userInteractionEnabled = NO;
                             }];
        }
    }
}

-(UIView*)specificNavigationBar
{
	
#define DEBUG_SHOW_COLORS false
#define NAVBAR_PADDING_TOP 0.0f
#define PADDING_LEFT 3.0f
    	
    if (_specificNavigationBar==nil) {
        
        CGRect specificNavigationBarFrame = CGRectMake(0.0f, 0.0f, 320.f, 44.0f);
        UIView* navView = [[UIView alloc] initWithFrame:specificNavigationBarFrame];
        navView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		navView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ign_nav_bar_pattern.png"]];
		
		//logo view
		CGSize ignantLogoSize = CGSizeMake(20.0f, 23.0f);
		CGRect ignantLogoFrame = CGRectMake((navView.bounds.size.width-ignantLogoSize.width)/2, (navView.bounds.size.height-ignantLogoSize.height)/2, ignantLogoSize.width, ignantLogoSize.height);
        UIImageView* ignantLogoView = [[UIImageView alloc] initWithFrame:ignantLogoFrame];
		ignantLogoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
		ignantLogoView.image = [UIImage imageNamed:@"ignant_logo_small.png"];
        [navView addSubview:ignantLogoView];
        
        //add the back button
        //back button
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect backButtonFrame = CGRectMake(PADDING_LEFT, 0.0f, 100.0f, 44.0f);
        backButton.frame = backButtonFrame;
        backButton.backgroundColor = DEBUG_SHOW_COLORS ? [UIColor blueColor] : [UIColor clearColor];
        [backButton addTarget:self action:@selector(handleTapOnSpecificNavBarBackButton:) forControlEvents:UIControlEventTouchDown];
        
        //arrow
        CGFloat arrowRatio = .25f;
        CGSize backArrowSize = CGSizeMake(17.0f*arrowRatio, 26.0f*arrowRatio);
        CGRect backArrowFrame = CGRectMake(backButtonFrame.origin.x, (backButtonFrame.size.height-backArrowSize.height)/2+NAVBAR_PADDING_TOP, backArrowSize.width, backArrowSize.height);
        UIImageView* backArrowView = [[UIImageView alloc] initWithFrame:backArrowFrame];
        backArrowView.image = [UIImage imageNamed:@"arrow_left.png"];
        backArrowView.backgroundColor = DEBUG_SHOW_COLORS ? [UIColor redColor] : [UIColor clearColor];
        [backButton addSubview:backArrowView];
        
        //back button title
        NSString* categoryName = [@"back" uppercaseString];
        UIFont* font = [UIFont fontWithName:@"Georgia" size:9.0f];
        CGSize textSize = [categoryName sizeWithFont:font];
        CGFloat paddingLeft = 5.0f;
        CGSize someLabelSize = CGSizeMake(textSize.width, textSize.height);
        CGRect someLabelFrame = CGRectMake(backArrowFrame.origin.x+backArrowFrame.size.width+paddingLeft, (backButtonFrame.size.height-someLabelSize.height)/2+NAVBAR_PADDING_TOP, someLabelSize.width, someLabelSize.height);
        UILabel* someLabel = [[UILabel alloc] initWithFrame:someLabelFrame];
        someLabel.text = categoryName;
        someLabel.backgroundColor = DEBUG_SHOW_COLORS ? [UIColor greenColor] : [UIColor clearColor];
        someLabel.font = font;
        [backButton addSubview:someLabel];
        
        //resize the frame
        backButtonFrame = CGRectMake(backButtonFrame.origin.x, backButtonFrame.origin.y, backArrowSize.width+paddingLeft+someLabelSize.width, backButtonFrame.size.height);
        backButton.frame = backButtonFrame;
        
        //add the home button
        UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect homeButtonFrame = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
        homeButton.frame = homeButtonFrame;
        homeButton.backgroundColor = DEBUG_SHOW_COLORS ? [UIColor blueColor] : [UIColor clearColor];
        [homeButton addTarget:self action:@selector(handleTapOnSpecificNavBarHomeButton:) forControlEvents:UIControlEventTouchDown];
        
        //resize the frame for the home button
        homeButtonFrame = CGRectMake((navView.frame.size.width-homeButton.frame.size.width)/2, (navView.frame.size.height-homeButton.frame.size.height)/2,homeButtonFrame.size.width, homeButtonFrame.size.height);
        homeButton.frame = homeButtonFrame;
		
		
		CGRect navBarFrame = specificNavigationBarFrame;
		
		//set up the gradient view
		CGSize gradientViewSize = CGSizeMake(2000.0f, 3.0f);
		CGRect gradientViewFrame = CGRectMake(navBarFrame.origin.x, navBarFrame.origin.y+navBarFrame.size.height, gradientViewSize.width, gradientViewSize.height);
		UIView* gradientView = [[UIView alloc] initWithFrame:gradientViewFrame];
		gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		gradientView.backgroundColor = [UIColor clearColor];
		
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.frame = gradientView.bounds;
		gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:223.0f/255.0f green:223.0f/255.0f blue:223.0f/255.0f alpha:.5f] CGColor], (id)[[UIColor colorWithRed:223.0f/255.0f green:223.0f/255.0f blue:223.0f/255.0f alpha:0.f] CGColor], nil];
		[gradientView.layer insertSublayer:gradient atIndex:0];
		gradientView.contentMode = UIViewContentModeScaleAspectFill;
		
        
		//add the ignant logo
		
		
		
		
        [navView addSubview:homeButton];
        [navView addSubview:backButton];
        [navView addSubview:gradientView];
        
        _specificNavigationBar = navView;
    }
    
	
	
	
	
    return _specificNavigationBar;
}

-(void)handleTapOnSpecificNavBarBackButton:(id)sender
{
    DBLog(@"handleTapOnSpecificNavBarBackButton");
}

-(void)handleTapOnSpecificNavBarHomeButton:(id)sender
{
    DBLog(@"handleTapOnSpecificNavBarHomeButton");
    [self.appDelegate showHome];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - specific toolbar

-(void)toggleShowSpecificToolbar
{    
    if (self.specificToolbar.alpha==0) {
        [self setIsSpecificToolbarHidden:NO animated:YES];
    }
    else {
        [self setIsSpecificToolbarHidden:YES animated:NO];
    }
}

-(void)setIsSpecificToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
    CGFloat activeAlpha = 1.0f;
    CGFloat animationDuration = 0.3f;
    
    if (!animated) {
        if (hidden) {
            self.specificToolbar.alpha = 0.0;
            self.specificToolbar.userInteractionEnabled = NO;
        }
        else {
            self.specificToolbar.alpha = activeAlpha;
            self.specificToolbar.userInteractionEnabled = YES;
        }
    }
    else {
        
        __block UIView* blockSpecificToolbar = self.specificToolbar;
        
        if (blockSpecificToolbar.alpha==0.0f) {
            
            [UIView animateWithDuration:animationDuration 
                             animations:^{
                                 blockSpecificToolbar.alpha = activeAlpha;
                             } 
                             completion:^(BOOL finished){ 
                                 blockSpecificToolbar.userInteractionEnabled = YES;
                                 
                             }];
        }
        else {
            
            [UIView animateWithDuration:animationDuration 
                             animations:^{
                                 blockSpecificToolbar.alpha = .0f;
                             } 
                             completion:^(BOOL finished){ 
                                 blockSpecificToolbar.userInteractionEnabled = NO;
                             }];
        }
    }
}

-(UIView*)specificToolbar
{
#define DEBUG_SHOW_DEBUG_COLORS false
    
    if (_specificToolbar==nil) {
        
        CGSize toolbarSize = CGSizeMake(320.0f, 50.0f);
        CGRect toolbarFrame = CGRectMake(0.0f, DeviceHeight-20.0f-toolbarSize.height, toolbarSize.width, toolbarSize.height);
        UIView* aView = [[UIView alloc] initWithFrame:toolbarFrame];
        aView.backgroundColor = [UIColor clearColor];
        if(DEBUG_SHOW_DEBUG_COLORS)
            aView.backgroundColor = [UIColor redColor];
        
        //set up the background imageview
        CGSize imageViewSize = toolbarSize;
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, imageViewSize.width, imageViewSize.height)];
        backgroundImageView.image = [UIImage imageNamed:@"mb_footer.png"];
        
        if(DEBUG_SHOW_DEBUG_COLORS)
            backgroundImageView.backgroundColor = [UIColor greenColor];
        
        [aView addSubview:backgroundImageView];
        
        //add buttons
        CGFloat paddingAmmount = 20.0f;
        CGFloat paddingTop = 9.0f;
        UIFont *buttonFont = [UIFont fontWithName:@"Georgia" size:11.0f]; 
        UIColor*buttonTextColor = [UIColor blackColor];
           
        CGSize buttonSize = CGSizeMake(85.0f, 37.0f);
        CGRect firstButtonFrame = CGRectMake(paddingAmmount, paddingTop, buttonSize.width, buttonSize.height);
        UIButton* firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
        firstButton.titleLabel.font = buttonFont;
        [firstButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
        firstButton.frame = firstButtonFrame;
        [firstButton setTitle:[NSLocalizedString(@"toolbar_mosaic", @"") uppercaseString] forState:UIControlStateNormal];
        [firstButton addTarget:self action:@selector(handleTapOnSpecificToolbarLeft:) forControlEvents:UIControlEventTouchDown];
        [aView addSubview:firstButton];
        
        CGSize buttonSize2 = CGSizeMake(72.0f, 37.0f);
        CGRect secondButtonFrame = CGRectMake(aView.frame.size.width-buttonSize2.width-paddingAmmount, paddingTop, buttonSize2.width, buttonSize2.height);
        UIButton* secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
        secondButton.titleLabel.font = buttonFont;
        [secondButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
        secondButton.frame = secondButtonFrame;
        [secondButton setTitle:[NSLocalizedString(@"toolbar_more", @"") uppercaseString] forState:UIControlStateNormal];
        [secondButton addTarget:self action:@selector(handleTapOnSpecificToolbarRight:) forControlEvents:UIControlEventTouchDown];
        [aView addSubview:secondButton];
        
        CGSize mercedesButtonSize = CGSizeMake(40.0f, 40.0f);
        CGRect mercedesButtonFrame = CGRectMake((aView.frame.size.width-mercedesButtonSize.width)/2, (aView.frame.size.height-mercedesButtonSize.height)/2, mercedesButtonSize.width, mercedesButtonSize.height);
        UIButton* mercedesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        mercedesButton.frame = mercedesButtonFrame;
        mercedesButton.backgroundColor = [UIColor clearColor];
        [mercedesButton setTitle:@"" forState:UIControlStateNormal];
        [mercedesButton addTarget:self action:@selector(handleTapOnSpecificToolbarMercedes:) forControlEvents:UIControlEventTouchDown];
        [aView addSubview:mercedesButton];
        
         _specificToolbar = aView;
    }
    
    return _specificToolbar;
}

-(void)handleTapOnSpecificToolbarLeft:(id)sender
{
    LOG_CURRENT_FUNCTION()
}

-(void)handleTapOnSpecificToolbarMercedes:(id)sender
{
    LOG_CURRENT_FUNCTION()
}

-(void)handleTapOnSpecificToolbarRight:(id)sender
{
    LOG_CURRENT_FUNCTION()
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
        someLabel.text = NSLocalizedString(@"could_not_load_data", @"Title for the couldNotLoadDataLabel when trying to load data, but not successful because of some error");; 
        someLabel.font = [UIFont fontWithName:@"Georgia" size:12.0f];
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
        
        [self setIsLoadingViewHidden:YES];
        [self setIsNoConnectionViewHidden:YES];
        [self setIsFirstRunLoadingViewHidden:YES animated:NO];
        
    }
}

-(void)setIsCouldNotLoadDataViewHidden:(BOOL)hidden fullscreen:(BOOL)fullscreen
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    if (!fullscreen) {
        [self setIsCouldNotLoadDataViewHidden:hidden];
        return;
    }
    
    
    if (hidden) {
        [_couldNotLoadDataView removeFromSuperview];
    }
    else {
        CGRect newFrame = CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
        self.couldNotLoadDataView.frame = newFrame;
        
        CGFloat paddingTop = 20.0f;
        CGRect oldFrameForLabel = self.couldNotLoadDataLabel.frame;
        CGRect newFrameForLabel = CGRectMake(oldFrameForLabel.origin.x, (newFrame.size.height-oldFrameForLabel.size.height)/2+paddingTop, oldFrameForLabel.size.width, oldFrameForLabel.size.height);
        self.couldNotLoadDataLabel.frame = newFrameForLabel;

        
        [self.navigationController.view addSubview:self.couldNotLoadDataView];        
                
        [self setIsLoadingViewHidden:YES];
        [self setIsNoConnectionViewHidden:YES];
        [self setIsFirstRunLoadingViewHidden:YES animated:NO];
    }
}

-(void)setUpBackButton
{
#define DEBUG_SHOW_COLORS false
    
    NSString* titleOfReturningToViewController = self.viewControllerToReturnTo.title;
    
    if (titleOfReturningToViewController==nil) {
        titleOfReturningToViewController = NSLocalizedString(@"back_button_back_title", @"Title of the back button in the navigation bar");
    }
    
#define PADDING_TOP 1.0f
    
    //back button
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect backButtonFrame = CGRectMake(0, 0, 100.0f, 57.0f);
    backButton.frame = backButtonFrame;
    backButton.backgroundColor = DEBUG_SHOW_COLORS ? [UIColor blueColor] : [UIColor clearColor];
    [backButton addTarget:self action:@selector(handleBack:) forControlEvents:UIControlEventTouchDown];
    
    //arrow
    CGFloat arrowRatio = .3f;
    CGSize backArrowSize = CGSizeMake(17.0f*arrowRatio, 26.0f*arrowRatio);
    CGRect backArrowFrame = CGRectMake(backButtonFrame.origin.x, (backButtonFrame.size.height-backArrowSize.height)/2+PADDING_TOP, backArrowSize.width, backArrowSize.height);
    UIImageView* backArrowView = [[UIImageView alloc] initWithFrame:backArrowFrame];
    backArrowView.image = [UIImage imageNamed:@"arrow_left"];
    backArrowView.backgroundColor = DEBUG_SHOW_COLORS ? [UIColor redColor] : [UIColor clearColor];
    [backButton addSubview:backArrowView];
    
    //back button title
    NSString* categoryName = [titleOfReturningToViewController uppercaseString];
    UIFont* font = [UIFont fontWithName:@"Georgia" size:9.0f];
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
        aView.backgroundColor = [UIColor whiteColor];
        
        CGRect imageViewRect = CGRectMake(0.0f, 0.0f, loadingViewFrame.size.width, DeviceHeight-20.0f);
        UIImageView* aImageView = [[UIImageView alloc] initWithFrame:imageViewRect];
		
		if([UIScreen mainScreen].bounds.size.height == 568.0){
			aImageView.image = [UIImage imageNamed:@"Default-568h-NO-TOP@2x.png"];
		}
		else{
			aImageView.image = [UIImage imageNamed:@"DefaultNoTOPX"];
		}
		
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
        CGRect newFrame = CGRectMake(0, 20.0f, self.view.frame.size.width, self.view.frame.size.height);
        self.firstRunLoadingView.frame = newFrame;
        [self.navigationController.view addSubview:self.firstRunLoadingView];   
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
        
        //set up the activity indicator
        CGFloat scalingFactor = 0.7f;
        CGSize activityIndicatorSize = CGSizeMake(21.0f, 21.0f);
        CGRect activityIndicatorFrame = CGRectMake((loadingViewFrame.size.width-activityIndicatorSize.width*scalingFactor)/2, (loadingViewFrame.size.height-activityIndicatorSize.height*scalingFactor)/2, activityIndicatorSize.width*scalingFactor, activityIndicatorSize.height*scalingFactor);
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.frame = activityIndicatorFrame;
        activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [activityIndicator.layer setValue:[NSNumber numberWithFloat:scalingFactor] forKeyPath:@"transform.scale"];
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
        someLabel.text = NSLocalizedString(@"no_internet_connection_feed_text", @"");     
        someLabel.font = [UIFont fontWithName:@"Georgia" size:12.0f];
        
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

#pragma mark - specific actions
-(void)loadLatestContent
{
	LOG_CURRENT_FUNCTION_AND_CLASS()
}

-(void)triggerLoadLatestDataIfNecessary
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
	
	[self loadLatestContent];
}

-(NSString*)currentPreferredLanguage
{
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    return language;
}


#pragma mark - resource loading
-(void)triggerLoadingImageAtURL:(NSURL*)url forImageView:(UIImageView*)imageView
{
    __block NSURL* blockThumbURL = url;
    __block UIImageView* blockImageView = imageView;
    
    [blockImageView  setImageWithURL:blockThumbURL
                    placeholderImage:nil
                             success:^(UIImage* image){
								 
								 blockImageView.alpha = .0f;
								 [UIView animateWithDuration:ASYNC_IMAGE_DURATION animations:^{
									 blockImageView.alpha = 1.0f;
								 }];
								 
                                 DBLog(@"loaded triggerLoadingImageAtURL: %@", blockThumbURL);
                             }
                             failure:^(NSError* aError){
                                 DBLog(@"could NOT load triggerLoadingImageAtURL: %@", blockThumbURL);
                             }];
}


#pragma mark - autorotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}



@end
