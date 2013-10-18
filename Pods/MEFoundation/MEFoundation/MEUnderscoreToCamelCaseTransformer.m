//
//  MEUnderscoreToCamelCaseTransformer.m
//  MEEventKit
//
//  Created by William Towe on 3/26/13.
//  Copyright (c) 2013 Maestro. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "MEUnderscoreToCamelCaseTransformer.h"

@implementation MEUnderscoreToCamelCaseTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}
+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        NSString *normalize = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSMutableString *retval = [NSMutableString stringWithCapacity:normalize.length];
        
        [[normalize componentsSeparatedByString:@"_"] enumerateObjectsUsingBlock:^(NSString *fragment, NSUInteger fragmentIndex, BOOL *stop) {
            if (fragmentIndex == 0)
                [retval appendString:fragment];
            else
                [retval appendString:fragment.capitalizedString];
        }];
        
        return [retval copy];
    }
    return nil;
}
- (id)reverseTransformedValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        NSString *normalize = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSMutableString *retval = [NSMutableString stringWithCapacity:normalize.length];
        
        [[normalize componentsSeparatedByCharactersInSet:[NSCharacterSet uppercaseLetterCharacterSet]] enumerateObjectsUsingBlock:^(NSString *fragment, NSUInteger idx, BOOL *stop) {
            if (idx == 0)
                [retval appendString:fragment.lowercaseString];
            else
                [retval appendString:[fragment.lowercaseString stringByAppendingString:@"_"]];
        }];
        
        return [retval copy];
    }
    return nil;
}

@end
