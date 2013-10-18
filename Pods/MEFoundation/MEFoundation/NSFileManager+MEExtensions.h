//
//  NSFileManager+MEExtensions.h
//  MEFrameworks
//
//  Created by William Towe on 4/19/13.
//  Copyright (c) 2013 Maestro. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>

@interface NSFileManager (MEExtensions)

@property (readonly,nonatomic) NSURL *ME_applicationSupportDirectoryURL;

/**
 An asynchronous version of createFileAtPath:contents:attributes:
 
 @param path The path at which to create the file
 @param contents The contents of the file
 @param attributes The attributes of the created file
 @param completion A completion block that is invoked when the operation completes
 @exception Thrown if _path_ or _contents_ are nil
 */
- (void)ME_createFileAtPath:(NSString *)path contents:(NSData *)contents attributes:(NSDictionary *)attributes completion:(void (^)(BOOL success))completion;
/**
 An asynchronous version of `copyItemAtURL:toURL:error:`.
 
 @param srcURL The file URL that identifies the file you want to copy. The URL in this parameter must not be a file reference URL
 @param dstURL The URL at which to place the copy of srcURL. The URL in this parameter must not be a file reference URL and must include the name of the file in its new location
 @param completion The completion block that is invoked when the operation completes
 @exception NSException Thrown if _srcURL_ or _dstURL_ are `nil`
 */
- (void)ME_copyItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL completion:(void (^)(BOOL success,NSError *error))completion;
/**
 An asynchronous version of `moveItemAtURL:toURL:error:`.
 
 @param srcURL The file URL that identifies the file or directory you want to move. The URL in this parameter must not be a file reference URL
 @param dstURL The new location for the item in srcURL. The URL in this parameter must not be a file reference URL and must include the name of the file or directory in its new location
 @param completion The completion that is invoked when the operation completes
 @exception NSException Thrown if _srcURL_ or _dstURL_ are `nil`
 */
- (void)ME_moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL completion:(void (^)(BOOL success,NSError *error))completion;

@end
