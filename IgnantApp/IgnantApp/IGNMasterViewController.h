//
//  IGNMasterViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "IgnantImporterDelegate.h"

#import "IGNViewController.h"

#import "EGORefreshTableHeaderView.h"

@class Category;
@class IGNDetailViewController;

@interface IGNMasterViewController : IGNViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, IgnantImporterDelegate, EGORefreshTableHeaderDelegate>
{
    @protected
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    
    BOOL _showLoadMorePosts;
    BOOL _isLoadingMorePosts;
}
@property (nonatomic, retain, readonly) IgnantImporter *importer;

@property (retain, nonatomic) IBOutlet UITableView *blogEntriesTableView;

@property (retain, nonatomic) IGNDetailViewController *detailViewController;

@property (retain, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (assign, readonly) BOOL isHomeCategory;

@property (retain, nonatomic, readonly) Category* currentCategory;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil category:(Category*)category;



- (IBAction)showTumblr:(id)sender;

-(void)fetch;

-(void)createImporter;

@end
