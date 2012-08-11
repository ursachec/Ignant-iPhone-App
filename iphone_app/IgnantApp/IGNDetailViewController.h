//
//  IGNDetailViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

#import "IGNViewController.h"
#import "IgnantImporter.h"
#import "Facebook.h"

#import "TapDetectingWindow.h"

#import "DTAttributedTextView.h"

@class BlogEntry;

@interface IGNDetailViewController : IGNViewController <IgnantImporterDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, FBDialogDelegate, DTAttributedTextContentViewDelegate>

@property (strong, nonatomic) NSString *currentArticleId;
@property (strong, nonatomic) IBOutlet UILabel *relatedArticlesTitleLabel;
@property (strong, nonatomic) IBOutlet UIView *articleVideoView;
@property (strong, nonatomic) IBOutlet UIWebView *articleVideoWebView;

@property(nonatomic, unsafe_unretained) BOOL didLoadContentForRemoteArticle;
@property(nonatomic, unsafe_unretained) BOOL isShowingArticleFromLocalDatabase; 
@property(nonatomic, unsafe_unretained) BOOL isNavigationBarAndToolbarHidden;

@property(strong, nonatomic) NSArray* fetchedResults;

@property (strong, nonatomic) IBOutlet DTAttributedTextView *dtTextView;

@property (strong, nonatomic) IBOutlet UIImageView *firstRelatedArticleImageView;
@property (strong, nonatomic) IBOutlet UIImageView *secondRelatedArticleImageView;
@property (strong, nonatomic) IBOutlet UIImageView *thirdRelatedArticleImageView;
@property (retain, nonatomic) IBOutlet UILabel *archiveLabel;

@property (strong, nonatomic) IBOutlet UILabel *firstRelatedArticleTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondRelatedArticleTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *thirdRelatedArticleTitleLabel;

@property (strong, nonatomic) IBOutlet UILabel *firstRelatedArticleCategoryLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondRelatedArticleCategoryLabel;
@property (strong, nonatomic) IBOutlet UILabel *thirdRelatedArticleCategoryLabel;

@property (strong, nonatomic) IBOutlet UIButton *firstRelatedArticleShowDetailsButton;
@property (strong, nonatomic) IBOutlet UIButton *secondRelatedArticleShowDetailsButton;
@property (strong, nonatomic) IBOutlet UIButton *thirdRelatedArticleShowDetailsButton;

@property (strong, nonatomic) BlogEntry* blogEntry;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UIScrollView *contentScrollView;

@property (strong, nonatomic) IGNDetailViewController *nextDetailViewController;

//properties related to the navigation
@property(unsafe_unretained) NSInteger currentBlogEntryIndex;
@property(unsafe_unretained) NSInteger nextBlogEntryIndex;
@property(unsafe_unretained) NSInteger previousBlogEntryIndex;

@property (strong, nonatomic) IBOutlet UIView *shareAndMoreToolbar;
@property (retain, nonatomic) IBOutlet UIButton *toggleLikeButton;

@property (nonatomic, assign, readonly) BOOL isShowingImageSlideshow;
@property (nonatomic, assign, readwrite) BOOL isShownFromMosaic;

- (IBAction)handleRightSwipe:(id)sender;

- (IBAction)tapAction:(id)sender;

-(IBAction)showRelatedArticle:(id)sender;
-(IBAction)playVideo:(id)sender;

- (IBAction)handleLeftSwipe:(id)sender;

-(IBAction)toggleLike:(id)sender;

@end
