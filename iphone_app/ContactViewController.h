//
//  ContactViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 04.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGNViewController.h"
#import <MessageUI/MessageUI.h>

@interface ContactViewController : IGNViewController <MFMailComposeViewControllerDelegate>
- (IBAction)handleTapOnDeutscheJapaner:(id)sender;
- (IBAction)handleTapOnClaudiu:(id)sender;
- (IBAction)handleTapOnClemens:(id)sender;

@end
