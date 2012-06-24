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

@class IgnantLoadingView, IgnantNoInternetConnectionView, IGNAppDelegate;
@class IgnantImporter;

@interface IGNViewController : UIViewController <IgnantNoInternetConnectionViewDelegate>
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

@property (nonatomic, unsafe_unretained) UIViewController* viewControllerToReturnTo;

-(void)setUpBackButton;

-(void)setIsLoadingViewHidden:(BOOL)hidden;
-(void)setIsLoadingViewHidden:(BOOL)hidden animated:(BOOL)animated;

-(void)setIsNoConnectionViewHidden:(BOOL)hidden;
-(void)setIsCouldNotLoadDataViewHidden:(BOOL)hidden;

-(void)setIsFirstRunLoadingViewHidden:(BOOL)hidden animated:(BOOL)animated;

-(void)setUpForOfflineUse;
-(void)setUpForOnlineUse;

-(void)createImporter;

@end
