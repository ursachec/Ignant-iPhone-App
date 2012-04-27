//
//  IGNMosaikViewController.m
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 03.02.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//


#import "IGNMosaikViewController.h"

#import "LoadMoreMosaicView.h"

NSString * const kImagesKey = @"images";

NSString * const kImageWidth = @"width";
NSString * const kImageHeight = @"height";
NSString * const kImageUrl = @"url";
NSString * const kImageArticleId = @"articleId";
NSString * const kImageFilename = @"filename";


@interface IGNMosaikViewController ()
{

}


@property(nonatomic,retain) NSArray* savedMosaicImages;

-(void)drawSavedMosaicImages;

-(UIColor*)randomColor;

-(void)addMoreMosaicImages:(NSArray*)mosaicImages;

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
    // Do any additional setup after loading the view from its nib.
    
    
    //add the back-to-start button
    UIImage *backButtonImage = [UIImage imageNamed:@"backButton.png"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat ratio = .65;
    backButton.frame = CGRectMake(0, 0, 46*ratio, 30*ratio);
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(handleBack:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    
    //add the close button to the view
    
    
    [self drawSavedMosaicImages];
    
    
    //resize the scrollview to fit the content properly
    CGRect bigMosaikViewRect = CGRectMake(0, 0, self.bigMosaikView.frame.size.width, self.bigMosaikView.frame.size.height);
    self.bigMosaikView.frame = bigMosaikViewRect;
    // add the big mosaik view to the content scrollview
    [self.mosaikScrollView setContentSize:bigMosaikViewRect.size];
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
    
    
    
    
    
    
    
}


#pragma mark - client-side loading / saving of the mosaic images
-(void)addMoreMosaicImages:(NSArray*)mosaicImages
{
    //first retrieve the currently saved mosaic images as a mutable copy
    NSArray* currentlySavedMosaicImages = [self.savedMosaicImages copy];
    
    //then add the mosaicImages parameter to the currently saved ones
    NSArray* newArrayOfSavedMosaicImages = [currentlySavedMosaicImages arrayByAddingObjectsFromArray:currentlySavedMosaicImages];
    
    //set the merged array to be the new mosaic images array
    self.savedMosaicImages = [newArrayOfSavedMosaicImages copy];
}

//return the saved mosaic images
-(NSArray*)savedMosaicImages
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mosaic_images" ofType:@"plist"];
    NSData* data = [NSData dataWithContentsOfFile:path];
    NSMutableDictionary* plist = [NSPropertyListSerialization propertyListFromData:data
                                                                  mutabilityOption:NSPropertyListImmutable
                                                                            format:NULL 
                                                                  errorDescription:NULL];
    NSArray* images =[plist objectForKey:kImagesKey];
    return [[images copy] autorelease];
}

#pragma mark - adding images to the mosaic view

-(void)drawSavedMosaicImages
{
    
#define PADDING_BOTTOM 5.0f
    
    //load the plist with the saved mosaic images in memory
    NSArray* images = [NSArray arrayWithArray:self.savedMosaicImages];
    [images retain];
    
    //add the load more mosaic view to the image dictionary
    //TODO: define how to implement
#warning TODO!!!! define how to implement adding the load more mosaic view
    
    
    //get active column
    const int numberOfColumns = 3;
    int columnHeights[numberOfColumns] = {0,0,0}; 
    int smallestColumn = 0;
    
    for (NSDictionary* oneImageDictionary in images) 
    {
        //getting image properties
        NSNumber* imageWidthNumber = [oneImageDictionary objectForKey:kImageWidth];
        NSNumber* imageHeightNumber = [oneImageDictionary objectForKey:kImageHeight];
        
        CGFloat imageWidth = [imageWidthNumber floatValue];
        CGFloat imageHeight = [imageHeightNumber floatValue];
        
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
        
        //add a mosaic view to the scrollview
        CGPoint mosaicViewPoint = CGPointMake(xposForActiveColumn, heightOfActiveColumn+PADDING_BOTTOM);
        CGRect mosaicViewFrame = CGRectMake(mosaicViewPoint.x, mosaicViewPoint.y, imageWidth, imageHeight);
        UIView* oneView = [[UIView alloc] initWithFrame:mosaicViewFrame];
        oneView.backgroundColor = [self randomColor];
        oneView.alpha = 0.3f;
        [self.bigMosaikView addSubview:oneView];
        
        //add one of the columnHeights value to the relevant columnHeight
        columnHeights[activeColumn] += (imageHeight+PADDING_BOTTOM);
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
    
    
    
    [images release];


    
}

#pragma mark - some help methods

-(CGFloat)xposForColumn:(int)column
{
#define PADDING_LEFT 5.0f
#define PADDING_RIGHT 5.0f
#define COLUMN_WIDTH 100.0f    
    
    CGFloat xpos = 0.0f;
    if (column==1) 
    {
        xpos = COLUMN_WIDTH+PADDING_LEFT;
    }
    else if (column==2) 
    {
        xpos = 2*(COLUMN_WIDTH+PADDING_LEFT);
    }
    else if (column==3) 
    {
        xpos = 3*(COLUMN_WIDTH+PADDING_LEFT);
    }
    
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


@end
