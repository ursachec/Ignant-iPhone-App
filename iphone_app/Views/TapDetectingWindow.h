//
//  TapDetectingWindow.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 29.07.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TapDetectingWindowDelegate
- (void)userDidTapWebView:(id)tapPoint;
@end

@interface TapDetectingWindow : UIWindow

@property (nonatomic, strong) UIView *viewToObserve;
@property (nonatomic, assign) id <TapDetectingWindowDelegate> controllerThatObserves;

@end