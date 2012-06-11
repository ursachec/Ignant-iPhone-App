//
//  IGNAppDelegate.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import "IGNAppDelegate.h"


//import relevant view controller
#import "IGNMasterViewController.h"
#import "IGNDetailViewController.h"
#import "IGNMoreOptionsViewController.h"
#import "IgnantTumblrFeedViewController.h"
#import "CategoriesViewController.h"
#import "IGNMosaikViewController.h"
#import "AboutViewController.h"
#import "MostViewedViewController.h"
#import "ContactViewController.h"

//import other needed classes
#import "IgnantImporter.h"
#import "IgnantLoadingView.h"
#import "IgnantNoInternetConnectionView.h"
#import "UserDefaultsManager.h"
#import "Constants.h"

//imports for ASIHTTPRequest
#import "ASIHTTPRequest.h"
#import "NSURL+stringforurl.h"

#import "Reachability.h"

#define kForceReloadCoreData NO


@interface IGNAppDelegate()

@property(nonatomic, readwrite, strong) IGNMasterViewController *masterViewController;
@property(nonatomic, readwrite, strong) IGNMoreOptionsViewController *moreOptionsViewController;
@property(nonatomic, readwrite, strong) IgnantTumblrFeedViewController *tumblrFeedViewController;
@property(nonatomic, readwrite, strong) CategoriesViewController *categoriesViewController;
@property(nonatomic, readwrite, strong) IGNMosaikViewController *mosaikViewController;
@property(nonatomic, readwrite, strong) AboutViewController *aboutViewController;
@property(nonatomic, readwrite, strong) MostViewedViewController *mostViewedViewController;
@property(nonatomic, readwrite, strong) ContactViewController *contactViewController;


@property (nonatomic, strong) IgnantLoadingView *customLoadingView;
@property (nonatomic, strong) IgnantNoInternetConnectionView *noInternetConnectionView;

@property(nonatomic, assign, readwrite) BOOL shouldLoadDataForFirstRun;
@property(nonatomic, assign, readwrite) BOOL isLoadingDataForFirstRun;

-(void)createCacheFolders;

@end

#pragma mark -

@implementation IGNAppDelegate
@synthesize userDefaultsManager = _userDefaultsManager;

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;
@synthesize importer = _importer;

@synthesize masterViewController = _masterViewController;
@synthesize moreOptionsViewController = _moreOptionsViewController;
@synthesize tumblrFeedViewController = _tumblrFeedViewController;
@synthesize categoriesViewController = _categoriesViewController;
@synthesize mosaikViewController = _mosaikViewController;
@synthesize aboutViewController = _aboutViewController;
@synthesize mostViewedViewController = _mostViewedViewController;
@synthesize contactViewController = _contactViewController;


@synthesize customLoadingView = _customLoadingView;
@synthesize noInternetConnectionView = _noInternetConnectionView;

@synthesize facebook = _facebook;

@synthesize shouldLoadDataForFirstRun;
@synthesize isLoadingDataForFirstRun;


#pragma mark - 




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    //initialize utility objects
    _userDefaultsManager = [[UserDefaultsManager alloc] init];
    
    //firstRunData, last update date
    NSDate *lastUpdate = [_userDefaultsManager lastUpdateForFirstRun];
    self.shouldLoadDataForFirstRun = (kForceReloadCoreData || lastUpdate == nil);
        
    NSLog(@"shouldLoadData: %@", self.shouldLoadDataForFirstRun ? @"TRUE" : @"FALSE");
    
    //create cache folders for the thumbs
    [self createCacheFolders];
    
    //initialize the importer
    self.importer = [[IgnantImporter alloc] init];
    _importer.persistentStoreCoordinator = self.persistentStoreCoordinator;
    _importer.delegate = self;
    
    UINavigationController *nav = [[[NSBundle mainBundle] loadNibNamed:@"IgnantNavigationController" owner:self options:nil] objectAtIndex:0];
    IGNMasterViewController *mVC = [[IGNMasterViewController alloc] initWithNibName:@"IGNMasterViewController_iPhone" bundle:nil category:nil];
    mVC.managedObjectContext = self.managedObjectContext;
    self.masterViewController = mVC;
        
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:mVC, nil];
    nav.viewControllers = viewControllers;
    self.navigationController = nav;
    self.window.rootViewController = self.navigationController;
    
    
    // check the last update, stored in NSUserDefaults    
    if (self.shouldLoadDataForFirstRun) {
        
        NSLog(@"new store");
        // remove the old store; easier than deleting every object
        // first, test for an existing store
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.persistentStorePath]) {
            NSError *error = nil;
            BOOL oldStoreRemovalSuccess = [[NSFileManager defaultManager] removeItemAtPath:self.persistentStorePath error:&error];
            NSAssert3(oldStoreRemovalSuccess, @"Unhandled error adding persistent store in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
        }
        
#warning CHECK IF internet connection exists and show screen if not ("Ignant needs an internet connection for this", <load again button>)
        if([self isAppOnline]){
            [self fetchAndLoadDataForFirstRun];
        }
        else {
            //show relvant window
            
            
        }
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)createCacheFolders
{
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
}

