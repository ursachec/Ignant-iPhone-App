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

#define TEST_JSON_DUMP [[NSBundle mainBundle] pathForResource:@"dump_images_big_jpg" ofType:@"txt"]


// String used to identify the update object in the user defaults storage.
NSString* const kLastImportedBlogEntryDateKey = @"LastImportedBlogEntryDate";

NSString *const kUserDefaultsLastImportDateForMainPageArticle = @"last_import_date_for_main_article";


NSString *const feedAdress = @"http://feeds2.feedburner.com/ignant";
//NSString *const feedAdress = @"feed://www.google.com/reader/atom/feed/feed://feeds.feedburner.com/ignant?n=4&r=o&et=1325451846";




#import "Image.h"
#import "BlogEntry.h"

#warning DELETE RSS Parser entries before releasing app

@interface IgnantImporter() 
{
    
	MWFeedParser *feedParser;
	NSMutableArray *parsedItems;
	NSDateFormatter *formatter;
    
    NSManagedObjectContext *insertionContext;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    
    NSDate *latestDayOfCurrentFeed;
}

-(void)updateLastDateForImportedArticleForMainPage;

-(void)importOneArticleFromDictionary:(NSDictionary*)oneArticleDictionary;


@property (nonatomic, retain) NSDate* lastImportDateForMainPageArticle;


@property (nonatomic, retain) Image* currentImage;
@property (nonatomic, retain) BlogEntry* currentBlogEntry;
@property (nonatomic, retain) Category* currentCategory;


@property (nonatomic, retain, readonly) NSEntityDescription *currentImageDescription;
@property (nonatomic, retain, readonly) NSEntityDescription *currentBlogEntryDescription;
@property (nonatomic, retain, readonly) NSEntityDescription *currentCategoryDescription;

@property NSUInteger countForNumberOfBlogEntriesToBeSaved;
@property NSUInteger countForNumberOfImagesToBeSaved;
@property NSUInteger countForNumberOfCommentsToBeSaved;

@property (nonatomic, retain) NSDate *latestDayOfCurrentFeed;

@end

#pragma mark -

@implementation IgnantImporter
@synthesize delegate;
@synthesize insertionContext = _insertionContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize currentImage, currentBlogEntry, currentImageDescription, currentBlogEntryDescription, currentCategory, currentCategoryDescription;

@synthesize countForNumberOfBlogEntriesToBeSaved, countForNumberOfImagesToBeSaved, countForNumberOfCommentsToBeSaved;

@synthesize latestDayOfCurrentFeed = _latestDayOfCurrentFeed;

@synthesize lastImportDateForMainPageArticle = _lastImportDateForMainPageArticle;

