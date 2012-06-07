//
//  IgnantNoInternetConnectionView.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 06.06.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IgnantNoInternetConnectionViewDelegate <NSObject>
@optional
-(void)retryToLoadData;
@end

@interface IgnantNoInternetConnectionView : UIView

@property(nonatomic, assign) id<IgnantNoInternetConnectionViewDelegate> delegate;
- (IBAction)retryToLoadData:(id)sender;
@end
