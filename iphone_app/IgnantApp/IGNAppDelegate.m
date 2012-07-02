//
//  IGNAppDelegate.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import "IGNAppDelegate.h"

#import "Reachability.h"

//import relevant view controller
#import "IGNMasterViewController.h"
#import "IGNDetailViewController.h"
#import "IGNMoreOptionsViewController.h"
#import "IgnantTumblrFeedViewController.h"
#import "CategoriesViewController.h"
#import "IGNMosaikViewController.h"
#import "AboutViewController.h"
#import "ContactViewController.h"
#import "FavouritesViewController.h"
#import "ExternalPageViewController.h"

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

//---google analytics
#import "GANTracker.h"

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;
static NSString* const kAnalyticsAccountId = @"UA-33084223-1";


#define kForceReloadCoreData NO

#warning TODO: app description, small artwork with special chars ●●●●●●●●●∙∙∙∙∙∙●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●

@interface IGNAppDelegate()

@property(nonatomic, readwrite, strong) UIView* toolbarGradientView;

@property(nonatomic, readwrite, strong) NSString* deviceToken;

@property(nonatomic, readwrite, strong) IGNMasterViewController *masterViewController;
@property(nonatomic, readwrite, strong) IGNMasterViewController *categoryViewController;
@property(nonatomic, readwrite, strong) IGNMoreOptionsViewController *moreOptionsViewController;
@property(nonatomic, readwrite, strong) IgnantTumblrFeedViewController *tumblrFeedViewController;
@property(nonatomic, readwrite, strong) CategoriesViewController *categoriesViewController;
@property(nonatomic, readwrite, strong) IGNMosaikViewController *mosaikViewController;
@property(nonatomic, readwrite, strong) AboutViewController *aboutViewController;
@property(nonatomic, readwrite, strong) ContactViewController *contactViewController;
@property(nonatomic, readwrite, strong) FavouritesViewController* favouritesViewController;
@property(nonatomic, readwrite, strong) ExternalPageViewController* externalPageViewController;

@property (nonatomic, strong) IgnantLoadingView *customLoadingView;
@property (nonatomic, strong) IgnantNoInternetConnectionView *noInternetConnectionView;

@property(nonatomic, unsafe_unretained, readwrite) BOOL shouldLoadDataForFirstRun;
@property(nonatomic, unsafe_unretained, readwrite) BOOL isLoadingDataForFirstRun;

@property(nonatomic, readwrite, strong) UIView* ignantToolbar;
@property(nonatomic, readwrite, strong) UIButton* goHomeButton;

-(void)createCacheFolders;

@end

#pragma mark -

@implementation IGNAppDelegate
@synthesize deviceToken = _deviceToken;

@synthesize goHomeButton = _goHomeButton;
@synthesize toolbarGradientView = _toolbarGradientView;

@synthesize userDefaultsManager = _userDefaultsManager;

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize navigationController = _navigationController;
@synthesize importer = _importer;

@synthesize masterViewController = _masterViewController;
@synthesize categoryViewController = _categoryViewController;
@synthesize moreOptionsViewController = _moreOptionsViewController;
@synthesize tumblrFeedViewController = _tumblrFeedViewController;
@synthesize categoriesViewController = _categoriesViewController;
@synthesize mosaikViewController = _mosaikViewController;
@synthesize aboutViewController = _aboutViewController;
@synthesize contactViewController = _contactViewController;
@synthesize favouritesViewController = _favouritesViewController;
@synthesize externalPageViewController = _externalPageViewController;

@synthesize customLoadingView = _customLoadingView;
@synthesize noInternetConnectionView = _noInternetConnectionView;

@synthesize facebook = _facebook;

@synthesize shouldLoadDataForFirstRun;
@synthesize isLoadingDataForFirstRun;

@synthesize ignantToolbar = _ignantToolbar;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound)];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    
    BOOL googleAnalyticsWasSetUp = [self setupGoogleAnalytics];
    
    
    //initialize utility objects
    _userDefaultsManager = [[UserDefaultsManager alloc] init];
    
    //firstRunData, last update date
    NSDate *lastUpdate = [_userDefaultsManager lastUpdateForFirstRun];
    self.shouldLoadDataForFirstRun = (kForceReloadCoreData || lastUpdate == nil);
        
    NSLog(@"shouldLoadData: %@", self.shouldLoadDataForFirstRun ? @"TRUE" : @"FALSE");
    
    //create cache folders for the thumbs
