//
//  NSDate+MEExtensions.h
//  MEFrameworks
//
//  Created by Joshua Kovach on 4/27/12.
//  Copyright (c) 2012 Maestro. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>

static const NSTimeInterval METimeIntervalOneMinute = 60;
static const NSTimeInterval METimeIntervalOneHour   = 3600;
static const NSTimeInterval METimeIntervalOneDay    = 86400;
static const NSTimeInterval METimeIntervalOneWeek   = 604800;

@interface NSDate (MEExtensions)

/**
 Returns a Boolean value that indicates whether the receiver date occurs before the given NSDate object.

 @param otherDate - The date to compare with the receiver
 @return YES if the receiver is an NSDate object that occurs before otherDate, otherwise NO.
 @see ME_isAfterDate:
 */

- (BOOL)ME_isBeforeDate:(NSDate *)otherDate;

/**
 Returns a Boolean value that indicates whether the receiver date occurs after the given NSDate object.
 
 @param otherDate - The date to compare with the receiver
 @return YES if the receiver is an NSDate object that occurs after otherDate, otherwise NO.
 @see ME_isBeforeDate:
 */
- (BOOL)ME_isAfterDate:(NSDate *)otherDate;

/**
 Returns an NSDateComponents instance created using the current calendar
 
 This is a shortcut method to convert a date or time interval to its calendar or clock components without having to know you need the calendar.
 
 @param a mask of NSCalendarUnit values you want available, e.g. (NSHourCalendarUnit | NSMinuteCalendarUnit)
 @param the date being counted toward
 @return The NSDateComponent instance containing the requested component units
 @see ME_components:fromDate:
 */
- (NSDateComponents *)ME_components:(NSUInteger)unitFlags toDate:(NSDate *)toDate;

/**
 Returns an NSDateComponents instance created using the current calendar
 
 This is a shortcut method to convert a date or time interval to its calendar or
 clock components without having to know you need the calendar.
 
 @param a mask of NSCalendarUnit values you want available, e.g. (NSHourCalendarUnit | NSMinuteCalendarUnit)
 @param the date being counted from
 @return The NSDateComponent instance containing the requested component units
 @see ME_components:toDate:
 */
- (NSDateComponents *)ME_components:(NSUInteger)unitFlags fromDate:(NSDate *)fromDate;

@end