- (NSString *)persistentStorePath {
    if (persistentStorePath == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths lastObject];
        persistentStorePath = [documentsDirectory stringByAppendingPathComponent:@"Ignant.sqlite"];
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

#pragma mark - internet connectivity
-(BOOL)isAppOnline
{
#warning USE IP ADRESS OF THE CONTENT SERVER, NOT OF IGNANT
    Reachability* r = [Reachability reachabilityWithHostName:kReachabilityHostnameToCheck];
    BOOL reachable = [r isReachable];    
    return reachable;
}


#pragma mark - reusable view controllers

-(ContactViewController*)contactViewController
{
    if (_contactViewController==nil) {
        _contactViewController = [[ContactViewController alloc] initWithNibName:@"ContactViewController" bundle:nil ];
    }
    
    return _contactViewController;
}

-(MostViewedViewController*)mostViewedViewController
{
    if (_mostViewedViewController==nil) {
        _mostViewedViewController = [[MostViewedViewController alloc] initWithNibName:@"IGNMasterViewController_iPhone" bundle:nil ];
    }
    
    return _mostViewedViewController;
}

-(AboutViewController*)aboutViewController
{
    if (_aboutViewController==nil) {
        _aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil ];
    }
    
    return _aboutViewController;
}

-(IGNMoreOptionsViewController*)moreOptionsViewController
{
    if (_moreOptionsViewController==nil) {
        _moreOptionsViewController = [[IGNMoreOptionsViewController alloc] initWithNibName:@"IGNMoreOptionsViewController" bundle:nil ];
    }
    
    return _moreOptionsViewController;
}

-(IgnantTumblrFeedViewController*)tumblrFeedViewController
{
    if (_tumblrFeedViewController==nil) {
        _tumblrFeedViewController = [[IgnantTumblrFeedViewController alloc] initWithNibName:@"IgnantTumblrFeedViewController" bundle:nil];
    }
    return _tumblrFeedViewController;
}

-(CategoriesViewController*)categoriesViewController
{
    if (_categoriesViewController==nil) {
        _categoriesViewController = [[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController" bundle:nil];
    }
    return _categoriesViewController;
}

-(IGNMosaikViewController*)mosaikViewController
{
    if (_mosaikViewController==nil) {
        _mosaikViewController = [[IGNMosaikViewController alloc] initWithNibName:@"IGNMosaikViewController" bundle:nil];
    }
    return _mosaikViewController;
}

#pragma mark - facebook integration

-(void)initializeFacebook
{
    //initialize the facebook object
    if (self.facebook==nil)
    _facebook = [[Facebook alloc] initWithAppId:kFacebookAppId andDelegate:self];
    
    //check for previously saved facebook information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![_facebook isSessionValid]) {
        
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_likes", 
                                @"read_stream",
                                nil];
        [_facebook authorize:permissions];
    }
}

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

-(void)didStartImportingData
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
  
}

-(void)didFailImportingData
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.masterViewController setIsLoadingViewHidden:YES];
    });
}

-(void)didFinishImportingData
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    self.isLoadingDataForFirstRun = NO;
    self.shouldLoadDataForFirstRun = NO;
    
    NSDate *dateToBeSaved = [NSDate date];
    [self.userDefaultsManager setLastUpdateDateForFirstRun:dateToBeSaved];
    [self.userDefaultsManager setLastUpdateDate:dateToBeSaved forCategoryId:[NSString stringWithFormat:@"%d",kCategoryIndexForHome]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.masterViewController fetch];
        self.navigationController.navigationBarHidden = NO;
        [self.masterViewController setIsLoadingViewHidden:YES];
    });
}

#pragma mark - getting content from the server
-(void)fetchAndLoadDataForFirstRun
{
    self.isLoadingDataForFirstRun = YES;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetDataForFirstRun,kParameterAction, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
        
    NSLog(@"APPDELEGATE FETCH LOAD DATA FIRST RUN encodedString: %@", encodedString);
    
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:encodedString]];
    [request setTimeOutSeconds:10.0f];
	[request setDelegate:self];
	[request startAsynchronous];
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{    
    [self.importer importJSONStringForFirstRun:[request responseString]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    
    NSLog(@"shouldLoadData: %@", self.shouldLoadDataForFirstRun ? @"TRUE" : @"FALSE");
    
    NSLog(@"requestFailed");
    [self.masterViewController setIsCouldNotLoadDataViewHidden:NO];
    
    self.isLoadingDataForFirstRun = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
