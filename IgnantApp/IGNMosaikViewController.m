//
//  IGNMosaikViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 03.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "IGNMosaikViewController.h"

@implementation IGNMosaikViewController

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

#pragma mark - handle going back
-(IBAction)handleBack:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    //add the back-to-start button
    UIImage *backButtonImage = [UIImage imageNamed:@"backButton.png"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat ratio = .65;
    backButton.frame = CGRectMake(0, 0, 46*ratio, 30*ratio);
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(handleBack:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
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

@end
