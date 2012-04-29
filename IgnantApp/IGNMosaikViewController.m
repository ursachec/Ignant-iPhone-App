//
//  IGNMosaikViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 03.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//


#import "IGNMosaikViewController.h"

#import "LoadMoreMosaicView.h"
#import "MosaicView.h"


//imports for ASIHTTPRequest
#import "ASIHTTPRequest.h"
#import "NSURL+stringforurl.h"

#import "Constants.h"


#warning TODO: see what image size to use / maybe do some server directory selection to differentiate between Retina and NON-Retina display versions


NSString *const filenameForMosaicImagesPlist = @"mosaic_images.plist";


NSString * const kImagesKey = @"images";

NSString * const kImageWidth = @"width";
NSString * const kImageHeight = @"height";
NSString * const kImageUrl = @"url";
NSString * const kImageArticleId = @"articleId";
NSString * const kImageFilename = @"filename";


#define DIRECTORY_FOR_MOSAIC_IMAGES_FILE [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]


@interface IGNMosaikViewController ()
{
    BOOL isLoadingMoreMosaicImages;
}

@property(nonatomic,retain) NSArray* savedMosaicImages;


-(UIColor*)randomColor;

-(void)drawSavedMosaicImages;
-(void)addMoreMosaicImages:(NSArray*)mosaicImages;
-(void)loadMoreMosaicImages;


@end

#pragma mark -

@implementation IGNMosaikViewController
@synthesize bigMosaikView;
@synthesize mosaikScrollView;
@synthesize closeMosaikButton;
@synthesize savedMosaicImages;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - handle going back
-(IBAction)handleBack:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //add the back-to-start button
    UIImage *backButtonImage = [UIImage imageNamed:@"backButton.png"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat ratio = .65;
    backButton.frame = CGRectMake(0, 0, 46*ratio, 30*ratio);
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(handleBack:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    //trigger the drawing for the images
    [self drawSavedMosaicImages];
    
    //resize the scrollview to fit the content properly
    CGRect bigMosaikViewRect = CGRectMake(0, 0, self.bigMosaikView.frame.size.width, self.bigMosaikView.frame.size.height);
    self.bigMosaikView.frame = bigMosaikViewRect;
    
    // add the big mosaik view to the content scrollview
    [self.mosaikScrollView setContentSize:bigMosaikViewRect.size];
    self.bigMosaikView.userInteractionEnabled = YES;
    [self.mosaikScrollView addSubview:self.bigMosaikView];
}

- (void)viewDidUnload
{
    [self setBigMosaikView:nil];
    [self setMosaikScrollView:nil];
    [self setCloseMosaikButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [bigMosaikView release];
    [mosaikScrollView release];
    [closeMosaikButton release];
    [super dealloc];
}

#pragma mark - server communication actions
-(void)loadMoreMosaicImages
{
    NSLog(@"loadMoreMosaicImages");
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kAPICommandGetSetOfMosaicImages,kParameterAction, nil];
    NSString *requestString = kAdressForContentServer;
    NSString *encodedString = [NSURL addQueryStringToUrlString:requestString withDictionary:dict];
    
    NSLog(@"encodedString go: %@",encodedString);
    
    
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:encodedString]];
	[request setDelegate:self];
	[request startAsynchronous];    
    
}

#pragma mark - client-side loading / saving of the mosaic images
-(void)addMoreMosaicImages:(NSArray*)mosaicImages
{
#warning TODO: implement comparing the existing imags and removing duplicates (unique_id for each image - articleId)
    
    //first retrieve the currently saved mosaic images as copy
    NSArray* currentlySavedMosaicImages = [self.savedMosaicImages copy];
    
    //then add the mosaicImages parameter to the currently saved ones
    NSArray* newArrayOfSavedMosaicImages = [currentlySavedMosaicImages arrayByAddingObjectsFromArray:mosaicImages];
    
    //save the new mosaic images array to disk, overwriting the last file
    NSMutableDictionary *imagesDictionary = [[NSMutableDictionary alloc] init];
    [imagesDictionary setObject:[newArrayOfSavedMosaicImages copy] forKey:kImagesKey];
    
    //write the data to the file
    NSString* fullPath = [DIRECTORY_FOR_MOSAIC_IMAGES_FILE stringByAppendingPathComponent:filenameForMosaicImagesPlist];
    if (![imagesDictionary writeToFile:fullPath atomically:NO])
    {
        NSLog(@"didNOTWriteToFile");
#warning TODO: do something in case the mosaic images couldn't be saved to file
    }
}

