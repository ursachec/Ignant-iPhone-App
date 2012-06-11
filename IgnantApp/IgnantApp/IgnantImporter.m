//
//  IgnantImporter.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 30.12.11.
//  Copyright (c) 2011 c.v.ursache. All rights reserved.
//

#import "IgnantImporter.h"
#import "NSString+HTML.h"
#import "NSData+Base64.h"

#import "SBJSON.h"

#import "Category.h"

#import "Constants.h"

#import "IGNAppDelegate.h"

#define TEST_JSON_DUMP [[NSBundle mainBundle] pathForResource:@"dump_images_big_jpg" ofType:@"txt"]


// String used to identify the update object in the user defaults storage.
NSString* const kLastImportedBlogEntryDateKey = @"LastImportedBlogEntryDate";

NSString *const kUserDefaultsLastImportDateForMainPageArticle = @"last_import_date_for_main_article";


NSString *const feedAdress = @"http://feeds2.feedburner.com/ignant";
//NSString *const feedAdress = @"feed://www.google.com/reader/atom/feed/feed://feeds.feedburner.com/ignant?n=4&r=o&et=1325451846";


#import "Image.h"
#import "BlogEntry.h"
#import "TumblrEntry.h"

#warning DO APPROPRIATE memory management before releasing app
#warning DELETE RSS Parser entries before releasing app

@interface IgnantImporter() 
{
    IGNAppDelegate* appDelegate;
    
	NSDateFormatter *formatter;
    
    NSManagedObjectContext *insertionContext;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    
}

-(void)updateLastDateForImportedArticleForMainPage;

-(void)importOneArticleFromDictionary:(NSDictionary*)oneArticleDictionary;

@property (nonatomic, strong) NSDate* lastImportDateForMainPageArticle;

@property (nonatomic, strong) Image* currentImage;
@property (nonatomic, strong) BlogEntry* currentBlogEntry;
@property (nonatomic, strong) Category* currentCategory;
@property (nonatomic, strong) TumblrEntry* currentTumblrEntry;

@property (nonatomic, strong, readonly) NSEntityDescription *currentImageDescription;
@property (nonatomic, strong, readonly) NSEntityDescription *currentBlogEntryDescription;
@property (nonatomic, strong, readonly) NSEntityDescription *currentTumblrEntryDescription;
@property (nonatomic, strong, readonly) NSEntityDescription *currentCategoryDescription;

@property NSUInteger countForNumberOfBlogEntriesToBeSaved;
@property NSUInteger countForNumberOfImagesToBeSaved;
@property NSUInteger countForNumberOfCommentsToBeSaved;

@property (nonatomic, strong) NSDate *currentDateForLeastRecentArticle;

@property (nonatomic, strong) NSFetchRequest *checkingFetchRequestForBlogEntries;
@property (nonatomic, strong) NSFetchRequest *checkingFetchRequestForTumblrEntries;
@property (nonatomic, strong) NSFetchRequest *checkingFetchRequestForCategories;

@end

#pragma mark -

@implementation IgnantImporter
@synthesize delegate;
@synthesize insertionContext = _insertionContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize currentImage, currentBlogEntry, currentTumblrEntry, currentImageDescription, currentBlogEntryDescription, currentTumblrEntryDescription, currentCategory, currentCategoryDescription;

@synthesize countForNumberOfBlogEntriesToBeSaved, countForNumberOfImagesToBeSaved, countForNumberOfCommentsToBeSaved;

@synthesize currentDateForLeastRecentArticle = _currentDateForLeastRecentArticle;

@synthesize lastImportDateForMainPageArticle = _lastImportDateForMainPageArticle;

//fetch request for checking existence
@synthesize checkingFetchRequestForBlogEntries = _checkingFetchRequestForBlogEntries;
@synthesize checkingFetchRequestForTumblrEntries = _checkingFetchRequestForTumblrEntries;
@synthesize checkingFetchRequestForCategories = _checkingFetchRequestForCategories;

