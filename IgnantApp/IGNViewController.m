//
//  IGNViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 04.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "IGNViewController.h"


@interface IGNViewController ()
{

}
@property(nonatomic, retain) UIView* loadingView;
@end

@implementation IGNViewController
@synthesize loadingView = _loadingView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
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
    
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.loadingView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setIsLoadingViewHidden:(BOOL)hidden
{
    if (hidden) {
        [_loadingView removeFromSuperview];
    }
    else {
        [self.view addSubview:_loadingView];        
    }
}

-(void)setUpForOfflineUse
{

}

-(void)setUpForOnlineUse
{
    
}


@end
