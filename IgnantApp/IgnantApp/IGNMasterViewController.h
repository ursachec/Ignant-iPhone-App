//
//  IGNMasterViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IgnantImporterDelegate.h"

#import "IGNViewController.h"

#import "EGORefreshTableHeaderView.h"

@class Category;
@class IGNDetailViewController;

#import <CoreData/CoreData.h>

@interface IGNMasterViewController : IGNViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, IgnantImporterDelegate, EGORefreshTableHeaderDelegate>
@property (retain, nonatomic) IBOutlet UITableView *blogEntriesTableView;

@property (strong, nonatomic) IGNDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (assign, readonly) BOOL isHomeCategory;
@property (retain, nonatomic, readonly) Category* currentCategory;




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil category:(Category*)category;

- (IBAction)showTumblr:(id)sender;

-(void)fetch;

@end