//return the saved mosaic images from disk
-(NSArray*)savedMosaicImages
{
    //the array of images to be returned
    NSArray* images;
    
    //loading data from disk if it exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString* fullPath = [DIRECTORY_FOR_MOSAIC_IMAGES_FILE stringByAppendingPathComponent:filenameForMosaicImagesPlist];
    if ([fileManager fileExistsAtPath:fullPath])
    {
        NSData* data = [NSData dataWithContentsOfFile:fullPath];
        NSMutableDictionary* plist = [NSPropertyListSerialization propertyListFromData:data
                                                                      mutabilityOption:NSPropertyListImmutable
                                                                                format:NULL 
                                                                      errorDescription:NULL];
        images =[plist objectForKey:kImagesKey];
    }

    //file not found, just return an empty array
    else
    images = [[NSArray alloc] init];
    
    
    return [[images copy] autorelease];
}

#pragma mark - adding images to the mosaic view

-(void)drawSavedMosaicImages
{
    
#define PADDING_BOTTOM 5.0f
    
    //load the plist with the saved mosaic images in memory
    NSMutableArray* images = [[NSArray arrayWithArray:self.savedMosaicImages] mutableCopy];
    [images retain];
    
    //add the load more mosaic view to the image dictionary
    //TODO: define how to implement
#warning TODO!!!! define how to implement adding the load more mosaic view
    NSMutableDictionary* loadMoreMosaicDictionary = [[NSMutableDictionary alloc] init];
    [loadMoreMosaicDictionary setObject:[NSNumber numberWithFloat:100.0f] forKey:kImageWidth];
    [loadMoreMosaicDictionary setObject:[NSNumber numberWithFloat:180.0f] forKey:kImageHeight];
    [images addObject:loadMoreMosaicDictionary];
    [loadMoreMosaicDictionary release];
    
    
    //get active column
    const int numberOfColumns = 3;
    int columnHeights[numberOfColumns] = {0,0,0}; 
    int smallestColumn = 0;
    int imageCounter = [images count];
    
    for (NSDictionary* oneImageDictionary in images) 
    {
        //getting image properties
        NSNumber* imageWidthNumber = [oneImageDictionary objectForKey:kImageWidth];
        NSNumber* imageHeightNumber = [oneImageDictionary objectForKey:kImageHeight];
        
        
        CGFloat imageWidth = [imageWidthNumber floatValue];
        CGFloat imageHeight = [imageHeightNumber floatValue];
        
#warning THIS IS just temporary
        NSString* imageFilename = [oneImageDictionary objectForKey:kImageFilename];;
        UIImage* currentImageFromBundle = [UIImage imageNamed:imageFilename];
        UIImage *scaledImage = [UIImage imageWithCGImage:[currentImageFromBundle CGImage] scale:0.5 orientation:UIImageOrientationUp];
        [scaledImage retain];
        
        
        //calculate the column with the smallest height
        int smallestHeight = 0, i = 0;        
        smallestColumn = 0;
        smallestHeight = columnHeights[0];
        
        for (; i<numberOfColumns; i++) {
            if (columnHeights[i] < smallestHeight) {
                smallestHeight = columnHeights[i];
                smallestColumn=i;
            }
        }
        
        //define the active column as being the one with the smallest height
        int activeColumn = smallestColumn;
          
        //get active column values
        CGFloat xposForActiveColumn = [self xposForColumn:activeColumn];
        CGFloat heightOfActiveColumn = columnHeights[activeColumn];
        
        
        BOOL isColumnLoadMoreView = (imageCounter==1);
        
        if (isColumnLoadMoreView) 
        {
            //add a load more view to the scrollview
            CGPoint mosaicViewPoint = CGPointMake(xposForActiveColumn, heightOfActiveColumn+PADDING_BOTTOM);
            CGRect mosaicViewFrame = CGRectMake(mosaicViewPoint.x, mosaicViewPoint.y, imageWidth, imageHeight);
            LoadMoreMosaicView* oneView = [[LoadMoreMosaicView alloc] initWithFrame:mosaicViewFrame];
            oneView.userInteractionEnabled = YES;
            oneView.backgroundColor = [UIColor blackColor];
            oneView.alpha = 1.0f;
            
            UIButton *loadMoreMosaicButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            loadMoreMosaicButton.frame = CGRectMake(10, 10, 70, 70);
            [loadMoreMosaicButton addTarget:self action:@selector(loadMoreMosaicImages) forControlEvents:UIControlEventTouchDown];
            [oneView addSubview:loadMoreMosaicButton];
            
            [self.bigMosaikView addSubview:oneView];
        }
        else 
        {
#warning TODO: find better way to handle higher resolution of images
            imageWidth/=2;
            imageHeight/=2;
            
            
            //add a mosaic view to the scrollview
            CGPoint mosaicViewPoint = CGPointMake(xposForActiveColumn, heightOfActiveColumn+PADDING_BOTTOM);
            CGRect mosaicViewFrame = CGRectMake(mosaicViewPoint.x, mosaicViewPoint.y, imageWidth, imageHeight);
            MosaicView* oneView = [[MosaicView alloc] initWithFrame:mosaicViewFrame];
            oneView.backgroundColor = [self randomColor];
            oneView.alpha = 1.0f;
            
#warning THIS is just temporary
            UIImageView* tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
            tempImageView.image = scaledImage;
            [oneView addSubview:tempImageView];
            [tempImageView release];
            [currentImageFromBundle release];
            
            [scaledImage release];
            
            [self.bigMosaikView addSubview:oneView];
        }
        
        
        //add one of the columnHeights value to the relevant columnHeight
        columnHeights[activeColumn] += (imageHeight+PADDING_BOTTOM);
        
        
        imageCounter--;
    }
    
    //calculate the height of the largest column
    int largestHeight = 0, i = 0; 
    
    for (; i<numberOfColumns; i++) {
        if (columnHeights[i] > largestHeight) {
            largestHeight = columnHeights[i];
        }
    }
    CGFloat heightOfLargestColumn = (CGFloat)largestHeight;
    
    //resize content size of scrollview
    CGRect frameOfBigMosaicView = self.bigMosaikView.frame;
    self.bigMosaikView.frame = CGRectMake(frameOfBigMosaicView.origin.x, frameOfBigMosaicView.origin.y, frameOfBigMosaicView.size.width, heightOfLargestColumn);
      
}

