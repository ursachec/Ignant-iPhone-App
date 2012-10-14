//
//  IGNAppDelegate.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import "IGNAppDelegate.h"

#import "Reachability.h"

#import "AFIgnantAPIClient.h"

//import relevant view controller
#import "IgnantNavigationController.h"
#import "IGNMasterViewController.h"
#import "IGNMoreOptionsViewController.h"
#import "IgnantTumblrFeedViewController.h"
#import "CategoriesViewController.h"
#import "IGNMosaikViewController.h"
#import "AboutViewController.h"
#import "ContactViewController.h"
#import "FavouritesViewController.h"

//import other needed classes
#import "IgnantImporter.h"
#import "IgnantLoadingView.h"
#import "IgnantNoInternetConnectionView.h"
#import "UserDefaultsManager.h"

#import "Reachability.h"

//---google analytics
#import "GANTracker.h"

#import "IgnantNavigationBar.h"

#define kForceReloadCoreData NO


@interface IGNAppDelegate()

@property(nonatomic, readwrite, strong) UIView* toolbarGradientView;

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

@end

#pragma mark -

@implementation IGNAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize navigationController = _navigationController;
@synthesize importer = _importer;

@synthesize facebook = _facebook;

@synthesize shouldLoadDataForFirstRun;
@synthesize isLoadingDataForFirstRun;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DBLog(@"didFinishLaunchingWithOptions");
	
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound)];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    [self setupGoogleAnalytics];
    
    
    //initialize utility objects
    _userDefaultsManager = [[UserDefaultsManager alloc] init];
    
    //firstRunData, last update date
    NSDate *lastUpdate = [_userDefaultsManager lastUpdateForFirstRun];
    self.shouldLoadDataForFirstRun = (kForceReloadCoreData || lastUpdate == nil);
        
    DBLog(@"shouldLoadData: %@", self.shouldLoadDataForFirstRun ? @"TRUE" : @"FALSE");
    
    //initialize the importer
    self.importer = [[IgnantImporter alloc] init];
    _importer.persistentStoreCoordinator = self.persistentStoreCoordinator;
    _importer.delegate = self;
    
	
	IgnantNavigationController *nav = [[IgnantNavigationController alloc] initWithNavigationBarClass:[IgnantNavigationBar class] toolbarClass:[UIToolbar class]];
    IGNMasterViewController *mVC = [[IGNMasterViewController alloc] initWithNibName:@"IGNMasterViewController_iPhone" bundle:nil category:nil];
    mVC.managedObjectContext = self.managedObjectContext;
    self.masterViewController = mVC;
	
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:mVC, nil];
    nav.viewControllers = viewControllers;
    self.navigationController = nav;
    
    // check the last update, stored in NSUserDefaults    
    if (self.shouldLoadDataForFirstRun) {
        
        DBLog(@"new store");
        // remove the old store; easier than deleting every object
        // first, test for an existing store
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.persistentStorePath]) {
            NSError *error = nil;
            BOOL oldStoreRemovalSuccess = [[NSFileManager defaultManager] removeItemAtPath:self.persistentStorePath error:&error];
            NSAssert3(oldStoreRemovalSuccess, @"Unhandled error adding persistent store in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
        }
        
        if([self checkIfAppOnline]){
            [self fetchAndLoadDataForFirstRun];
        }
    }
	
	//check with the server if the firstData should be reloaded
	else if([self checkIfAppOnline])
	{
		DEF_BLOCK_SELF
			
		NSDate *lastUpdate = [self.userDefaultsManager lastUpdateForFirstRun];
		NSNumber* lastUpdateTimeStamp = [NSNumber numberWithInteger:[lastUpdate timeIntervalSince1970]];
		
		[[AFIgnantAPIClient sharedClient] getContentWithParameters:@{kParameterAction:kAPICommandShouldReloadDataForTheFirstRun, kTLLastFirstDataFetch:lastUpdateTimeStamp}
												success:^(AFHTTPRequestOperation *operation, id responseJSON) {
												  
												  if ([responseJSON isKindOfClass:[NSDictionary class]]) {
													  BOOL shouldReload = false;
													  id responseValue = [responseJSON objectForKey:kTLShouldFetchFirstData];
													  if ([responseValue isKindOfClass:[NSNumber class]]) {
														  shouldReload = [responseValue boolValue];
													  }
													  if (shouldReload) {
														  [blockSelf fetchAndLoadDataForFirstRun];
													  }													  
												  }
												  
											  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
												  DBLog(@"failure");
											  }];
	}
	
	
    //set up the toolbar
    [self.navigationController.view addSubview:self.ignantToolbar];
    
    //set up gradient view
    [self.navigationController.view addSubview:self.toolbarGradientView];
    
    //set up the go home button
    [self setupGoHomeButton];
    
	self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
	
    
    [self initializeFacebook];
    
    NSDictionary* dict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (dict) {
        NSString* articleID = [dict objectForKey:kFKArticleId];
        [self.masterViewController showArticleWithId:articleID];
    }
    
    return YES;
}