-(id)init
{
    self = [super init];

    if (self) {
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        parsedItems = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)dealloc
{
    
#warning IMPLEMENT DEALLOC
    
    [super dealloc];
}

-(void)startImportingDataFromIgnant
{
    if (delegate && [delegate respondsToSelector:@selector(importerDidSave:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
    }
    
    if ([delegate respondsToSelector:@selector(didStartImportingRSSData)]) {
        [delegate didStartImportingRSSData];
    }
    
    NSURL *feedURL = [NSURL URLWithString:feedAdress];
	feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
	feedParser.delegate = self;
	feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
	feedParser.connectionType = ConnectionTypeAsynchronously;
	[feedParser parse];
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


#pragma mark - parsing


-(void)finishImportingDataFromIgnantWithError:(NSError*)error
{
    if ([delegate respondsToSelector:@selector(didFinishImportingRSSData)]) {
        [delegate didFinishImportingRSSData];
    }
    
    if (delegate && [delegate respondsToSelector:@selector(importerDidSave:)]) {
        [[NSNotificationCenter defaultCenter] removeObserver:delegate name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
    }
}

#pragma - MWFeedParserDelegate DEBUGGING
#warning debugging here
- (void)feedParserDidStart:(MWFeedParser *)parser {
    
    if ([delegate respondsToSelector:@selector(didStartParsingRSSData)]) {
        [delegate didStartParsingRSSData];
    }
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
	NSLog(@"Parsed Feed Info: “%@”", info.title);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
    
    NSDate *lastSavedObjectDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastImportedBlogEntryDateKey];
    
    //only use the feedItem if its date is newer than that of the last saved object 
    if ( lastSavedObjectDate!=nil && ([item.date compare:lastSavedObjectDate]!=NSOrderedDescending) ) {
        return;
    }
    //check if a BlogEntry with the same title already exists
    NSString *decodedContentString = [item.content stringByDecodingHTMLEntities];
    NSString *entitiesDecodedDescriptionString = [item.summary stringByDecodingHTMLEntities];
    
    //create new BlogEntry
    self.currentBlogEntry = nil;
    self.currentBlogEntry.title = item.title;
    self.currentBlogEntry.publishingDate = item.date;
    self.currentBlogEntry.descriptionText = entitiesDecodedDescriptionString;
    
    if ([item.date compare:self.latestDayOfCurrentFeed]==NSOrderedDescending) {
        self.latestDayOfCurrentFeed = item.date;
    }
    
    //find images using regex and import them
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\http://www.ignant.de/wp-content/uploads/([0-9]*)/([0-9]*)/([-_a-z]*)([0-9]*).(jpg|jpeg|png)+\\b"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *matches = [regex matchesInString:decodedContentString
                                      options:0
                                        range:NSMakeRange(0, [decodedContentString length])];
    NSLog(@"matches number of: %d", [matches count]);
    
    BOOL thumbnailImageAdressResolved = NO;
    NSString *thumbnailImageAdress = @"";
    
    for (NSTextCheckingResult *match in matches) {
        
        NSString *matchedString = [decodedContentString substringWithRange:[match range]];
        NSString *firstMatchedString = [decodedContentString substringWithRange:[match rangeAtIndex:1]];
        NSString *secondMatchedString = [decodedContentString substringWithRange:[match rangeAtIndex:2]];
        NSString *thirdMatchedString = [decodedContentString substringWithRange:[match rangeAtIndex:3]];
        NSString *fourthMatchedString = [decodedContentString substringWithRange:[match rangeAtIndex:4]]; 
        NSString *fifthMatchedString = [decodedContentString substringWithRange:[match rangeAtIndex:5]]; 
        NSString *imageFilenameWithExtention = [NSString stringWithFormat:@"%@.%@",fourthMatchedString,fifthMatchedString];
        
        //create new image
        self.currentImage = nil;
        self.currentImage.url = matchedString;
        self.currentImage.filename = imageFilenameWithExtention;
        self.currentImage.entry = self.currentBlogEntry;
        
        
        if(!thumbnailImageAdressResolved)
        {
            thumbnailImageAdress = [NSString stringWithFormat:@"http://www.ignant.de/wp-content/uploads/%@/%@/%@pre.%@",firstMatchedString,secondMatchedString,thirdMatchedString,fifthMatchedString];
            
            NSLog(@"thumbnailImageAdress: %@", thumbnailImageAdress);
            
            self.currentBlogEntry.thumbImageFilename = thumbnailImageAdress;
            
            thumbnailImageAdressResolved=YES;
        } 
        //this is not needed yet
//        [self finishProcessingCurrentImage];
    }
    
    [self finishProcessingCurrentBlogEntry];
    
	if (item) [parsedItems addObject:item];	
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
    
    //save the publishing date of the latest object
    [[NSUserDefaults standardUserDefaults] setObject:_latestDayOfCurrentFeed forKey:kLastImportedBlogEntryDateKey];
    
    
    NSError *saveError = nil;
    NSAssert1([insertionContext save:&saveError], @"Unhandled error saving managed object context in import thread: %@", [saveError localizedDescription]);
    

    if ([delegate respondsToSelector:@selector(didFinishParsingRSSData)]) {
        [delegate didFinishParsingRSSData];
    }
    
    [self finishImportingDataFromIgnantWithError:nil];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
	NSLog(@"Finished Parsing With Error: %@", error);
    if (parsedItems.count == 0) {
        
    } else {
        // Failed but some items parsed, so show and inform of error
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Parsing Incomplete"
                                                         message:@"There was an error during the parsing of this feed. Not all of the feed items could parsed."
                                                        delegate:nil
                                               cancelButtonTitle:@"Dismiss"
                                               otherButtonTitles:nil] autorelease];
        [alert show];
    }
    [self finishImportingDataFromIgnantWithError:error];
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
        currentBlogEntryDescription = [[NSEntityDescription entityForName:@"BlogEntry" inManagedObjectContext:self.insertionContext] retain];
    }
    return currentBlogEntryDescription;
}
- (BlogEntry *)currentBlogEntry {
    if (currentBlogEntry == nil) {
        currentBlogEntry = [[BlogEntry alloc] initWithEntity:self.currentBlogEntryDescription insertIntoManagedObjectContext:self.insertionContext];
    }
    return currentBlogEntry;
}

