//
//  NSArray+MEExtensions.m
//  MEFrameworks
//
//  Created by Joshua Kovach on 4/19/12.
//  Copyright (c) 2012 Maestro. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSArray+MEExtensions.h"

#if !__has_feature(objc_arc)
#error This file requires ARC
#endif

@implementation NSArray (MEExtensions)

- (id)ME_firstObject; {
    if ([self respondsToSelector:@selector(firstObject)])
        return [(id)self firstObject];
    else if (self.count == 0)
        return nil;
    else
        return [self objectAtIndex:0];
}

- (NSArray *)ME_arrayByPerformingSelector:(SEL)selector {
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:self.count];
    for (id object in self) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"        
        id result = [object performSelector:selector];
#pragma clang diagnostic pop            
        [results addObject:result];
    }
    return results;
}

- (void)ME_forEach:(void (^)(id object, NSUInteger index))performBlock; {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        performBlock(obj,idx);
    }];
}

- (NSArray *)ME_map:(id (^)(id object, NSUInteger index))mapBlock; {
    NSMutableArray *retval = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [retval addObject:mapBlock(obj,idx)];
    }];
    
    return retval;
}

- (NSArray *)ME_filter:(BOOL (^)(id obj))predicate 
{    
    NSMutableArray *newArr = [NSMutableArray arrayWithCapacity:0];
    for (id item in self) {
        if (predicate(item)) {
            [newArr addObject:item];
        }
    }
    return newArr;
}

- (id)ME_findFirst:(id)object matching:(BOOL (^)(id obj1, id obj2))predicate
{
    for (id o in self) {
        if (predicate(object, o))
            return o;
    }
    return nil;
}

- (NSArray *)ME_sliceAt:(NSUInteger)start length:(NSUInteger)length
{
    NSUInteger end = [self count] - 1;
    if (start > end) return nil;
    NSUInteger maxLen = (MIN(length, end - start + 1));
    NSRange range = NSMakeRange(start, maxLen);
    return [self subarrayWithRange:range];
}

- (NSSet *)ME_set; {
    return [NSSet setWithArray:self];
}
- (NSMutableSet *)ME_mutableSet; {
    return [NSMutableSet setWithArray:self];
}

@end

@implementation NSMutableArray (MEExtensions)

- (void)ME_removeFirstObject; {
    if (self.count > 0)
        [self removeObjectAtIndex:0];
}

- (void)ME_push:(id)object {
    [self insertObject:object atIndex:0];
}

- (void)ME_pop {
    [self ME_removeFirstObject];
}

// Code blantantly stolen from http://stackoverflow.com/questions/56648/whats-the-best-way-to-shuffle-an-nsmutablearray
- (void)ME_shuffle; {
    for (NSUInteger i=0; i<self.count; i++) {
        NSInteger nElements = self.count - i;
        NSInteger n = (arc4random() % nElements) + i;
        
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
