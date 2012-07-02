//
//  MoreCell.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 27.06.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const kMoreCellHeight;

@interface MoreCell : UITableViewCell

-(void)configureWithTitle:(NSString*)title
                    image:(UIImage*)image;
@end