- (NSEntityDescription *)currentImageDescription {
    if (currentImageDescription == nil) {
        currentImageDescription = [[NSEntityDescription entityForName:@"Image" inManagedObjectContext:self.insertionContext] retain];
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
        currentCategoryDescription = [[NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.insertionContext] retain];
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
-(void)importJSONString:(NSString*)jsonString{
    
    if([delegate respondsToSelector:@selector(didStartImportingRSSData)]){
        [delegate didStartImportingRSSData];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
    
    SBJSON *parser = [[SBJSON alloc] init];
    
    NSString *filePath = TEST_JSON_DUMP;
    NSData *response = [NSData dataWithContentsOfFile:filePath];
    
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *dictionaryFromJSON = [parser objectWithString:json_string error:nil];

    NSDictionary *metaInformationDictionary = [dictionaryFromJSON objectForKey:kTLMetaInformation];
    NSArray *categoriesArray = [metaInformationDictionary objectForKey:kTLCategoriesList];
    NSArray *articlesArray = [dictionaryFromJSON objectForKey:kTLArticles];
    
    //prepare importing
    NSManagedObjectContext *newManagedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
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
        self.lastImportDateForMainPageArticle = self.currentBlogEntry.publishingDate;
        [self updateLastDateForImportedArticleForMainPage];
    }
    else 
    {
        NSLog(@"did not save or publishing date is nil");
    }
    
    
    NSLog(@"self.lastImportDateForMainPageArticle: %@", self.lastImportDateForMainPageArticle);
    
    NSLog(@"__onecall_didFinishImportingRSSData: savedOk: %@", savedOk ? @"TRUE" : @"FALSE");
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:delegate name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
    [[NSNotificationCenter defaultCenter] removeObserver:delegate name:NSManagedObjectContextDidSaveNotification object:newManagedObjectContext];
    
    if([delegate respondsToSelector:@selector(didFinishImportingRSSData)]){
        [delegate didFinishImportingRSSData];
    }
}


-(void)importOneArticleFromDictionary:(NSDictionary*)oneArticle
{
    
    //create BlogEntry
    NSString *blogEntryTitle = [oneArticle objectForKey:kFKArticleTitle];
    NSString *blogEntryDescriptionText = [oneArticle objectForKey:kFKArticleDescriptionText];
    NSString *blogEntryPublishDate = [oneArticle objectForKey:kFKArticlePublishingDate];
    NSString *blogEntryCategoryName = [oneArticle objectForKey:kFKArticleCategoryName];
        
    NSArray *blogEntryRelatedArticles = [oneArticle objectForKey:kFKArticleRelatedArticles];

    id unconvertedBlogEntryCategoryId = [oneArticle objectForKey:kFKArticleCategoryId];
    id unconvertedBlogEntryArticleId = [oneArticle objectForKey:kFKArticleId]; 
    
    NSString *blogEntryCategoryId = [unconvertedBlogEntryCategoryId isKindOfClass:[NSNumber class]] ? [unconvertedBlogEntryCategoryId stringValue] : unconvertedBlogEntryCategoryId;
    NSString *blogEntryArticleId = [unconvertedBlogEntryArticleId isKindOfClass:[NSNumber class]] ? [unconvertedBlogEntryArticleId stringValue] : unconvertedBlogEntryArticleId;
    
#warning fix date to take GMT into consideration
    //2012-03-02T00:00:00+00:00
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate *myDate = [df dateFromString: blogEntryPublishDate];
    
    
    //create new BlogEntry
    self.currentBlogEntry = nil;
    self.currentBlogEntry.articleId = blogEntryArticleId;
    self.currentBlogEntry.title = blogEntryTitle;
    self.currentBlogEntry.descriptionText = blogEntryDescriptionText;
    self.currentBlogEntry.publishingDate = myDate;
    self.currentBlogEntry.categoryName = blogEntryCategoryName;
    self.currentBlogEntry.categoryId = blogEntryCategoryId;
    self.currentBlogEntry.relatedArticles = blogEntryRelatedArticles;
        
    
    //add the article to the specific category
    
    //fetch the category
#warning TODO: fetch the category and add it to the viewcontroller
    
    
    
    
    
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
            
            [image release];
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

-(void)importJSONStringWithMorePosts:(NSString*)jsonStringWithPosts
{
 
    NSLog(@"importJSONStringWithMorePosts: %@",jsonStringWithPosts);
    
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *dictionaryFromJSON = [parser objectWithString:jsonStringWithPosts error:nil];
    
    BOOL errorOccured = [[dictionaryFromJSON objectForKey:kTLError] boolValue];
    
    
    NSDictionary *metaInformationDictionary = [dictionaryFromJSON objectForKey:kTLMetaInformation];
    NSArray *categoriesArray = [metaInformationDictionary objectForKey:kTLCategoriesList];
    
    NSArray *articlesArray = [dictionaryFromJSON objectForKey:kTLArticles];
    
    

    //prepare importing
    NSManagedObjectContext *newManagedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
    [newManagedObjectContext setPersistentStoreCoordinator:[insertionContext persistentStoreCoordinator]];
    
    [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:newManagedObjectContext];
    NSError *saveError = nil;
    
    BOOL savedOk = NO;
    
    
    NSLog(@"numberOfArticlesToImport: %d", [articlesArray count]);

    
    //enumerate articles
    for (NSDictionary* oneArticle in articlesArray) 
    {
        [self importOneArticleFromDictionary:oneArticle];
    }
    
    
    
#warning IMPLEMENT "no more articles available for this category" in User Defaults
    
    
    if (errorOccured) {
        
        NSLog(@"error sent from server, handle it!");
#warning TODO: handle Server error
        
        return;
    }
    
    //try to save the context with the imported articles
    savedOk = [insertionContext save:&saveError];
    
    //update the date of the last imported article for the main page
    if (savedOk && self.currentBlogEntry.publishingDate!=nil) 
    {
        self.lastImportDateForMainPageArticle = self.currentBlogEntry.publishingDate;
        [self updateLastDateForImportedArticleForMainPage];
    }
    else 
    {
        NSLog(@"did not save or publishing date is nil");
    }
    
    
    NSLog(@"self.lastImportDateForMainPageArticle: %@", self.lastImportDateForMainPageArticle);
    
    
    NSLog(@"__onecall_didFinishImportingRSSData: savedOk: %@", savedOk ? @"TRUE" : @"FALSE");
    
    
    if([delegate respondsToSelector:@selector(didFinishImportingRSSData)]){
        [delegate didFinishImportingRSSData];
    }
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:delegate name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
    [[NSNotificationCenter defaultCenter] removeObserver:delegate name:NSManagedObjectContextDidSaveNotification object:newManagedObjectContext];
    
}

-(void)importJSONStringForSingleArticle:(NSString*)jsonStringWithSingleArticle
{
    NSLog(@"importJSONStringForSingleArticle");
    
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


-(void)updateLastDateForImportedArticleForMainPage {
	[[NSUserDefaults standardUserDefaults] setObject:self.lastImportDateForMainPageArticle forKey:kUserDefaultsLastImportDateForMainPageArticle];
	[[NSUserDefaults standardUserDefaults] synchronize];
}



@end
