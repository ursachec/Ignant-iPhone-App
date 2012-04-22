//
//  IGNAppDelegate.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IgnantImporterDelegate.h"

#import "FBConnect.h"

@class IgnantImporter, IGNMasterViewController;

@interface IGNAppDelegate : UIResponder <UIApplicationDelegate, IgnantImporterDelegate, FBSessionDelegate>
{
    NSString *persistentStorePath;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, strong, nonatomic) IGNMasterViewController *masterViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) UISplitViewController *splitViewController;

@property (strong, nonatomic) IgnantImporter *importer;

@property (readonly, strong, nonatomic) NSString *persistentStorePath;

-(void)setUpLoadingView;
-(void)showLoadingViewAnimated:(BOOL)animated;
-(void)hideLoadingViewAnimated:(BOOL)animated;

@end
