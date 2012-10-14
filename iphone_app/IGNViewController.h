//
//  IGNViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 04.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IgnantNoInternetConnectionView.h"

#import "IgnantImporter.h"
#import "IGNAppDelegate.h"

#import "GANTracker.h"

#import <SDWebImage/UIImageView+WebCache.h>

@class IgnantLoadingView, IgnantNoInternetConnectionView, IGNAppDelegate;
@class IgnantImporter;

@interface IGNViewController : UIViewController <IgnantNoInternetConnectionViewDelegate, IgnantImporterDelegate>
{
    @protected
    UIView* _loadingView;
    UIView* _noInternetConnectionView;
}

@property (nonatomic, readonly, unsafe_unretained) IGNAppDelegate *appDelegate;
@property (nonatomic, readwrite, strong) IgnantImporter *importer;

@property(nonatomic, strong, readonly) UIView* firstRunLoadingView;
@property(nonatomic, strong, readonly) UIView* loadingView;
@property(nonatomic, strong, readonly) UILabel* loadingViewLabel;
@property(nonatomic, strong, readonly) UIView* noInternetConnectionView;
@property(nonatomic, strong, readonly) UIView* couldNotLoadDataView;
@property(nonatomic, strong, readonly) UILabel* couldNotLoadDataLabel;

@property(nonatomic, strong, readonly) UIView* specificNavigationBar;
@property(nonatomic, strong, readonly) UIView* specificToolbar;

@property (nonatomic, unsafe_unretained) UIViewController* viewControllerToReturnTo;

-(void)loadLatestContent;

-(void)setUpBackButton;

-(void)setIsLoadingViewHidden:(BOOL)hidden;
-(void)setIsLoadingViewHidden:(BOOL)hidden animated:(BOOL)animated;

-(void)setIsNoConnectionViewHidden:(BOOL)hidden;
-(void)setIsCouldNotLoadDataViewHidden:(BOOL)hidden;

-(void)setIsFirstRunLoadingViewHidden:(BOOL)hidden animated:(BOOL)animated;

-(void)setIsCouldNotLoadDataViewHidden:(BOOL)hidden fullscreen:(BOOL)fullscreen;

-(void)setUpForOfflineUse;
-(void)setUpForOnlineUse;


//specific navigation bar
-(void)toggleShowSpecificNavigationBarAnimated:(BOOL)animated;
-(void)setIsSpecificNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;
-(void)handleTapOnSpecificNavBarBackButton:(id)sender;
-(void)handleTapOnSpecificNavBarHomeButton:(id)sender;

//sepcific toolbar
-(void)toggleShowSpecificToolbar;
-(void)setIsSpecificToolbarHidden:(BOOL)hidden animated:(BOOL)animated;
-(void)handleTapOnSpecificToolbarLeft:(id)sender;
-(void)handleTapOnSpecificToolbarMercedes:(id)sender;
-(void)handleTapOnSpecificToolbarRight:(id)sender;

-(void)triggerLoadLatestDataIfNecessary;


-(NSString*)currentPreferredLanguage;


-(void)triggerLoadingImageAtURL:(NSURL*)url forImageView:(UIImageView*)imageView;

@end
