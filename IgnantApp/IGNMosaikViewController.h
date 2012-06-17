//
//  IGNMosaikViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 03.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IGNViewController.h"

extern NSString * const kImagesKey;

extern NSString * const kImageWidth;
extern NSString * const kImageHeight;
extern NSString * const kImageUrl;
extern NSString * const kImageArticleId;
extern NSString * const kImageFilename;

#import "MosaicView.h"

@interface IGNMosaikViewController : IGNViewController <MosaicViewDelegate>

-(IBAction)handleBack:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *bigMosaikView;
@property (strong, nonatomic) IBOutlet UIScrollView *mosaikScrollView;
@property (strong, nonatomic) IBOutlet UIButton *closeMosaikButton;

@property (nonatomic, unsafe_unretained) UINavigationController* parentNavigationController;

@property(nonatomic, unsafe_unretained) BOOL isMosaicImagesArrayNotEmpty;

@end

