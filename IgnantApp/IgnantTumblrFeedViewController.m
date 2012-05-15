//
//  IgnantTumblrFeedViewController.m
//  OtherTests
//
//  Created by Claudiu-Vlad Ursache on 4/3/12.
//  Copyright (c) 2012 Cortado AG. All rights reserved.
//

#import "IgnantTumblrFeedViewController.h"
#import "HJObjManager.h"
#import "HJManagedImageV.h"

//imports for ASIHTTPRequest
#import "ASIHTTPRequest.h"
#import "NSURL+stringforurl.h"

#import "Constants.h"

#warning TODO: implement real data from tumblr

@interface IgnantTumblrFeedViewController ()
{
    BOOL isLoadingMoreTumblr;
    BOOL _showLoadMoreTumblr;
    BOOL isLoadingLatestTumblrArticles;
    

    
    NSArray *_arrayWithTestImages;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
}

@property(nonatomic, retain) HJObjManager *imageManager;
@end

@implementation IgnantTumblrFeedViewController
@synthesize tumblrTableView = _tumblrTableView;
@synthesize imageManager = _imageManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        isLoadingMoreTumblr = NO;
        isLoadingLatestTumblrArticles = NO;
        
        // Set up the image cache manager
        self.imageManager = [[HJObjManager alloc] init];
        
        // Tell the manager where to store the images on the device
        NSString *cacheDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Images/"];
        HJMOFileCache *fileCache = [[[HJMOFileCache alloc] initWithRootPath:
                                     cacheDirectory] autorelease];
        
        // Have the file cache trim itself down to a size & age limit, so it doesn't grow forever
        fileCache.fileCountLimit = 100;
        fileCache.fileAgeLimit = 60*60*24*7; //1 week
        [fileCache trimCacheUsingBackgroundThread];
        
        
        self.imageManager.fileCache = fileCache;
        
        
        
        _arrayWithTestImages = [[NSArray alloc] initWithObjects:
        
    @"http://29.media.tumblr.com/tumblr_m1w8emWNTe1qztdbbo1_400.png",
    @"http://27.media.tumblr.com/tumblr_m1w8af4yZr1qztdbbo1_400.png",
    @"http://24.media.tumblr.com/tumblr_m1pxjwDgpS1qztdbbo1_400.png",
    @"http://29.media.tumblr.com/tumblr_m1pxizsIDB1qztdbbo1_400.png",
    @"http://26.media.tumblr.com/tumblr_m1jx641OGr1qztdbbo1_400.png",
    @"http://27.media.tumblr.com/tumblr_m1fk3dT2Dp1qztdbbo1_400.png",
    @"http://25.media.tumblr.com/tumblr_m1fk1o7w4Z1qztdbbo1_400.png",
    @"http://24.media.tumblr.com/tumblr_m1fk0oM2GF1qztdbbo1_400.png",
    @"http://29.media.tumblr.com/tumblr_m18c8zq3Fv1qztdbbo1_400.png",
                                @"http://29.media.tumblr.com/tumblr_m18c6zOqoo1qztdbbo1_400.png", nil];
        
    }
    return self;
}

- (void)dealloc {
    [_tumblrTableView release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //set up the refresh header view
    if (_refreshHeaderView == nil) {
        
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tumblrTableView.bounds.size.height, self.view.frame.size.width, self.tumblrTableView.bounds.size.height)];
		view.delegate = self;
		[self.tumblrTableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
	}
}

- (void)viewDidUnload
{
    [self setTumblrTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [_refreshHeaderView release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_arrayWithTestImages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    HJManagedImageV* currentImage;
    
    NSURL *urlAtCurrentIndex = [NSURL URLWithString:[_arrayWithTestImages objectAtIndex:indexPath.row]];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier] autorelease];
        
        currentImage = [[[HJManagedImageV alloc] initWithFrame:CGRectMake(5,5,310,310)] autorelease];
        [currentImage setBackgroundColor:[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:0.3]];
        currentImage.tag = 999;
        currentImage.url = urlAtCurrentIndex;
        [self.imageManager manage:currentImage];
        
        
        [cell addSubview:currentImage];
        
    } else{
        currentImage = (HJManagedImageV*)[cell viewWithTag:999];
        [currentImage clear];
    }
    
    
    currentImage.url = urlAtCurrentIndex;
    [currentImage.loadingWheel setColor:[UIColor whiteColor]];
    [self.imageManager manage:currentImage];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];

    //copied code from http://stackoverflow.com/questions/5137943/how-to-know-when-uitableview-did-scroll-to-bottom
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 10;
    if(y > h + reload_distance) 
    {
        if (!isLoadingMoreTumblr) {
            [self loadMoreTumblrArticles];
        }

    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark - server communication actions
-(void)loadMoreTumblrArticles
{    
    if (isLoadingMoreTumblr) return;
    isLoadingMoreTumblr = YES;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetMoreTumblrArticles,kParameterAction, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
    
    NSLog(@"encodedString go: %@",encodedString);
    
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:encodedString]];
	[request setDelegate:self];
	[request startAsynchronous];    
}

-(void)loadLatestTumblrArticles
{
    if (isLoadingLatestTumblrArticles) return;        
    isLoadingLatestTumblrArticles = YES;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetLatestTumblrArticles,kParameterAction, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
    
    NSLog(@"encodedString go: %@",encodedString);
    
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:encodedString]];
	[request setDelegate:self];
	[request startAsynchronous]; 
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    LOG_CURRENT_FUNCTION()
    LOG_CURRENT_FUNCTION_AND_CLASS()
    
    if (isLoadingMoreTumblr) {
        
        
    }
    else if (isLoadingLatestTumblrArticles) {
        
        
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    LOG_CURRENT_FUNCTION()
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    
    if (isLoadingMoreTumblr) {
        
        
        _showLoadMoreTumblr = YES;
        isLoadingMoreTumblr = NO;
        
    }
    else if (isLoadingLatestTumblrArticles) {
        
        isLoadingLatestTumblrArticles = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tumblrTableView];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    LOG_CURRENT_FUNCTION()
    
#warning TODO: do something if the request has failed
    
    if (isLoadingMoreTumblr) {
        
        isLoadingMoreTumblr = NO;
        
    }
    else if (isLoadingLatestTumblrArticles) {
        
        isLoadingLatestTumblrArticles = NO;
        
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tumblrTableView];
    }
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self loadLatestTumblrArticles];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return isLoadingLatestTumblrArticles; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
}

@end
