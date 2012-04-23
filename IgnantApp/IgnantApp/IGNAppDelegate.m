//
//  IGNAppDelegate.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import "IGNAppDelegate.h"

#import "IGNMasterViewController.h"

#import "IGNDetailViewController.h"

#import "IgnantImporter.h"

#import "IgnantLoadingView.h"

#import "Constants.h"

//imports for ASIHTTPRequest
#import "ASIHTTPRequest.h"
#import "NSURL+stringforurl.h"



#define kForceReloadCoreData NO


@interface IGNAppDelegate()
{
    Facebook *facebook;
}

@property (readwrite, strong, nonatomic) IGNMasterViewController *masterViewController;
@property (nonatomic, strong) IgnantLoadingView *customLoadingView;

@property (nonatomic, retain) Facebook *facebook;

-(void)startGettingDataForFirstRun;

@end

#pragma mark -

@implementation IGNAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;
@synthesize importer = _importer;

@synthesize masterViewController = _masterViewController;

@synthesize customLoadingView = _customLoadingView;

@synthesize facebook = _facebook;

// String used to identify the update object in the user defaults storage.
static NSString * const kLastStoreUpdateKey = @"LastStoreUpdate";
static NSString * const kSomeTestUpdateKey = @"SomeTestUpdateKey";


- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [_navigationController release];
    [_splitViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    
    //set up loading view
    [self setUpLoadingView];
    
    
    //create cache folders
    NSFileManager *fileManager= [NSFileManager defaultManager]; 
    
    NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *thumbImagesCacheDirectory = [applicationDocumentsDir stringByAppendingFormat:@"thumbs/"];
    BOOL isDir;
    if(![fileManager fileExistsAtPath:thumbImagesCacheDirectory isDirectory:&isDir])
    {
        if(![fileManager createDirectoryAtPath:thumbImagesCacheDirectory withIntermediateDirectories:YES attributes:nil error:NULL])
        {
            NSLog(@"Error: Create folder failed %@", thumbImagesCacheDirectory);
        }
        else
        {
            NSLog(@"created Folder");
        }
    }
    else
    {
        NSLog(@"directory exists");
    }
        
    
    
    
//    //initialize the facebook object
//    _facebook = [[Facebook alloc] initWithAppId:@"270065646390191" andDelegate:self];
//    
//    //check for previously saved facebook information
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if ([defaults objectForKey:@"FBAccessTokenKey"] 
//        && [defaults objectForKey:@"FBExpirationDateKey"]) {
//        _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
//        _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
//    }
//    
//    if (![_facebook isSessionValid]) {
//        [_facebook authorize:nil];
//    }
    
    
    
    

    UINavigationController *nav = [[[NSBundle mainBundle] loadNibNamed:@"IgnantNavigationController" owner:self options:nil] objectAtIndex:0];
    IGNMasterViewController *mVC = [[[IGNMasterViewController alloc] initWithNibName:@"IGNMasterViewController_iPhone" bundle:nil category:nil] autorelease];
    mVC.managedObjectContext = self.managedObjectContext;
    self.masterViewController = mVC;
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:mVC, nil];
    nav.viewControllers = viewControllers;
    self.navigationController = nav;
    self.window.rootViewController = self.navigationController;
    
    
    
    //initialize the importer
    self.importer = [[IgnantImporter alloc] init];
    _importer.persistentStoreCoordinator = self.persistentStoreCoordinator;
    _importer.delegate = self;
    
    //get data from ignant and parse it
    
    //    [_importer startImportingDataFromIgnant];
    
    // check the last update, stored in NSUserDefaults
    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastStoreUpdateKey];
    NSString *lastUpdateString = [[NSUserDefaults standardUserDefaults] objectForKey:kLastStoreUpdateKey];
    
    
    NSString *somekSomeTestUpdateKey = [[NSUserDefaults standardUserDefaults] objectForKey:kSomeTestUpdateKey]; 
    
    NSLog(@"lastUpdate: %@ // lastUpdateString: %@ // somekSomeTestUpdateKey: %@", lastUpdate, lastUpdateString, somekSomeTestUpdateKey);
    
    if (kForceReloadCoreData || lastUpdate == nil) {
        NSLog(@"new store");
        // remove the old store; easier than deleting every object
        // first, test for an existing store
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.persistentStorePath]) {
            NSError *error = nil;
            BOOL oldStoreRemovalSuccess = [[NSFileManager defaultManager] removeItemAtPath:self.persistentStorePath error:&error];
            NSAssert3(oldStoreRemovalSuccess, @"Unhandled error adding persistent store in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
        }
        
        [self startGettingDataForFirstRun];
    }    
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (NSString *)persistentStorePath {
    if (persistentStorePath == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths lastObject];
        persistentStorePath = [[documentsDirectory stringByAppendingPathComponent:@"Ignant.sqlite"] retain];
    }
    return persistentStorePath;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - facebook integration
// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [_facebook handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [_facebook handleOpenURL:url]; 
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[_facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[_facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];    
}


#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"IgnantApp" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"IgnantApp.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - IgnantImporter delegate methods
// This method will be called on a secondary thread. Forward to the main thread for safe handling of UIKit objects.
- (void)importerDidSave:(NSNotification *)saveNotification {
    
    if ([NSThread isMainThread]) {
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];
        [_masterViewController fetch];
    } else {
        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
    }
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - IgnantImporterDelegate

-(void)didStartImportingRSSData
{
    NSLog(@"didStartImportingRSSData");
    
  
}

-(void)didFinishImportingRSSData
{
    NSLog(@"didFinishImportingRSSData");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDate *dateToBeSaved = [NSDate date];
        NSLog(@"appdelegate: didFinishImportingRSSData, dateToBeSaved:%@ kLastStoreUpdateKey: %@",dateToBeSaved, kLastStoreUpdateKey);
        
        [[NSUserDefaults standardUserDefaults] setObject:dateToBeSaved forKey:kLastStoreUpdateKey];        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.importer = nil;
        
        [self.masterViewController fetch];
        
        [self hideLoadingViewAnimated:YES];
        
    });
}

#pragma mark - loading view methods
-(void)setUpLoadingView
{
    //loading the custom loading view from a nib file
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"IgnantLoadingView"
                                                    owner:self 
                                                  options:nil];
    IgnantLoadingView *view;
    for (id object in bundle) {
        if ([object isKindOfClass:[IgnantLoadingView class]])
            view = (IgnantLoadingView *)object;
    }
    self.customLoadingView = view;
}

-(void)showLoadingViewAnimated:(BOOL)animated
{    
        [self.navigationController.view addSubview:_customLoadingView];
        [self.navigationController.view bringSubviewToFront:_customLoadingView];
}

-(void)hideLoadingViewAnimated:(BOOL)animated
{    
    dispatch_async(dispatch_get_main_queue(), ^{
            [_customLoadingView removeFromSuperview];
    });
}


#pragma mark - getting content from the server
-(void)startGettingDataForFirstRun
{
    
    //show the loading view here
    [self showLoadingViewAnimated:YES];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetDataForFirstRun,kParameterAction, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
        
    NSLog(@"encodedString: %@", encodedString);
    
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:encodedString]];
	[request setDelegate:self];
	[request startAsynchronous];
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{    
    [self.importer importJSONString:[request responseString]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end