//    [self createCacheFolders];
    
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
        if([self checkIfAppOnline]){
            [self fetchAndLoadDataForFirstRun];
        }
        else {
            //show relvant window
            
            
        }
    }
    
    //set up the toolbar
    [self.navigationController.view addSubview:self.ignantToolbar];
    
    //set up gradient view
    [self.navigationController.view addSubview:self.toolbarGradientView];
    
    //set up the go home button
    [self setupGoHomeButton];
    
    [self.window makeKeyAndVisible];
    
    
    NSDictionary* dict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (dict) {
        NSString* articleID = [dict objectForKey:kFKArticleId];
        [self.masterViewController showArticleWithId:articleID];
    }
    
    return YES;
}


#pragma mark - 
-(BOOL)setupGoogleAnalytics
{
    LOG_CURRENT_FUNCTION()
    
    //init google analytics
    [[GANTracker sharedTracker] startTrackerWithAccountID:kAnalyticsAccountId
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    NSError *error;
    
    if (![[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                         name:@"iOS1"
                                                        value:@"iv1"
                                                    withError:&error]) {
        NSLog(@"error in setCustomVariableAtIndex");
    }
    
    if (![[GANTracker sharedTracker] trackEvent:@"Application iOS"
                                         action:@"Launch iOS"
                                          label:@"Example iOS"
                                          value:99
                                      withError:&error]) {
        NSLog(@"error in trackEvent");
    }
    
    if (![[GANTracker sharedTracker] trackPageview:@"/app_entry_point"
                                         withError:&error]) {
        NSLog(@"error in trackPageview");
    }
    
#warning TODO: add actual return value, do something if it didn't work, like send data to the server
    return true;
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
    [[GANTracker sharedTracker] stopTracker];
    
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
-(BOOL)checkIfAppOnline
{    
    Reachability* r = [Reachability reachabilityWithHostname:kReachabilityHostnameToCheck]; 
    BOOL returnBool = [r isReachable];
    return returnBool;
}

#pragma mark - reusable view controllers

-(IGNMasterViewController*)categoryViewController
{
if (_categoryViewController==nil) {
    _categoryViewController = [[IGNMasterViewController alloc] initWithNibName:@"IGNMasterViewController_iPhone" bundle:nil ];
}

return _categoryViewController;
}

-(ExternalPageViewController*)externalPageViewController
{
if (_externalPageViewController==nil) {
    _externalPageViewController = [[ExternalPageViewController alloc] initWithNibName:@"ExternalPageViewController" bundle:nil ];
}

return _externalPageViewController;
}


-(FavouritesViewController*)favouritesViewController
{
    if (_favouritesViewController==nil) {
        _favouritesViewController = [[FavouritesViewController alloc] initWithNibName:@"IGNMasterViewController_iPhone" bundle:nil ];
    }
    
    return _favouritesViewController;
}

-(ContactViewController*)contactViewController
{
    if (_contactViewController==nil) {
        _contactViewController = [[ContactViewController alloc] initWithNibName:@"ContactViewController" bundle:nil ];
    }
    
    return _contactViewController;
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
    
    NSLog(@"APP delegate importerDidSave");
    
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
        [self.masterViewController setIsFirstRunLoadingViewHidden:NO animated:NO];
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
        [self.masterViewController setIsFirstRunLoadingViewHidden:YES animated:NO];
    });
}

#pragma mark - getting content from the server
-(void)fetchAndLoadDataForFirstRun
{
    self.isLoadingDataForFirstRun = YES;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetDataForFirstRun,kParameterAction, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
        
    NSLog(@"APPDELEGATE FETCH LOAD DATA FIRST RUN encodedString: %@ /// deviceToken: %@", encodedString, self.deviceToken);
    
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:encodedString]];
    [request setTimeOutSeconds:6.0f];
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
    
    [self.masterViewController setIsCouldNotLoadDataViewHidden:NO fullscreen:YES];
    
    self.isLoadingDataForFirstRun = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - push notifications
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"devToken=%@",deviceToken);
    self.deviceToken = [[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)userInfo
{   
#warning TODO: is this OK?
    [self.masterViewController loadLatestContent];
    
}

#pragma mark - ui stuff
-(UIView*)ignantToolbar
{
#define DEBUG_SHOW_DEBUG_COLORS false
    
    if (_ignantToolbar==nil) {
        
        CGRect navControllerFrame = self.navigationController.view.frame;
        NSLog(@"navControllerFrame: %@", NSStringFromCGRect(navControllerFrame));        
        
        CGSize toolbarSize = CGSizeMake(320.0f, 50.0f);
        CGRect toolbarFrame = CGRectMake(0.0f, 480.0f-toolbarSize.height, toolbarSize.width, toolbarSize.height);
        UIView* aView = [[UIView alloc] initWithFrame:toolbarFrame];
        aView.backgroundColor = [UIColor clearColor];
        if(DEBUG_SHOW_DEBUG_COLORS)
        aView.backgroundColor = [UIColor redColor];

        //set up the background imageview
        CGSize imageViewSize = toolbarSize;
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, imageViewSize.width, imageViewSize.height)];
        backgroundImageView.image = [UIImage imageNamed:@"ign_footer.jpg"];
        
        if(DEBUG_SHOW_DEBUG_COLORS)
            backgroundImageView.backgroundColor = [UIColor greenColor];
        
        [aView addSubview:backgroundImageView];
        
        
        //add buttons
        
        CGFloat paddingAmmount = 20.0f;
        CGFloat paddingTop = 9.0f;
        UIFont *buttonFont = [UIFont fontWithName:@"Georgia" size:11.0f]; 
        UIColor*buttonTextColor = [UIColor blackColor];
        
#warning TODO: localize text - mosaik     
        CGSize buttonSize = CGSizeMake(85.0f, 37.0f);
        CGRect firstButtonFrame = CGRectMake(paddingAmmount, paddingTop, buttonSize.width, buttonSize.height);
        UIButton* firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
        firstButton.titleLabel.font = buttonFont;
        [firstButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
        firstButton.frame = firstButtonFrame;
        [firstButton setTitle:[@"Mosaik" uppercaseString] forState:UIControlStateNormal];
        [firstButton addTarget:self action:@selector(showMosaik) forControlEvents:UIControlEventTouchDown];
        [aView addSubview:firstButton];
        
#warning TODO: localize text - mosaik
        CGSize buttonSize2 = CGSizeMake(72.0f, 37.0f);
        CGRect secondButtonFrame = CGRectMake(aView.frame.size.width-buttonSize2.width-paddingAmmount, paddingTop, buttonSize2.width, buttonSize2.height);
        UIButton* secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
        secondButton.titleLabel.font = buttonFont;
        [secondButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
        secondButton.frame = secondButtonFrame;
        [secondButton setTitle:[@"More" uppercaseString] forState:UIControlStateNormal];
        [secondButton addTarget:self action:@selector(showMore) forControlEvents:UIControlEventTouchDown];
        [aView addSubview:secondButton];
        
        
        CGSize mercedesButtonSize = CGSizeMake(40.0f, 40.0f);
        CGRect mercedesButtonFrame = CGRectMake((aView.frame.size.width-mercedesButtonSize.width)/2, (aView.frame.size.height-mercedesButtonSize.height)/2, mercedesButtonSize.width, mercedesButtonSize.height);
        UIButton* mercedesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        mercedesButton.frame = mercedesButtonFrame;
        mercedesButton.backgroundColor = [UIColor clearColor];
        [mercedesButton setTitle:@"" forState:UIControlStateNormal];
        [mercedesButton addTarget:self action:@selector(showMercedes) forControlEvents:UIControlEventTouchDown];
        [aView addSubview:mercedesButton];
        
        
        _ignantToolbar = aView;
    }

    return _ignantToolbar;
}
-(void)showMercedes
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAdressForMercedesPage]];
}

