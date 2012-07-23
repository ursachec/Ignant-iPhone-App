//
//  IgnantTumblrFeedViewController.h
//  OtherTests
//
//  Created by Claudiu-Vlad Ursache on 4/3/12.
//  Copyright (c) 2012 Cortado AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGNViewController.h"

#import "IgnantImporter.h"

#import "EGORefreshTableHeaderView.h"

@interface IgnantTumblrFeedViewController : IGNViewController <EGORefreshTableHeaderDelegate, IgnantImporterDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tumblrTableView;

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
