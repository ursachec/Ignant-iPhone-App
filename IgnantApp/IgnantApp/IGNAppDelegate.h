//
//  IGNAppDelegate.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IgnantImporter.h"

#import "FBConnect.h"


@class UserDefaultsManager, IgnantImporter, IGNMasterViewController, IGNMoreOptionsViewController, IgnantTumblrFeedViewController, CategoriesViewController, IGNMosaikViewController;

@interface IGNAppDelegate : UIResponder <UIApplicationDelegate, IgnantImporterDelegate, FBSessionDelegate>
{
    NSString *persistentStorePath;
}


@property(nonatomic, readonly, strong) IGNMoreOptionsViewController *moreOptionsViewController;
@property(nonatomic, readonly, strong) IgnantTumblrFeedViewController *tumblrFeedViewController;
@property(nonatomic, readonly, strong) CategoriesViewController *categoriesViewController;
@property(nonatomic, readonly, strong) IGNMosaikViewController *mosaikViewController;


@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, strong, nonatomic) IGNMasterViewController *masterViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property(nonatomic, assign) BOOL isLoadingDataForFirstRun;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) UISplitViewController *splitViewController;

@property (strong, nonatomic) IgnantImporter *importer;
@property (strong, nonatomic) UserDefaultsManager *userDefaultsManager;

@property (readonly, strong, nonatomic) NSString *persistentStorePath;

-(void)setUpLoadingView;
-(void)showLoadingViewAnimated:(BOOL)animated;
-(void)hideLoadingViewAnimated:(BOOL)animated;

@end
