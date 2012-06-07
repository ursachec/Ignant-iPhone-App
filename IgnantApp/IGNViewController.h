//
//  IGNViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 04.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGNViewController : UIViewController

-(void)setIsLoadingViewHidden:(BOOL)hidden;
-(void)setIsLoadingViewHidden:(BOOL)hidden animated:(BOOL)animated;

-(void)setIsNoConnectionViewHidden:(BOOL)hidden;

-(void)setUpForOfflineUse;
-(void)setUpForOnlineUse;

-(void)setIsFullscreenNoInternetConnectionViewHidden:(BOOL)hidden;
-(void)setIsFullscreenLoadingViewHidden:(BOOL)hidden;

@end
