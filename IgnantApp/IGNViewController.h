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

@property(nonatomic, strong, readonly) UIView* loadingView;
@property(nonatomic, strong, readonly) UILabel* loadingViewLabel;
@property(nonatomic, strong, readonly) UIView* noInternetConnectionView;
@property(nonatomic, strong, readonly) UIView* couldNotLoadDataView;
@property(nonatomic, strong, readonly) UILabel* couldNotLoadDataLabel;

@property (nonatomic, unsafe_unretained) UIViewController* viewControllerToReturnTo;

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
