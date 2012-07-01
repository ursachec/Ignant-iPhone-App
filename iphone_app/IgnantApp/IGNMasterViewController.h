//
//  IGNMasterViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "IgnantImporter.h"

#import "IGNViewController.h"

#import "EGORefreshTableHeaderView.h"

@class Category;
@class IGNDetailViewController;

@interface IGNMasterViewController : IGNViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, IgnantImporterDelegate, EGORefreshTableHeaderDelegate>
{
    @protected
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    BOOL _reloading;
    BOOL _showLoadMoreContent;
    BOOL _isLoadingMoreContent;
    BOOL _isLoadingLatestContent;
    
    int _numberOfActiveRequests;
    
}

@property (strong, nonatomic) IBOutlet UITableView *blogEntriesTableView;

@property (strong, nonatomic) IGNDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (unsafe_unretained, readonly) BOOL isHomeCategory;
@property (unsafe_unretained, readonly) BOOL fetchingDataForFirstRun;


@property (strong, nonatomic, readonly) Category* currentCategory;

-(void)loadLatestContent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil category:(Category*)category;

-(void)showArticleWithId:(NSString*)articleId;
- (IBAction)showTumblr:(id)sender;

-(void)fetch;

-(void)forceSetCurrentCategory:(Category *)currentCategory;

@end
