//
//  NSData+MEExtensions.h
//  MEFrameworks
//
//  Created by William Towe on 9/11/12.
//  Copyright (c) 2012 Maestro. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>

@interface NSData (MEExtensions)

/**
 Returns the MD5 hash of the receiver's bytes
 
 @return An NSString representation of the MD5 hash
 */
- (NSString *)ME_MD5String;
/**
 Returns the SHA1 hash of the receiver's bytes
 
 @return An NSString representation of the SHA1 hash
 */
- (NSString *)ME_SHA1String;
/**
 Returns the SHA512 hash of the receiver's bytes.
 
 @return An NSString representation of the SHA512 hash
 */
- (NSString *)ME_SHA512String;

/**
 Returns an NSData instance created from a base 64 encoded string
 
 You would presumably use `ME_Base64EncodedString` to generate the string
 
 @param string The base 64 encoded string representation of bytes
 @return The NSData instance
 @see ME_Base64EncodedString
 */
+ (NSData *)ME_dataFromBase64EncodedString:(NSString *)string;
/**
 Returns a base 64 encoded string representation of the receiver's bytes
 
 @return An NSString representation of the receiver's bytes using base 64 encoding
 */
- (NSString *)ME_base64EncodedString;

/**
 An asynchronous version of `writeToURL:options:error:`.
 
 @param url The location to which to write the receiver's bytes
 @param mask A mask that specifies options for writing the data
 @param completion The completion block that is invoked when the operation completes
 */
+ (void)ME_writeData:(NSData *)data toURL:(NSURL *)url options:(NSDataWritingOptions)options completion:(void (^)(BOOL success,NSError *error))completion;
- (void)ME_writeToURL:(NSURL *)url options:(NSDataWritingOptions)options completion:(void (^)(BOOL success,NSError *error))completion;

@end
