//
//  MosaicView.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 24.04.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MosaicView;

@protocol MosaicViewDelegate <NSObject>
@optional
-(void)triggerActionForTapInView:(MosaicView*)view;
-(void)triggerActionForDoubleTapInView:(MosaicView*)view;
@end

@interface MosaicView : UIView

@property(nonatomic, unsafe_unretained) id<MosaicViewDelegate> delegate;
@property(nonatomic, copy) NSString* articleId;

@end
