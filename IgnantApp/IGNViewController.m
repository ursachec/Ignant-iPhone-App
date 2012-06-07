//
//  IGNViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 04.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "IGNViewController.h"
#import "IgnantLoadingView.h"
#import "IgnantNoInternetConnectionView.h"

#import "Constants.h"

@interface IGNViewController ()
{

}
@property(nonatomic, retain) UIView* loadingView;
@property(nonatomic, retain) UIView* noInternetConnectionView;


@property(nonatomic, retain) IgnantLoadingView* fullscreenLoadingView;
@property(nonatomic, retain) IgnantNoInternetConnectionView* fullscreenNoInternetConnectionView;


-(void)setUpFullscreenNoInternetConnectionView;
-(void)setUpFullscreenLoadingView;


@end

@implementation IGNViewController
@synthesize loadingView = _loadingView;
@synthesize noInternetConnectionView = _noInternetConnectionView;
@synthesize fullscreenLoadingView = _fullscreenLoadingView;
@synthesize fullscreenNoInternetConnectionView = _fullscreenNoInternetConnectionView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self setUpFullscreenLoadingView];
        [self setUpFullscreenNoInternetConnectionView];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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

    //add the back-to-start button
    UIImage *backButtonImage = [UIImage imageNamed:@"navigationButtonBack"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat ratio = .5;
    backButton.frame = CGRectMake(0, 0, 122*ratio, 57*ratio);
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton setImage:backButtonImage forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(handleBack:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    [backBarButtonItem release];
    
    
    //set up the loading view
    CGRect loadingViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    UIView* aView = [[UIView alloc] initWithFrame:loadingViewFrame];
    aView.backgroundColor = [UIColor whiteColor];
    
    CGSize activityIndicatorSize = CGSizeMake(44.0f, 44.0f);
    CGRect activityIndicatorFrame = CGRectMake((loadingViewFrame.size.width-activityIndicatorSize.width)/2, (loadingViewFrame.size.height-activityIndicatorSize.height)/2, activityIndicatorSize.width, activityIndicatorSize.height);
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = activityIndicatorFrame;
    [aView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    [activityIndicator release];
    
    
    self.loadingView = aView;
    [aView release];
    
    
    //set up the no internet connection view
    CGRect noInternetConnectionViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    UIView* someView = [[UIView alloc] initWithFrame:noInternetConnectionViewFrame];
    someView.backgroundColor = [UIColor redColor];
    self.noInternetConnectionView = someView;
    [someView release];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.loadingView = nil;
    self.noInternetConnectionView = nil;

    self.fullscreenNoInternetConnectionView = nil;
    self.fullscreenLoadingView = nil;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setIsLoadingViewHidden:(BOOL)hidden
{
    [self setIsLoadingViewHidden:hidden animated:NO];
}

-(void)setIsLoadingViewHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (hidden) {
        [_loadingView removeFromSuperview];
    }
    else {
        [self.view addSubview:_loadingView];        
    }
}

-(void)setIsNoConnectionViewHidden:(BOOL)hidden
{        
    if (hidden) {
        [_noInternetConnectionView removeFromSuperview];
    }
    else {
        [self.view addSubview:_noInternetConnectionView];        
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

#pragma mark - special views
-(void)setUpFullscreenNoInternetConnectionView
{
    //loading the custom loading view from a nib file
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"IgnantNoInternetConnectionView"
                                                    owner:self 
                                                  options:nil];
    IgnantNoInternetConnectionView *view;
    for (id object in bundle) {
        if ([object isKindOfClass:[IgnantNoInternetConnectionView class]])
            view = (IgnantNoInternetConnectionView *)object;
    }
    self.fullscreenNoInternetConnectionView = view;
}

-(void)setIsFullscreenNoInternetConnectionViewHidden:(BOOL)hidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (hidden) {
            [_fullscreenNoInternetConnectionView removeFromSuperview];
        }
        
        else {
            [self.navigationController.view addSubview:_fullscreenNoInternetConnectionView];
            [self.navigationController.view bringSubviewToFront:_fullscreenNoInternetConnectionView];
            [self setIsFullscreenLoadingViewHidden:YES];
        }
    });
}

-(void)setUpFullscreenLoadingView
{
    //loading the custom loading view from a nib file
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"IgnantLoadingView"
                                                    owner:self 
                                                  options:nil];
    IgnantLoadingView *view;
    for (id object in bundle) {
        if ([object isKindOfClass:[IgnantLoadingView class]])
            view = (IgnantLoadingView *)object;
    }
    self.fullscreenLoadingView = view;
}

-(void)setIsFullscreenLoadingViewHidden:(BOOL)hidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"setIsFullscreenLoadingViewHidden: %@", hidden ? @"TRUE" : @"FALSE");
        
        if (hidden) {
            [_fullscreenLoadingView removeFromSuperview];
        }
        
        else {
            [self.navigationController.view addSubview:_fullscreenLoadingView];
            [self.navigationController.view bringSubviewToFront:_fullscreenLoadingView];
        }
        
    });
    
}

@end
