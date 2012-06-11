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

-(void)triggerActionForTapInView:(MosaicView*)view;

@end

@interface MosaicView : UIView

@property(nonatomic, unsafe_unretained) id<MosaicViewDelegate> delegate;
@property(nonatomic, copy) NSString* articleId;
@property(nonatomic, copy) NSString* articleTitle;


@end
