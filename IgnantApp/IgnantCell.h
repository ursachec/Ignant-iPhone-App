//
//  IgnantCell.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 12/23/11.
//  Copyright (c) 2011 Cortado AG. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface IgnantCell : UITableViewCell
{
    UIImage *thumbImage;
    NSString *title;
    NSString *categoryName;
    NSString *dateString;
}

@property(nonatomic,strong) UIView *cellContentView;
@property(nonatomic,strong) UIImageView *cellImageView;

@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *categoryName;
@property(nonatomic,strong) NSString *dateString;

@end
