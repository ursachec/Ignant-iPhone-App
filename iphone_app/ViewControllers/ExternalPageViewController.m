//
//  ExternalPageViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 02.07.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "ExternalPageViewController.h"

@interface ExternalPageViewController ()
@end

@implementation ExternalPageViewController
@synthesize externalPageWebView;



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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)dismiss:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

-(void)openURL:(NSURL*)url
{    
    NSLog(@"openURL");
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
    [self.externalPageWebView loadRequest:req];
}


#pragma mark - uiwebview delegate
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"didFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError");
}

@end
