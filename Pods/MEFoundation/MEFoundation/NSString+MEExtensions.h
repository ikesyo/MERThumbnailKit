//
//  NSString+MEExtensions.h
//  MEFrameworks
//
//  Created by William Towe on 4/23/12.
//  Copyright (c) 2012 Maestro. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>

@interface NSString (MEExtensions)

/*******************************************************************************
 Description:
    Returns a string that is the result of removing all newline characters (i.e. '\n') and
 replacing them with replaceString.
 
 Args:
    NSString *replaceString
        the string you want to replace any newline characters that are found in the receiver
 
 Return:
    an autoreleased string
 */
- (NSString *)ME_stringByReplacingNewlinesWithString:(NSString *)replaceString;

/*******************************************************************************
 Description:
    Returns a copy of the receiver in reverse order (e.g. 'abcd' returns 'dcba')
 
 Args: None
 
 Return:
    an autoreleased reversed copy of the receiver
 */
- (NSString *)ME_reverseString;

/*******************************************************************************
 Description:
 Returns a URL encoded (percent encoded) string based on Dave DeLong's method at (http://stackoverflow.com/questions/3423545/objective-c-iphone-percent-encode-a-string/3426140#3426140) but changed handling of space char as %20 instead of +
 
 Args: None
 
 Return:
 an autoreleased reversed string
 */
- (NSString *)ME_URLEncodedString;

/*******************************************************************************
 Description:
    Returns the result of calling NSLocalizedString(self,@"")
 
 Args: None
 
 Return:
    an autoreleased string
 */
- (NSString *)ME_localizedString;

/*******************************************************************************
 Description:
    Returns a string representation of a CFUUIDRef
 
 Args: None
 
 Return:
    an autoreleased string representation of a CFUUIDRef
 */
+ (NSString *)ME_UUIDString;

@end

@interface NSString (MEHashing)
/**
 Returns the MD5 hash of the receiver
 
 @return An NSString representation of the MD5 hash
 */
- (NSString *)ME_MD5String;
/**
 Returns the SHA1 hash of the receiver
 
 @return An NSString representation of the SHA1 hash
 */
- (NSString *)ME_SHA1String;
@end

@interface NSString (MENumberConversion)

/*******************************************************************************
 Description:
    Returns the numerical value of the receiver, assuming base 16
 
 Args: None
 
 Return:
    an NSUInteger representing the numerical value of the receiver
 */
- (NSUInteger)ME_valueFromHexadecimalString;

/*******************************************************************************
 Description:
    Returns the numerical value of the receiver, assuming base 2
 
 Args: None
 
 Return:
    an NSUInteger representing the numerical value of the receiver
 */
- (NSUInteger)ME_valueFromBinaryString;

/*******************************************************************************
 Description:
    Returns the numerical value of the receiver, assuming base 10
    Behaves unpredictably beyond NSUInteger max value 4,294,967,295
 
 Args: None
 
 Return:
    an NSUInteger representing the numerical value of the receiver
 */
- (NSUInteger)ME_valueFromString;

/*******************************************************************************
 Description:
    Returns a string that is the result of removing all non-hex digits from the receiver
 
 Args: None
 
 Return:
    an autoreleased string
 */
- (NSString *)ME_stringByRemovingInvalidHexadecimalDigits;

/*******************************************************************************
 Description:
    Returns a string that is the result of removing all non-binary digits from the receiver
 
 Args: None
 
 Return:
    an autoreleased string
 */
- (NSString *)ME_stringByRemovingInvalidBinaryDigits;

/*******************************************************************************
 Description:
    Returns a string that is the result of removing all non-digit characters from the receiver
 
 Args: None
 
 Return:
    an autoreleased string
 */
- (NSString *)ME_stringByRemovingInvalidDigits;

/**
 Returns the value of the receiver as a long long (int64_t).
 */
- (int64_t)ME_longLongValue;
@end
