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


#warning TODO: implement real data from tumblr

@interface IgnantTumblrFeedViewController ()
{

    NSArray *_arrayWithTestImages;
}

@property(nonatomic, retain) HJObjManager *imageManager;
@end

@implementation IgnantTumblrFeedViewController
@synthesize imageManager = _imageManager;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
        NSLog(@"load more tumblr");
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
    NSLog(@"scrollViewDidEndDragging");
}


@end
