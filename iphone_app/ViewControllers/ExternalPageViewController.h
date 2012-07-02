//
//  ExternalPageViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 02.07.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IGNViewController.h"

@interface ExternalPageViewController : IGNViewController <UIWebViewDelegate>
@property (retain, nonatomic) IBOutlet UIWebView *externalPageWebView;
-(void)openURL:(NSURL*)url;
@end
