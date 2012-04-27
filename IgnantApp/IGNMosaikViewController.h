//
//  IGNMosaikViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 03.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kImagesKey;

extern NSString * const kImageWidth;
extern NSString * const kImageHeight;
extern NSString * const kImageUrl;
extern NSString * const kImageArticleId;
extern NSString * const kImageFilename;

@interface IGNMosaikViewController : UIViewController

-(IBAction)handleBack:(id)sender;

@property (retain, nonatomic) IBOutlet UIView *bigMosaikView;
@property (retain, nonatomic) IBOutlet UIScrollView *mosaikScrollView;
@property (retain, nonatomic) IBOutlet UIButton *closeMosaikButton;

@end