-(void)showHome
{
    NSLog(@"showHome");
    [self.navigationController popToViewController:self.masterViewController animated:YES];
}


-(void)showMosaik
{    
    IGNMosaikViewController *mosaikVC = self.mosaikViewController;
    mosaikVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    mosaikVC.parentNavigationController = self.navigationController;
    
    if (!mosaikVC.isMosaicImagesArrayNotEmpty && ![self checkIfAppOnline]) 
    {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"" 
                                                     message:NSLocalizedString(@"ui_alert_message_you_need_an_internet_connection",nil)  
                                                    delegate:self 
                                           cancelButtonTitle:NSLocalizedString(@"ui_alert_dismiss",nil)
                                           otherButtonTitles:nil];
        [av show];
        
        return;
    }
    else 
    {
        [self.navigationController presentModalViewController:mosaikVC animated:YES];
    }
}

-(void)showMore
{
    IGNMoreOptionsViewController *moreOptionsVC = self.moreOptionsViewController;
    [self showViewController:moreOptionsVC];
}

-(void)showViewController:(UIViewController*)viewController
{
    
    NSArray* vcs = self.navigationController.viewControllers;
    BOOL isCategoriesVCOnStack = NO;
    for (id object in vcs) {
        if ([object isKindOfClass:[viewController class]]) {
            isCategoriesVCOnStack = YES;
            break;
        }
    }
    
    if (isCategoriesVCOnStack) {
        [self.navigationController popToViewController:viewController animated:YES];
    }
    else {
        [self.navigationController pushViewController:viewController animated:YES];                
    }    
}


