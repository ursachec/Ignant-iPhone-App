//
//  CategoriesViewController.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 04.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGNViewController.h"

@interface CategoriesViewController : IGNViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *categoriesTableView;

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
