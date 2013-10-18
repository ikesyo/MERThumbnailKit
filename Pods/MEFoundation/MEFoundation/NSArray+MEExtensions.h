//
//  NSArray+MEExtensions.h
//  MEFrameworks
//
//  Created by Joshua Kovach on 4/19/12.
//  Copyright (c) 2013 Maestro. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>

@interface NSArray (MEExtensions)

/**
 Returns the first object in the receiver, or nil if the receiver is empty
 
 @return The first object in the receiver, equivalent to [self objectAtIndex:0], or nil if the self.count == 0
 */
- (id)ME_firstObject;

/**
 Returns an array of objects containing the objects returned by performing the given selector on each item in the receiving array. Similar to Ruby's #map method block.
 
 @param selector The selector to perform on each object in the array
 @exception NSException Thrown if _selector_ returns nil for any object in the receiver
 @return An array of elements parallel to the receiving array
 */
- (NSArray *)ME_arrayByPerformingSelector:(SEL)selector;

/**
 Enumerates the receiver and calls the block once for each object with the object as its argument.
 
 @param performBlock The block that is invoked for each object in the receiver, passing the object and its index in the receiver as the two arguments
 */
- (void)ME_forEach:(void (^)(id object, NSUInteger index))performBlock;

/**
 Enumerates the receiver and calls the _mapBlock_ once for each object, passing the object as the argument to the block. Accumulates the results in another array and returns them.
 
 @param mapBlock The block that will be invoked for each object in the receiver, passing the object and its index in the receiver as the two arguments
 @return The array tha results from applying _mapBlock_ to each object in the receiver
 */
- (NSArray *)ME_map:(id (^)(id object, NSUInteger index))mapBlock;

/**
 Tests each object in the receiver and returns all the elements that satisfy the _predicate_ block.
 
 @param predicate The block that will be invoked for each object in the receiver, passing the object as its argument and returning YES/NO indicating whether the object should be returned as part of the result
 @return The array of all objects in the receiver that pass the _predicate_ block
 */
- (NSArray *)ME_filter:(BOOL (^)(id obj))predicate;

/**
 Find and return the first object in the receiver satisfying the predicate, nil otherwise.
 
 @param object The object being sought
 @param predicate The block that is invoked for each object in the receiver, or until _predicate_ returns YES
 @return The first object satisfying _predicate_, nil otherwise
 */
- (id)ME_findFirst:(id)object matching:(BOOL (^)(id obj1, id obj2))predicate;

/**
 Returns a portion(slice) of the array starting at a given starting element and having a specified length. if the start is past the end of the array, nil is returned. if the length exceeds the length of the array, the array from start to end is returned.
 
 @warning *NOTE:* The slice contains objects from the receiver, it does not copy them.
 @param start The starting index from which to begin the slice (inclusive)
 @param length The length of the slice
 @return The slice of the receiver start at _start_ inclusive and containing at most _length_ objects
 */
- (NSArray *)ME_sliceAt:(NSUInteger)start length:(NSUInteger)length;

/**
 Creates and returns a set from the receiver's objects.
 
 @return The set created from the receiver's objects
 */
- (NSSet *)ME_set;

/**
 Creates and returns a mutable set from the receiver's objects.
 
 @return The mutable set created from the receiver's objects
 */
- (NSMutableSet *)ME_mutableSet;

@end

@interface NSMutableArray (MEExtensions)

/**
 Removes the first object in the receiver, or does nothing if the receiver is empty.
 
 Equivalent to calling [self removeObjectAtIndex:0]
 
 */
- (void)ME_removeFirstObject;

/**
 Pushes the object onto the receiver at index 0.
 
 Equivalent to calling [self insertObject:object atIndex:0]
 
 @param object The object to push
 @exception NSException Thrown if object is nil
 */
- (void)ME_push:(id)object;

/**
 Calls [self ME_removeFirstObject]
 */
- (void)ME_pop;

/**
 Shuffles the receiver.
 */
- (void)ME_shuffle;

@end