-(UIView*)toolbarGradientView
{
    if (_toolbarGradientView==nil) {
        
        CGRect navBarFrame = self.navigationController.navigationBar.frame;
        NSLog(@"navBarFrame: %@", NSStringFromCGRect(navBarFrame));
        
        //set up the gradient view
        CGSize gradientViewSize = CGSizeMake(320.0f, 3.0f);
        CGRect gradientViewFrame = CGRectMake(navBarFrame.origin.x, navBarFrame.origin.y+navBarFrame.size.height, gradientViewSize.width, gradientViewSize.height);
        UIView* aView = [[UIView alloc] initWithFrame:gradientViewFrame];
        aView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        aView.backgroundColor = [UIColor clearColor];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = aView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:223.0f/255.0f green:223.0f/255.0f blue:223.0f/255.0f alpha:.5f] CGColor], (id)[[UIColor colorWithRed:223.0f/255.0f green:223.0f/255.0f blue:223.0f/255.0f alpha:0.f] CGColor], nil];
        [aView.layer insertSublayer:gradient atIndex:0];
        
        _toolbarGradientView = aView;  
    }
    
    return _toolbarGradientView;
}

-(void)setIsToolbarGradientViewHidden:(BOOL)hidden
{
    
    if (hidden) {
        [self.toolbarGradientView removeFromSuperview];
    } 
    else {
        
        [self.navigationController.view addSubview:self.toolbarGradientView];
    }
}

-(void)setIsToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
#define ANIMATION_DURATION .5f    
    
    //execute show/hide
    if (!animated) 
    {
        if (hidden) {
            [self.ignantToolbar removeFromSuperview];
        } 
        else {
            self.ignantToolbar.alpha = 1.0f;
            [self.navigationController.view addSubview:self.ignantToolbar];
        }
        
    }
    else 
    {
        if (!hidden) {
            self.ignantToolbar.alpha = 1.0f;
            [self.navigationController.view addSubview:self.ignantToolbar];
        }
        
        __block __typeof__(self) blockSelf = self;
        __block BOOL bHidden = hidden;
        
        void (^toolbarblock)(void);
        toolbarblock = ^{
            blockSelf.ignantToolbar.alpha = bHidden ? 0.0f : 1.0f;
        };
        
        [UIView animateWithDuration:ANIMATION_DURATION 
                         animations:toolbarblock
                         completion:^(BOOL finished){
                             
                             if (bHidden) {
                                 [blockSelf.ignantToolbar removeFromSuperview];
                             }
                         }];
    }
}

-(void)setIsToolbarHidden:(BOOL)hidden
{   
   [self setIsToolbarHidden:hidden animated:NO];
}

-(void)setupGoHomeButton
{
    CGRect navBarFrame = self.navigationController.navigationBar.frame;
    
    CGSize buttonSize = CGSizeMake(40.0f, 40.0f);
    UIButton* aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    aButton.backgroundColor = [UIColor clearColor];
    [aButton setTitle:@"" forState:UIControlStateNormal];
    aButton.frame = CGRectMake((navBarFrame.size.width-buttonSize.width)/2, (navBarFrame.size.height-buttonSize.height)/2, buttonSize.width, buttonSize.height);
    [aButton addTarget:self action:@selector(showHome) forControlEvents:UIControlEventTouchDown];
    
    [self.navigationController.navigationBar addSubview:aButton];
}

#pragma mark - useful methods
+(BOOL)isIOS5{
    NSString* osVersion = @"5.0";
    NSString* currentOsVersion = [[UIDevice currentDevice] systemVersion];
    return [currentOsVersion compare:osVersion options:NSNumericSearch] == NSOrderedDescending;
}


@end
