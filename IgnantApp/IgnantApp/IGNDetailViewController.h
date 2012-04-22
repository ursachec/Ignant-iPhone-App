//
//  IGNDetailViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IGNViewController.h"

#import "IgnantImporterDelegate.h"

@class BlogEntry;

@interface IGNDetailViewController : IGNViewController <UISplitViewControllerDelegate, UIWebViewDelegate,IgnantImporterDelegate, UIActionSheetDelegate>


@property (strong, nonatomic) NSString *currentArticleId;

@property(nonatomic) BOOL didLoadContentForRemoteArticle;
@property(nonatomic) BOOL isShowingArticleFromLocalDatabase; 

@property(retain, nonatomic) NSArray* fetchedResults;

@property (retain, nonatomic) IBOutlet UIImageView *firstRelatedArticleImageView;
@property (retain, nonatomic) IBOutlet UIImageView *secondRelatedArticleImageView;
@property (retain, nonatomic) IBOutlet UIImageView *thirdRelatedArticleImageView;

@property (retain, nonatomic) IBOutlet UILabel *firstRelatedArticleTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *secondRelatedArticleTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *thirdRelatedArticleTitleLabel;


@property (retain, nonatomic) IBOutlet UILabel *thirdRelatedArticleCategoryLabel;

@property (retain, nonatomic) IBOutlet UILabel *firstRelatedArticleCategoryLabel;
@property (retain, nonatomic) IBOutlet UILabel *secondRelatedArticleCategoryLabel;

@property (strong, nonatomic) BlogEntry* blogEntry;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) IBOutlet UIScrollView *contentScrollView;

@property (strong, nonatomic) IGNDetailViewController *nextDetailViewController;

//properties related to the navigation
@property(assign) NSInteger currentBlogEntryIndex;
@property(assign) NSInteger nextBlogEntryIndex;
@property(assign) NSInteger previousBlogEntryIndex;
- (IBAction)tapAction:(id)sender;

@property (retain, nonatomic) IBOutlet UIView *shareAndMoreToolbar;
@property (retain, nonatomic) IBOutlet UIWebView *descriptionWebView;

-(IBAction)showRelatedArticle:(id)sender;
@end