-(id)init
{
    self = [super init];

    if (self) {
        
        appDelegate = (IGNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
    }
    
    return self;
}


#pragma mark - parsing support methods

static const NSUInteger kImportBatchSize = 5;

-(void)finishProcessingCurrentBlogEntry
{
    countForNumberOfBlogEntriesToBeSaved++;
    
    if (countForNumberOfBlogEntriesToBeSaved == kImportBatchSize) {
        
        NSError *saveError = nil;
        NSAssert1([insertionContext save:&saveError], @"Unhandled error saving managed object context in import thread: %@", [saveError localizedDescription]);
        countForNumberOfBlogEntriesToBeSaved = 0;
    }
}

-(void)finishProcessingCurrentImage
{
    countForNumberOfImagesToBeSaved++;
}

-(void)finishProcessingCurrentComment
{
    countForNumberOfCommentsToBeSaved++;
}

#pragma mark - appropriate getters

- (NSManagedObjectContext *)insertionContext {
    if (insertionContext == nil) {
        insertionContext = [[NSManagedObjectContext alloc] init];
        [insertionContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return insertionContext;
}

- (NSEntityDescription *)currentBlogEntryDescription {
    if (currentBlogEntryDescription == nil) {
        currentBlogEntryDescription = [NSEntityDescription entityForName:@"BlogEntry" inManagedObjectContext:self.insertionContext];
    }
    return currentBlogEntryDescription;
}
- (BlogEntry *)currentBlogEntry {
    if (currentBlogEntry == nil) {
        currentBlogEntry = [[BlogEntry alloc] initWithEntity:self.currentBlogEntryDescription insertIntoManagedObjectContext:self.insertionContext];
    }
    return currentBlogEntry;
}

- (NSEntityDescription *)currentTumblrEntryDescription {
    if (currentTumblrEntryDescription == nil) {
        currentTumblrEntryDescription = [NSEntityDescription entityForName:@"TumblrEntry" inManagedObjectContext:self.insertionContext];
    }
    return currentTumblrEntryDescription;
}
- (TumblrEntry *)currentTumblrEntry {
    if (currentTumblrEntry == nil) {
        currentTumblrEntry = [[TumblrEntry alloc] initWithEntity:self.currentTumblrEntryDescription insertIntoManagedObjectContext:self.insertionContext];
    }
    return currentTumblrEntry;
}

- (NSEntityDescription *)currentImageDescription {
    if (currentImageDescription == nil) {
        currentImageDescription = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:self.insertionContext];
    }
    return currentImageDescription;
}
- (Image *)currentImage {
    if (currentImage == nil) {
        currentImage = [[Image alloc] initWithEntity:self.currentImageDescription insertIntoManagedObjectContext:self.insertionContext];
    }
    return currentImage;
}

- (NSEntityDescription *)currentCategoryDescription {
    if (currentCategoryDescription == nil) {
        currentCategoryDescription = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.insertionContext];
    }
    return currentCategoryDescription;
}
- (Category *)currentCategory {
    if (currentCategory == nil) {
        currentCategory = [[Category alloc] initWithEntity:self.currentCategoryDescription insertIntoManagedObjectContext:self.insertionContext];
    }
    return currentCategory;
}


#pragma mark - JSON importing

-(void)importJSONWithLatestPosts:(NSString*)jsonString forCategoryId:(NSString*)categoryId
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    if([delegate respondsToSelector:@selector(didStartImportingData)]){
        [delegate didStartImportingData];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
    
    SBJSON *parser = [[SBJSON alloc] init];
    
    NSString *json_string = [jsonString copy];
    NSDictionary *dictionaryFromJSON = [parser objectWithString:json_string error:nil];
    NSArray *articlesArray = [dictionaryFromJSON objectForKey:kTLArticles];
    
    //prepare importing
    NSManagedObjectContext *newManagedObjectContext = [[NSManagedObjectContext alloc] init];
    [newManagedObjectContext setPersistentStoreCoordinator:[insertionContext persistentStoreCoordinator]];
    
    [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:newManagedObjectContext];
    NSError *saveError = nil;
    
    BOOL savedOk = NO;
    
    
    //----------------------------------------------------
    //IMPORT ARTICLES
    
    //enumerate articles
    for (NSDictionary* oneArticle in articlesArray) 
    {
        [self importOneArticleFromDictionary:oneArticle];
    }
    savedOk = [insertionContext save:&saveError];
    
    
    
    NSLog(@"self.lastImportDateForMainPageArticle: %@", self.lastImportDateForMainPageArticle);
    NSLog(@"importJSONWithMorePosts __onecall_didFinishImportingData: savedOk: %@", savedOk ? @"TRUE" : @"FALSE");
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:delegate name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
    [[NSNotificationCenter defaultCenter] removeObserver:delegate name:NSManagedObjectContextDidSaveNotification object:newManagedObjectContext];
    
    if (savedOk) {
        
#warning THIS MAY NOT BE FUNCTIONING PROPERLY; IT CAN BE THAT THe self.currentDateForLeastRecentArticle is not set right, not sure
        //save date for least recent article
        [appDelegate.userDefaultsManager setDateForLeastRecentArticle:self.currentDateForLeastRecentArticle withCategoryId:categoryId];
        
        
        if([delegate respondsToSelector:@selector(didFinishImportingData)]){
            [delegate didFinishImportingData];
        }
    }
    else {
        if([delegate respondsToSelector:@selector(didFailImportingData)]){
            [delegate didFailImportingData];
        }
    }
}

-(void)importJSONWithMorePosts:(NSString*)jsonString forCategoryId:(NSString*)categoryId
{
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    if([delegate respondsToSelector:@selector(didStartImportingData)]){
        [delegate didStartImportingData];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
    
    SBJSON *parser = [[SBJSON alloc] init];
    
    NSString *json_string = [jsonString copy];
    NSDictionary *dictionaryFromJSON = [parser objectWithString:json_string error:nil];
    NSArray *articlesArray = [dictionaryFromJSON objectForKey:kTLArticles];
    
    //prepare importing
    NSManagedObjectContext *newManagedObjectContext = [[NSManagedObjectContext alloc] init];
    [newManagedObjectContext setPersistentStoreCoordinator:[insertionContext persistentStoreCoordinator]];
    
    [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:newManagedObjectContext];
    NSError *saveError = nil;
    
    BOOL savedOk = NO;

    
    //----------------------------------------------------
    //IMPORT ARTICLES
    
    //enumerate articles
    for (NSDictionary* oneArticle in articlesArray) 
    {
        [self importOneArticleFromDictionary:oneArticle];
    }
    savedOk = [insertionContext save:&saveError];
    
    
    
    NSLog(@"self.lastImportDateForMainPageArticle: %@", self.lastImportDateForMainPageArticle);
    NSLog(@"importJSONWithMorePosts __onecall_didFinishImportingData: savedOk: %@", savedOk ? @"TRUE" : @"FALSE");
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:delegate name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
    [[NSNotificationCenter defaultCenter] removeObserver:delegate name:NSManagedObjectContextDidSaveNotification object:newManagedObjectContext];
    
    if (savedOk) {
        
#warning THIS MAY NOT BE FUNCTIONING PROPERLY; IT CAN BE THAT THe self.currentDateForLeastRecentArticle is not set right, not sure
        //save date for least recent article
        [appDelegate.userDefaultsManager setDateForLeastRecentArticle:self.currentDateForLeastRecentArticle withCategoryId:categoryId];
        
        
        if([delegate respondsToSelector:@selector(didFinishImportingData)]){
            [delegate didFinishImportingData];
        }
    }
    else {
        if([delegate respondsToSelector:@selector(didFailImportingData)]){
            [delegate didFailImportingData];
        }
    }
}

-(void)importJSONStringForFirstRun:(NSString*)jsonString{
    
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    if([delegate respondsToSelector:@selector(didStartImportingData)]){
        [delegate didStartImportingData];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
    
    SBJSON *parser = [[SBJSON alloc] init];
    
    NSString *json_string = [jsonString copy];
    NSDictionary *dictionaryFromJSON = [parser objectWithString:json_string error:nil];

    NSDictionary *metaInformationDictionary = [dictionaryFromJSON objectForKey:kTLMetaInformation];
    NSArray *categoriesArray = [metaInformationDictionary objectForKey:kTLCategoriesList];
    NSArray *articlesArray = [dictionaryFromJSON objectForKey:kTLArticles];
    
    //prepare importing
    NSManagedObjectContext *newManagedObjectContext = [[NSManagedObjectContext alloc] init];
    [newManagedObjectContext setPersistentStoreCoordinator:[insertionContext persistentStoreCoordinator]];
    
    [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:newManagedObjectContext];
    NSError *saveError = nil;
    
    BOOL savedOk = NO;
    
    
    //----------------------------------------------------
    //IMPORT METAINFORMATION
    
    //import categories if needed
    for (NSDictionary* oneCategory in categoriesArray) 
    {
        NSString *categoryName = [oneCategory objectForKey:kFKCategoryName];
        NSString *categoryId = [[oneCategory objectForKey:kFKCategoryId] stringValue];
        NSString *categoryDescription = [oneCategory objectForKey:kFKCategoryDescription];
        
        //create new BlogEntry
        self.currentCategory = nil;
        self.currentCategory.categoryId = categoryId;
        self.currentCategory.name = categoryName;
        self.currentCategory.categoryDescription = categoryDescription;
    }
    
    //----------------------------------------------------
    //IMPORT ARTICLES
        
    //enumerate articles
    for (NSDictionary* oneArticle in articlesArray) 
    {
        [self importOneArticleFromDictionary:oneArticle];
    }
    savedOk = [insertionContext save:&saveError];
    
   
    //update the date of the last imported article for the main page
    if (savedOk && self.currentBlogEntry.publishingDate!=nil) 
    {
        
#warning THIS MAY NOT BE FUNCTIONING PROPERLY; IT CAN BE THAT THe self.currentDateForLeastRecentArticle is not set right, not sure
#warning make sure this method (importJSONString) is only called when importing
        //save date for least recent article
        NSString* homeCategoryId = [NSString stringWithFormat:@"%d",kCategoryIndexForHome];
        [appDelegate.userDefaultsManager setDateForLeastRecentArticle:self.currentDateForLeastRecentArticle withCategoryId:homeCategoryId];
        
        self.lastImportDateForMainPageArticle = self.currentBlogEntry.publishingDate;
        [self updateLastDateForImportedArticleForMainPage];
    }
    else 
    {
        NSLog(@"did not save or publishing date is nil");
    }
    
    
    NSLog(@"self.lastImportDateForMainPageArticle: %@", self.lastImportDateForMainPageArticle);
    
    NSLog(@"importJSONString __onecall_didFinishImportingData: savedOk: %@", savedOk ? @"TRUE" : @"FALSE");
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:delegate name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
    [[NSNotificationCenter defaultCenter] removeObserver:delegate name:NSManagedObjectContextDidSaveNotification object:newManagedObjectContext];
    
    if (savedOk) {
        if([delegate respondsToSelector:@selector(didFinishImportingData)]){
            [delegate didFinishImportingData];
        }
    }
    else {
        if([delegate respondsToSelector:@selector(didFailImportingData)]){
            [delegate didFailImportingData];
        }
    }
    
}


-(void)importOneArticleFromDictionary:(NSDictionary*)oneArticle
{
    LOG_CURRENT_FUNCTION()
    
    //create BlogEntry
    NSString *blogEntryTitle = [oneArticle objectForKey:kFKArticleTitle];
    NSString *blogEntryDescriptionText = [oneArticle objectForKey:kFKArticleDescriptionText];
    NSString *blogEntryPublishDate = [oneArticle objectForKey:kFKArticlePublishingDate];
    NSString *blogEntryCategoryName = [oneArticle objectForKey:kFKArticleCategoryName];
    NSString *blogEntryWebLink = [oneArticle objectForKey:kFKArticleWebLink];
    
    NSArray *blogEntryRelatedArticles = [oneArticle objectForKey:kFKArticleRelatedArticles];

    id unconvertedBlogEntryCategoryId = [oneArticle objectForKey:kFKArticleCategoryId];
    id unconvertedBlogEntryArticleId = [oneArticle objectForKey:kFKArticleId]; 
    id unconvertedBlogEntryNumberOfViews = [oneArticle objectForKey:kFKArticleNumberOfViews]; 
    id unconvertedBlogEntryShouldShowOnHomeCategory = [oneArticle objectForKey:kFKArticleShowOnHomeCategory];
    
    
    NSNumber* blogEntryShouldShowOnHomeCategory = [NSNumber numberWithBool:[unconvertedBlogEntryShouldShowOnHomeCategory boolValue]];
    
    NSString *blogEntryCategoryId = [unconvertedBlogEntryCategoryId isKindOfClass:[NSNumber class]] ? [unconvertedBlogEntryCategoryId stringValue] : unconvertedBlogEntryCategoryId;
    NSString *blogEntryArticleId = [unconvertedBlogEntryArticleId isKindOfClass:[NSNumber class]] ? [unconvertedBlogEntryArticleId stringValue] : unconvertedBlogEntryArticleId;
    
    NSNumber * blogEntryNumberOfViews = nil;
    
    if ([unconvertedBlogEntryNumberOfViews isKindOfClass:[NSString class]]) 
    {
        NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
        blogEntryNumberOfViews = [numberFormatter numberFromString:unconvertedBlogEntryNumberOfViews];
    }
    else
    {
        blogEntryNumberOfViews = unconvertedBlogEntryNumberOfViews;
    }
    
    //check if entry with this articleId already exists
    NSFetchRequest *checkRequest = self.checkingFetchRequestForBlogEntries; 
    [checkRequest setPredicate:[NSPredicate predicateWithFormat:@"articleId == %@", blogEntryArticleId]];
    
    NSError *error = nil;
    NSArray *result = [self.insertionContext executeFetchRequest:checkRequest error:&error];
    if (error==nil) {
        
        //rewrite logic can be implemented here
        if ([result count]>0) {
            BlogEntry* entry = (BlogEntry*)[result objectAtIndex:0];
            NSLog(@"skipping found entry: %@",entry.title);
            
            return;
        }
    }
    else {
#warning handle fetch error
        NSLog(@"error is not nil this should be handled");
    }
    
    
#warning fix date to take GMT into consideration
    //2012-03-02T00:00:00+00:00
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate *myDate = [df dateFromString: blogEntryPublishDate];
    
    //save to current date for least recent article
    if(_currentDateForLeastRecentArticle==nil || [_currentDateForLeastRecentArticle compare:myDate]==NSOrderedDescending)
    self.currentDateForLeastRecentArticle = myDate;
    
    //create new BlogEntry
    self.currentBlogEntry = nil;
    self.currentBlogEntry.articleId = blogEntryArticleId;
    self.currentBlogEntry.title = blogEntryTitle;
    self.currentBlogEntry.descriptionText = blogEntryDescriptionText;
    self.currentBlogEntry.publishingDate = myDate;
    self.currentBlogEntry.categoryName = blogEntryCategoryName;
    self.currentBlogEntry.categoryId = blogEntryCategoryId;
    self.currentBlogEntry.relatedArticles = blogEntryRelatedArticles;
    self.currentBlogEntry.numberOfViews = blogEntryNumberOfViews;
    self.currentBlogEntry.showInHomeCategory = blogEntryShouldShowOnHomeCategory;
    self.currentBlogEntry.webLink = blogEntryWebLink;
    
    
    /////////////////////////// handle the thumb image image
    NSDictionary *aImageDictionary = [oneArticle objectForKey:kFKArticleThumbImage];
    
    if (aImageDictionary!=nil) {
        
        NSString* imageIdentifier = [aImageDictionary objectForKey:kFKImageId];
        NSString* imageCaption = [aImageDictionary objectForKey:kFKImageDescription];
        NSString* imageBase64String =  [aImageDictionary objectForKey:kFKImageBase64Representation];
        
        self.currentBlogEntry.thumbIdentifier = imageIdentifier;
        
        //create new image
        self.currentImage = nil;
        self.currentImage.entry = self.currentBlogEntry;
        self.currentImage.identifier = imageIdentifier; 
        self.currentImage.caption = imageCaption; 
        
        //save the image file
        NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        applicationDocumentsDir = [applicationDocumentsDir stringByAppendingFormat:@"thumbs/"];
        NSString *storePath = [applicationDocumentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg",imageIdentifier]];
        
        //imagefile already exists, don't save it
        if ([[NSFileManager defaultManager] fileExistsAtPath:storePath]){
            NSLog(@"image file already exists"); 
        }
        else
        {
            UIImage *image = [[UIImage alloc] initWithData:[NSData dataFromBase64String:imageBase64String]];
            NSData *data2 = [[NSData alloc] initWithData:UIImageJPEGRepresentation(image, 1.0f)];
            
            NSError *error = nil;
            BOOL didSaveImageFile = [data2 writeToFile:storePath options:NSDataWritingAtomic error:&error];
            
            
            if (didSaveImageFile) {
                NSLog(@"didSave: %@", imageIdentifier);
            }
            else{
                NSLog(@"didNotSave: %@, error: %@", imageIdentifier, error);
            }
            
        }
        
        //handle remote images urls
        NSArray *remoteImages = [oneArticle objectForKey:kFKArticleRemoteImages];
        
        if (remoteImages!=nil) 
        {    
            self.currentBlogEntry.remoteImages = remoteImages;
        }
    }
    else {
        NSLog(@"image dictionary is nil");
    }
}

-(void)importJSONStringForSingleArticle:(NSString*)jsonStringWithSingleArticle
{
    LOG_CURRENT_FUNCTION()
    
    if(delegate!=nil){
        [delegate importerDidStartParsingSingleArticle:self];
    }
    
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *dictionaryFromJSON = [parser objectWithString:jsonStringWithSingleArticle error:nil];
    
    //check if an error has occured
    BOOL errorOccured = [[dictionaryFromJSON objectForKey:kTLError] boolValue];
    if (dictionaryFromJSON==nil || errorOccured) 
    {
        if(delegate!=nil){
            [delegate importer:self didFailParsingSingleArticleWithDictionary:dictionaryFromJSON];
        }
        
        return;
    }
    
    //try to get article data
    NSDictionary *metaInformationDictionary = [dictionaryFromJSON objectForKey:kTLMetaInformation];    
    NSDictionary *articleDictionary = [dictionaryFromJSON objectForKey:kTLSingleArticle];
    
    if(delegate!=nil){
        [delegate importer:self didFinishParsingSingleArticleWithDictionary:articleDictionary];
    }
    
}

#pragma mark - import TUMBLR data

-(void)importJSONStringForTumblrPosts:(NSString*)jsonString{
    LOG_CURRENT_FUNCTION()
    
    if([delegate respondsToSelector:@selector(didStartImportingData)]){
        [delegate didStartImportingData];
    }
    
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *dictionaryFromJSON = [parser objectWithString:jsonString error:nil];
    NSArray *tumblrPostsArray = [dictionaryFromJSON objectForKey:kTLPosts];
    
    for (NSDictionary* oneTumblrPost in tumblrPostsArray) {
        [self importOneTumblrPostFromDictionary:oneTumblrPost];
    }
    
    BOOL savedOk = NO;
    NSError *saveError = nil;
    
    //try to save the context with the imported articles
    savedOk = [insertionContext save:&saveError];
    
    if (savedOk) {
        NSLog(@"could save tumblr posts");
    }
    else {
        NSLog(@"ERROR: exporting tumblr posts");
    }
    
    
    
    if (savedOk) {
        if([delegate respondsToSelector:@selector(didFinishImportingData)]){
            [delegate didFinishImportingData];
        }
    }
    else {
        if([delegate respondsToSelector:@selector(didFailImportingData)]){
            [delegate didFailImportingData];
        }
    }
}


-(void)importOneTumblrPostFromDictionary:(NSDictionary*)oneTumblrPost
{
    LOG_CURRENT_FUNCTION()
    
    NSString *tumblrEntryUrl = [oneTumblrPost objectForKey:kTumblrPostImageUrl];
    NSNumber *tumblrEntryPublishingDateTimestamp = [oneTumblrPost objectForKey:kTumblrPostPublishingDate]; 
    NSDate* tumblrEntryPublishingDate = [NSDate dateWithTimeIntervalSince1970:[tumblrEntryPublishingDateTimestamp intValue]];
    
    //check if entry with this articleId already exists
    NSFetchRequest *checkRequest = self.checkingFetchRequestForTumblrEntries; 
    [checkRequest setPredicate:[NSPredicate predicateWithFormat:@"publishingDate == %@", tumblrEntryPublishingDate]];
    
    NSError *error = nil;
    NSArray *result = [self.insertionContext executeFetchRequest:checkRequest error:&error];
    if (error==nil) {
        
        //rewrite logic can be implemented here
        if ([result count]>0) {
            TumblrEntry* entry = (TumblrEntry*)[result objectAtIndex:0];
            NSLog(@"skipping found tumblr entry: %@",entry.publishingDate);
            
            return;
        }
    }
    else {
#warning handle fetch error
        NSLog(@"error is not nil this should be handled");
    }
    
    self.currentTumblrEntry = nil;
    self.currentTumblrEntry.imageUrl = tumblrEntryUrl;
    self.currentTumblrEntry.publishingDate = tumblrEntryPublishingDate;
    
}

-(void)updateLastDateForImportedArticleForMainPage {
    
    if (self.lastImportDateForMainPageArticle==nil)
    return;    
    

        [[NSUserDefaults standardUserDefaults] setObject:self.lastImportDateForMainPageArticle forKey:kUserDefaultsLastImportDateForMainPageArticle];
        [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - fetch requests for checking existence

-(NSFetchRequest*)checkingFetchRequestForTumblrEntries
{
    if (_checkingFetchRequestForTumblrEntries==nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TumblrEntry" inManagedObjectContext:self.insertionContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchLimit:1];
        [fetchRequest setFetchBatchSize:1];
        self.checkingFetchRequestForTumblrEntries = fetchRequest;
    }
    
    return _checkingFetchRequestForTumblrEntries;
}

-(NSFetchRequest*)checkingFetchRequestForBlogEntries
{
    if (_checkingFetchRequestForBlogEntries==nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"BlogEntry" inManagedObjectContext:self.insertionContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchLimit:1];
        [fetchRequest setFetchBatchSize:1];
        self.checkingFetchRequestForBlogEntries = fetchRequest;
    }
    
    return _checkingFetchRequestForBlogEntries;
}

-(NSFetchRequest*)checkingFetchRequestForCategories
{
    if (_checkingFetchRequestForCategories==nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.insertionContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchLimit:1];
        [fetchRequest setFetchBatchSize:1];
        self.checkingFetchRequestForCategories = fetchRequest;
    }
    
    return _checkingFetchRequestForCategories;
}

-(BlogEntry*)blogEntryWithId:(NSString*)blogEntryId
{
    BlogEntry* entry = nil;
    NSFetchRequest *checkRequest = self.checkingFetchRequestForBlogEntries; 
    [checkRequest setPredicate:[NSPredicate predicateWithFormat:@"articleId == %@", blogEntryId]];
    
    NSError *error = nil;
    NSArray *result = [self.insertionContext executeFetchRequest:checkRequest error:&error];
    if (error==nil) {
        if ([result count]>0) {
            entry = (BlogEntry*)[result objectAtIndex:0];
        }
    }
    else {
        #warning handle fetch error
        NSLog(@"error is not nil this should be handled");
    }

    return entry;
}

@end
