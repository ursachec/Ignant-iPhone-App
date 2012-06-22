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

@class BlogEntry;

@interface IGNDetailViewController : IGNViewController <UISplitViewControllerDelegate, UIWebViewDelegate,IgnantImporterDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, FBDialogDelegate>

@property (strong, nonatomic) NSString *currentArticleId;

@property(nonatomic, unsafe_unretained) BOOL didLoadContentForRemoteArticle;
@property(nonatomic, unsafe_unretained) BOOL isShowingArticleFromLocalDatabase; 
@property(nonatomic, unsafe_unretained) BOOL isNavigationBarAndToolbarHidden;

@property(strong, nonatomic) NSArray* fetchedResults;

@property (strong, nonatomic) IBOutlet UIImageView *firstRelatedArticleImageView;
@property (strong, nonatomic) IBOutlet UIImageView *secondRelatedArticleImageView;
@property (strong, nonatomic) IBOutlet UIImageView *thirdRelatedArticleImageView;

@property (strong, nonatomic) IBOutlet UILabel *firstRelatedArticleTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondRelatedArticleTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *thirdRelatedArticleTitleLabel;


@property (strong, nonatomic) IBOutlet UILabel *thirdRelatedArticleCategoryLabel;

@property (strong, nonatomic) IBOutlet UILabel *firstRelatedArticleCategoryLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondRelatedArticleCategoryLabel;

@property (strong, nonatomic) IBOutlet UIButton *firstRelatedArticleShowDetailsButton;
@property (strong, nonatomic) IBOutlet UIButton *secondRelatedArticleShowDetailsButton;
@property (strong, nonatomic) IBOutlet UIButton *thirdRelatedArticleShowDetailsButton;
@property (strong, nonatomic) BlogEntry* blogEntry;
- (IBAction)handleRightSwipe:(id)sender;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UIScrollView *contentScrollView;

@property (strong, nonatomic) IGNDetailViewController *nextDetailViewController;


//properties related to the navigation
@property(unsafe_unretained) NSInteger currentBlogEntryIndex;
@property(unsafe_unretained) NSInteger nextBlogEntryIndex;
@property(unsafe_unretained) NSInteger previousBlogEntryIndex;
- (IBAction)tapAction:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *shareAndMoreToolbar;

-(IBAction)showRelatedArticle:(id)sender;
-(IBAction)playVideo:(id)sender;

- (IBAction)handleLeftSwipe:(id)sender;

@end
