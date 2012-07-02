//
//  CategoryCell.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 28.06.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>


extern CGFloat const kCategoryCellHeight;

@interface CategoryCell : UITableViewCell

-(void)configureWithTitle:(NSString*)title;

@end
