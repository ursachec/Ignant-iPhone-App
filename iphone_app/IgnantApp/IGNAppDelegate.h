//
//  IGNAppDelegate.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IgnantImporter.h"

#import "UserDefaultsManager.h"
#import "FBConnect.h"

#import "TapDetectingWindow.h"


@class Facebook, UserDefaultsManager, IgnantImporter, IGNMasterViewController, IGNMoreOptionsViewController, IgnantTumblrFeedViewController, CategoriesViewController, IGNMosaikViewController, AboutViewController, ContactViewController, FavouritesViewController, ExternalPageViewController;

@interface IGNAppDelegate : UIResponder <UIApplicationDelegate, IgnantImporterDelegate, FBSessionDelegate>
{
    NSString *persistentStorePath;
}

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, readonly, strong) UIView* toolbarGradientView;
@property(nonatomic, readonly, strong) UIView* ignantToolbar;
@property(nonatomic, readonly, strong) UIButton* goHomeButton;

@property(nonatomic, readonly, strong) IGNMasterViewController *categoryViewController;
@property(nonatomic, readonly, strong) IGNMoreOptionsViewController *moreOptionsViewController;
@property(nonatomic, readonly, strong) IgnantTumblrFeedViewController *tumblrFeedViewController;
@property(nonatomic, readonly, strong) CategoriesViewController *categoriesViewController;
@property(nonatomic, readonly, strong) IGNMosaikViewController *mosaikViewController;
@property(nonatomic, readonly, strong) AboutViewController *aboutViewController;
@property(nonatomic, readonly, strong) ContactViewController *contactViewController;
@property(nonatomic, readonly, strong) FavouritesViewController *favouritesViewController;
@property(nonatomic, readonly, strong) ExternalPageViewController *externalPageViewController;

@property (nonatomic, readonly, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly, strong) IGNMasterViewController *masterViewController;

@property (nonatomic, readwrite, strong) Facebook *facebook;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property(nonatomic, unsafe_unretained, readonly) BOOL shouldLoadDataForFirstRun;
@property(nonatomic, unsafe_unretained, readonly) BOOL isLoadingDataForFirstRun;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) IgnantImporter *importer;
@property (strong, nonatomic) UserDefaultsManager *userDefaultsManager;

@property (readonly, strong, nonatomic) NSString *persistentStorePath;

-(void)fetchAndLoadDataForFirstRun;
-(void)initializeFacebook;
-(BOOL)checkIfAppOnline;

-(void)setIsToolbarGradientViewHidden:(BOOL)hidden;
-(void)setIsToolbarHidden:(BOOL)hidden;
-(void)setIsToolbarHidden:(BOOL)hidden animated:(BOOL)animated;

-(void)showHome;
-(void)showMore;

+(BOOL)isIOS5;

@end
