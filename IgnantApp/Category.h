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

@property (nonatomic, retain) NSString * categoryDescription;
@property (nonatomic, retain) NSString * categoryId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *entries;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(BlogEntry *)value;
- (void)removeEntriesObject:(BlogEntry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