#pragma mark - some help methods

-(CGFloat)xposForColumn:(int)column
{
#define PADDING_LEFT 5.0f
#define PADDING_RIGHT 5.0f
#define COLUMN_WIDTH 100.0f    
    
    CGFloat xpos = column*COLUMN_WIDTH + (column+1)*PADDING_LEFT;
    return xpos;
}

-(UIColor*)randomColor
{
    CGFloat redValue = (CGFloat)((rand()%255)/255.0f);
    CGFloat greenValue = (CGFloat)((rand()%255)/255.0f);
    CGFloat blueValue = (CGFloat)((rand()%255)/255.0f);
    CGFloat alpha = 0.5;
    
    UIColor *randColor = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:alpha];
    return randColor;    
}


#pragma mark - ASIHTTP request delegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    
    LOG_CURRENT_FUNCTION()
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    
    
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{    
    LOG_CURRENT_FUNCTION()
    
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mosaic_images" ofType:@"plist"];
    NSData* data = [NSData dataWithContentsOfFile:path];
    NSMutableDictionary* plist = [NSPropertyListSerialization propertyListFromData:data
                                                                  mutabilityOption:NSPropertyListImmutable
                                                                            format:NULL 
                                                                  errorDescription:NULL];
    NSArray* images = [plist objectForKey:kImagesKey];
    
    [self addMoreMosaicImages:[[images copy] autorelease]];
    
    
    [self.bigMosaikView setNeedsDisplay];
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    
    LOG_CURRENT_FUNCTION()
    
#warning TODO: do something if the request failed!
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}



@end
