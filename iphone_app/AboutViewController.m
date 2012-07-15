//
//  AboutViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 04.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController
@synthesize aboutScrollView;
@synthesize aboutTextView;
@synthesize aboutImageView;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
    CGFloat paddingTop = 5.0f;
    CGFloat paddingBottom = 25.0f;
    
    
    CGRect oldAboutTextViewFrame = self.aboutTextView.frame;
    NSString* aboutText = NSLocalizedString(@"about_text", nil);    
    self.aboutTextView.text = aboutText;
    
    
    CGSize constraintSize;
    constraintSize.width = 310.0f;
    constraintSize.height = MAXFLOAT;
    CGSize aboutImageViewSize = self.aboutImageView.frame.size;
    CGSize textSize = [self.aboutTextView.text sizeWithFont:self.aboutTextView.font constrainedToSize:constraintSize];
    
    CGRect newAboutTextViewFrame = CGRectMake(oldAboutTextViewFrame.origin.x, oldAboutTextViewFrame.origin.y, oldAboutTextViewFrame.size.width, textSize.height+8.0f);
    self.aboutTextView.frame = newAboutTextViewFrame;
    
    CGFloat newAboutScrollViewHeight = paddingTop+aboutImageViewSize.height+textSize.height+paddingBottom;
    self.aboutScrollView.contentSize = CGSizeMake(310.0f, newAboutScrollViewHeight);
        
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSError* error = nil;
    [[GANTracker sharedTracker] trackPageview:kGAPVAboutView
                                    withError:&error];
}

- (void)viewDidUnload
{
    [self setAboutTextView:nil];
    [self setAboutImageView:nil];
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
