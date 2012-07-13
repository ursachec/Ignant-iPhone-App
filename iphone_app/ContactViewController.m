//
//  ContactViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 04.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import "ContactViewController.h"
#import "Constants.h"

NSString * const kEmailClaudiu = @"claudiu@cvursache.com";
NSString * const kEmailIgnant = @"clemens@ignant.de";
NSString * const kEmailDeutscheUndJapaner = @"info@deutscheundjapaner.de";

@implementation ContactViewController

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

- (IBAction)handleTapOnDeutscheJapaner:(id)sender {
    LOG_CURRENT_FUNCTION()
    [self displayComposerSheetWithRecipient:kEmailDeutscheUndJapaner];
}

- (IBAction)handleTapOnClaudiu:(id)sender {
    LOG_CURRENT_FUNCTION()
    [self displayComposerSheetWithRecipient:kEmailClaudiu];
}

- (IBAction)handleTapOnClemens:(id)sender {
    LOG_CURRENT_FUNCTION()
    [self displayComposerSheetWithRecipient:kEmailIgnant];
}


#pragma mark - mail composer
-(void)displayComposerSheetWithRecipient:(NSString*)recepient
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // Set up the recipients.
    NSArray *toRecipients = @[recepient];
    [picker setToRecipients:toRecipients];
    
#warning TODO: LOCALIZE STRINGS
    //set the subject
    NSString* emailSubject = @"";
    if ([recepient compare:kEmailIgnant]==NSOrderedSame) {
        emailSubject = @"";
    }
    else if ([recepient compare:kEmailClaudiu]==NSOrderedSame) {
        emailSubject = @"";
    }
    else if ([recepient compare:kEmailDeutscheUndJapaner]==NSOrderedSame) {
        emailSubject = @"";
    }
    [picker setSubject:emailSubject];
    
    //set the email body text
    NSString *emailBody = @"";
    
    if ([recepient compare:kEmailIgnant]==NSOrderedSame) {
        emailBody = @"Hi Clemens!";
    }
    else if ([recepient compare:kEmailClaudiu]==NSOrderedSame) {
        emailBody = @"Hi Claudiu!";
    }
    else if ([recepient compare:kEmailDeutscheUndJapaner]==NSOrderedSame) {
        emailBody = @"Hi Deutsche und Japaner!";
    }
    
    [picker setMessageBody:emailBody isHTML:NO];
    
    // Present the mail composition interface.
    [self presentModalViewController:picker animated:YES];
}

// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
