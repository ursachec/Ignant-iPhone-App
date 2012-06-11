//
//  Category.h
//  IgnantApp
//
//  Created by Claudiu-Vlad Ursache on 06.03.12.
//  Copyright (c) 2012 c.v.ursache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BlogEntry;

@interface Category : NSManagedObject

@property (nonatomic, strong) NSString * categoryDescription;
@property (nonatomic, strong) NSString * categoryId;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSSet *entries;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(BlogEntry *)value;
- (void)removeEntriesObject:(BlogEntry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
