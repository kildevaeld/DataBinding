//
//  FAMapperPropertyFinder.h
//  FAMapper
//
//  Created by Rasmus Kildevaeld on 23/11/13.
//  Copyright (c) 2013 Rasmus Kildevaeld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>




@interface FAPropertyFinder : NSObject

+ (BOOL)hasProperty:(NSString *)property onClass:(Class)klass;

+ (Class)propertyType:(NSString*)property onClass:(Class)klass;

@end
