//
//  IgnantCell.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 12/23/11.
//  Copyright (c) 2011 Cortado AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJManagedImageV.h"

@interface IgnantCell : UITableViewCell
{
    
    UIImage *thumbImage;
    NSString *title;
    NSString *categoryName;
    NSString *dateString;
    
    HJManagedImageV* managedImage;
    
    NSString* imageIdentifier;
}
@property(nonatomic,strong) UIView *cellContentView;

@property(nonatomic,strong) UIImage *thumbImage;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *categoryName;
@property(nonatomic,strong) NSString *dateString;

@property (nonatomic,strong) HJManagedImageV* managedImage;

@property(nonatomic,strong) NSString* imageIdentifier;

@end
