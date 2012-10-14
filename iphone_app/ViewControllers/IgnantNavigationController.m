//
//  IgnantNavigationController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 01.10.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "IgnantNavigationController.h"

@interface IgnantNavigationController ()

@end

@implementation IgnantNavigationController

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
	
	UINavigationBar* navBar = self.navigationBar;
	
	CGSize navBarSize = navBar.bounds.size;
	CGSize ignantLogoSize = CGSizeMake(26.0f,26.0f);
		
	UIImageView* ignantLogo = [[UIImageView alloc] initWithFrame:CGRectMake((navBarSize.width-ignantLogoSize.width)/2, (navBarSize.height-ignantLogoSize.height)/2, ignantLogoSize.width, ignantLogoSize.height)];
	ignantLogo.image = [UIImage imageNamed:@"navbar_ignant_logo"];
	ignantLogo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
	[self.navigationBar addSubview:ignantLogo];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - autorotation

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

@end