#pragma mark -
-(void)setupGoogleAnalytics
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
        DBLog(@"error in setCustomVariableAtIndex");
    }
    
	NSString* systemVersion = [UIDevice currentDevice].systemVersion;
	NSString* model = [UIDevice currentDevice].model;
	NSString* deviceInfo = [NSString stringWithFormat:@"version:%@|model:%@",systemVersion, model];
	GATrackEvent(&error, @"Application iOS", @"Launch iOS", deviceInfo, 99);
	GATrackPageView(&error, kGAPVAppEntryPoint);
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
    
    [[self facebook] extendAccessTokenIfNeeded];
	[self.masterViewController triggerLoadLatestDataIfNecessary];
	
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
            DBLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
}

// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [_facebook handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
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
        DBLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - IgnantImporter delegate methods
// This method will be called on a secondary thread. Forward to the main thread for safe handling of UIKit objects.
- (void)importerDidSave:(NSNotification *)saveNotification {
    
    DBLog(@"APP delegate importerDidSave");
    
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
    

	
	DEF_BLOCK_SELF
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[[AFIgnantAPIClient sharedClient] getDataForFirstRunWithSuccess:^(AFHTTPRequestOperation *operation, id responseJSON) {
		
		NSString *responseString = [[NSString alloc] initWithData:[operation responseData] encoding:NSUTF8StringEncoding];
		[blockSelf.importer importJSONStringForFirstRun:responseString];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				
		[blockSelf.masterViewController setIsCouldNotLoadDataViewHidden:NO fullscreen:YES];
		blockSelf.isLoadingDataForFirstRun = NO;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
	}];	
}

#pragma mark - push notifications
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    NSString * tokenAsString = [[[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""] copy];
    
	[[AFIgnantAPIClient sharedClient] getRegisterForNotificationsWithDeviceToken:tokenAsString success:^(AFHTTPRequestOperation *operation, id responseJSON) {
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
	}];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    DBLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self.masterViewController loadLatestContent];
}

#pragma mark - ui stuff
-(UIView*)ignantToolbar
{
#define DEBUG_SHOW_DEBUG_COLORS false
    
    if (_ignantToolbar==nil) {
        
        CGSize toolbarSize = CGSizeMake(320.0f, 50.0f);
		
        CGRect toolbarFrame = CGRectMake(0.0f, DeviceHeight-toolbarSize.height, toolbarSize.width, toolbarSize.height);
        UIView* aView = [[UIView alloc] initWithFrame:toolbarFrame];
        aView.backgroundColor = [UIColor clearColor];
        if(DEBUG_SHOW_DEBUG_COLORS)
        aView.backgroundColor = [UIColor redColor];

        //set up the background imageview
        CGSize imageViewSize = toolbarSize;
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, imageViewSize.width, imageViewSize.height)];
        backgroundImageView.image = [UIImage imageNamed:@"mb_footer.png"];
        
        if(DEBUG_SHOW_DEBUG_COLORS)
            backgroundImageView.backgroundColor = [UIColor greenColor];
        
        [aView addSubview:backgroundImageView];
        

        //add buttons        
        CGFloat paddingAmmount = 20.0f;
        CGFloat paddingTop = 9.0f;
        UIFont *buttonFont = [UIFont fontWithName:@"Georgia" size:11.0f]; 
        UIColor*buttonTextColor = [UIColor blackColor];
          
        CGSize buttonSize = CGSizeMake(85.0f, 37.0f);
        CGRect firstButtonFrame = CGRectMake(paddingAmmount, paddingTop, buttonSize.width, buttonSize.height);
        UIButton* firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
        firstButton.titleLabel.font = buttonFont;
        [firstButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
        firstButton.frame = firstButtonFrame;
        
        
        [firstButton setTitle:[NSLocalizedString(@"toolbar_mosaic", @"Title for the mosaic button in the toolbar") uppercaseString] forState:UIControlStateNormal];
        [firstButton addTarget:self action:@selector(showMosaik) forControlEvents:UIControlEventTouchDown];
        [aView addSubview:firstButton];
        
        CGSize buttonSize2 = CGSizeMake(72.0f, 37.0f);
        CGRect secondButtonFrame = CGRectMake(aView.frame.size.width-buttonSize2.width-paddingAmmount, paddingTop, buttonSize2.width, buttonSize2.height);
        UIButton* secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
        secondButton.titleLabel.font = buttonFont;
        [secondButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
        secondButton.frame = secondButtonFrame;
        [secondButton setTitle:[NSLocalizedString(@"toolbar_more", @"Title for the more button in the toolbar") uppercaseString] forState:UIControlStateNormal];
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
    NSError* error = nil;
	GATrackEvent(&error, @"IGNAppDelegate", @"showHome", @"", -1);
    
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

#pragma mark - toolbar methods


-(void)setIsToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
#define ANIMATION_DURATION .5f
    
    DEF_BLOCK_SELF
    __block BOOL bHidden = hidden;
    void (^toolbarblock)(void);
    toolbarblock = ^{
        blockSelf.ignantToolbar.alpha = bHidden ? 0.0f : 1.0f;
        [blockSelf.ignantToolbar setUserInteractionEnabled:!bHidden];
    };
    
    //execute show/hide
    if (!animated) 
    {
        toolbarblock();
    }
    else 
    {
        [UIView animateWithDuration:ANIMATION_DURATION 
                         animations:toolbarblock
                         completion:^(BOOL finished){
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

#pragma mark - FBSessionDelegate methods


/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    DBLog(@"token extended");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
}

@end
