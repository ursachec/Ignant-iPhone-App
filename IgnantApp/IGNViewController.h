//
//  IGNViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 04.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IgnantNoInternetConnectionView.h"

@class IgnantLoadingView, IgnantNoInternetConnectionView;


@interface IGNViewController : UIViewController <IgnantNoInternetConnectionViewDelegate>
{
    @protected
    UIView* _loadingView;
    UIView* _noInternetConnectionView;
}

@property(nonatomic, retain, readonly) UIView* loadingView;
@property(nonatomic, retain, readonly) UILabel* loadingViewLabel;
@property(nonatomic, retain, readonly) UIView* noInternetConnectionView;
@property(nonatomic, retain, readonly) UIView* couldNotLoadDataView;
@property(nonatomic, retain, readonly) UILabel* couldNotLoadDataLabel;

@property (nonatomic, assign) UIViewController* viewControllerToReturnTo;

-(void)setUpBackButton;

-(void)setUpLoadingView;
-(void)setIsLoadingViewHidden:(BOOL)hidden;
-(void)setIsLoadingViewHidden:(BOOL)hidden animated:(BOOL)animated;

-(void)setUpNoConnectionView;
-(void)setIsNoConnectionViewHidden:(BOOL)hidden;

-(void)setUpForOfflineUse;
-(void)setUpForOnlineUse;

-(void)setUpCouldNotLoadDataView;
-(void)setIsCouldNotLoadDataViewHidden:(BOOL)hidden;

@end
