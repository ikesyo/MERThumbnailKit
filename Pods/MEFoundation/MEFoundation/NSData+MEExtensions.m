//
//  NSData+MEExtensions.m
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

#import "NSData+MEExtensions.h"
#import "MEFunctions.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSData (MEExtensions)

- (NSString *)ME_MD5String; {
    unsigned char buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(self.bytes, self.length, buffer);
    
    NSMutableString *retval = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++)
        [retval appendFormat:@"%02x",buffer[i]];
    
    return retval;
}
- (NSString *)ME_SHA1String; {
    unsigned char buffer[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(self.bytes, self.length, buffer);
    
    NSMutableString *retval = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i=0; i<CC_SHA1_DIGEST_LENGTH; i++)
        [retval appendFormat:@"%02x",buffer[i]];
    
    return retval;
}
- (NSString *)ME_SHA512String; {
    unsigned char buffer[CC_SHA512_DIGEST_LENGTH];
    
    CC_SHA512(self.bytes, self.length, buffer);
    
    NSMutableString *retval = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    
    for (int i=0; i<CC_SHA512_DIGEST_LENGTH; i++)
        [retval appendFormat:@"%02x",buffer[i]];
    
    return retval;
}

/*
 This code was (mostly) copied verbatim from the following post http://www.cocoawithlove.com/2009/06/base64-encoding-options-on-mac-and.html
 I modified the style to suit my own and the variable/method names to match those found throughout MEExtensions. The original license is included below.
 */

//
//  NSData+Base64.m
//  base64
//
//  Created by Matt Gallagher on 2009/06/03.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//
static unsigned char kBase64EncodeLookup[65] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

#define xx 65
static unsigned char kBase64DecodeLookup[256] = {
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 62, xx, xx, xx, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, xx, xx, xx, xx, xx, xx,
    xx,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, xx, xx, xx, xx, xx,
    xx, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
};

#define BINARY_UNIT_SIZE 3
#define BASE64_UNIT_SIZE 4

static void *ME_NewBase64Decode(const char *inputBuffer,size_t length,size_t *outputLength) {
	if (length == -1)
		length = strlen(inputBuffer);
	
	size_t outputBufferSize = ((length+BASE64_UNIT_SIZE-1) / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE;
	unsigned char *outputBuffer = (unsigned char *)malloc(outputBufferSize);
	
	size_t i = 0;
	size_t j = 0;
    
	while (i < length) {
		unsigned char accumulated[BASE64_UNIT_SIZE];
		size_t accumulateIndex = 0;
		while (i < length) {
			unsigned char decode = kBase64DecodeLookup[inputBuffer[i++]];
			if (decode != xx) {
				accumulated[accumulateIndex] = decode;
				accumulateIndex++;
				
				if (accumulateIndex == BASE64_UNIT_SIZE)
					break;
			}
		}
		
		if(accumulateIndex >= 2)
			outputBuffer[j] = (accumulated[0] << 2) | (accumulated[1] >> 4);
		if(accumulateIndex >= 3)
			outputBuffer[j + 1] = (accumulated[1] << 4) | (accumulated[2] >> 2);
		if(accumulateIndex >= 4)
			outputBuffer[j + 2] = (accumulated[2] << 6) | accumulated[3];
        
		j += accumulateIndex - 1;
	}
	
	if (outputLength)
		*outputLength = j;
    
	return outputBuffer;
}

#define MAX_NUM_PADDING_CHARS 2
#define OUTPUT_LINE_LENGTH 64
#define INPUT_LINE_LENGTH ((OUTPUT_LINE_LENGTH / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE)
#define CR_LF_SIZE 2

static char *ME_NewBase64Encode(const void *buffer,size_t length,BOOL separateLines,size_t *outputLength) {
	const unsigned char *inputBuffer = (const unsigned char *)buffer;
    
	size_t outputBufferSize = ((length / BINARY_UNIT_SIZE) + ((length % BINARY_UNIT_SIZE) ? 1 : 0)) * BASE64_UNIT_SIZE;
    
	if (separateLines)
		outputBufferSize += (outputBufferSize / OUTPUT_LINE_LENGTH) * CR_LF_SIZE;
	
	outputBufferSize += 1;
    
	char *outputBuffer = (char *)malloc(outputBufferSize);
    
	if (!outputBuffer)
		return NULL;
    
	size_t i = 0;
	size_t j = 0;
	const size_t lineLength = separateLines ? INPUT_LINE_LENGTH : length;
	size_t lineEnd = lineLength;
	
	for (;;) {
        if (lineEnd > length)
			lineEnd = length;
        
		for (; i + BINARY_UNIT_SIZE - 1 < lineEnd; i += BINARY_UNIT_SIZE) {
			outputBuffer[j++] = kBase64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
			outputBuffer[j++] = kBase64EncodeLookup[((inputBuffer[i] & 0x03) << 4) | ((inputBuffer[i + 1] & 0xF0) >> 4)];
			outputBuffer[j++] = kBase64EncodeLookup[((inputBuffer[i + 1] & 0x0F) << 2) | ((inputBuffer[i + 2] & 0xC0) >> 6)];
			outputBuffer[j++] = kBase64EncodeLookup[inputBuffer[i + 2] & 0x3F];
		}
		
		if (lineEnd == length)
			break;
		
		outputBuffer[j++] = '\r';
		outputBuffer[j++] = '\n';
		lineEnd += lineLength;
    }
	
	if (i + 1 < length) {
		outputBuffer[j++] = kBase64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
		outputBuffer[j++] = kBase64EncodeLookup[((inputBuffer[i] & 0x03) << 4) | ((inputBuffer[i + 1] & 0xF0) >> 4)];
		outputBuffer[j++] = kBase64EncodeLookup[(inputBuffer[i + 1] & 0x0F) << 2];
		outputBuffer[j++] =	'=';
	}
	else if (i < length) {
		outputBuffer[j++] = kBase64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
		outputBuffer[j++] = kBase64EncodeLookup[(inputBuffer[i] & 0x03) << 4];
		outputBuffer[j++] = '=';
		outputBuffer[j++] = '=';
	}
    
	outputBuffer[j] = 0;
	
	if (outputLength)
		*outputLength = j;

	return outputBuffer;
}

+ (NSData *)ME_dataFromBase64EncodedString:(NSString *)string; {
    NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding];
    
    size_t outputLength;
    void *outputBuffer = ME_NewBase64Decode(data.bytes, data.length, &outputLength);
    NSData *retval = [self dataWithBytesNoCopy:outputBuffer length:outputLength freeWhenDone:YES];
    
    return retval;
}
- (NSString *)ME_base64EncodedString; {
    size_t outputLength;
    char *outputBuffer = ME_NewBase64Encode(self.bytes, self.length, YES, &outputLength);
    NSString *retval = [[NSString alloc] initWithBytesNoCopy:outputBuffer length:outputLength encoding:NSASCIIStringEncoding freeWhenDone:YES];
    
    return retval;
}

+ (void)ME_writeData:(NSData *)data toURL:(NSURL *)url options:(NSDataWritingOptions)options completion:(void (^)(BOOL success,NSError *error))completion; {
    MEDispatchBackgroundAsync(^{
        NSError *outError;
        
        if ([data writeToURL:url options:options error:&outError]) {
            if (completion) {
                MEDispatchMainAsync(^{
                    completion(YES,nil);
                });
            }
        }
        else {
            if (completion) {
                MEDispatchMainAsync(^{
                    completion(NO,outError);
                });
            }
        }
    });
}
- (void)ME_writeToURL:(NSURL *)url options:(NSDataWritingOptions)options completion:(void (^)(BOOL success,NSError *error))completion; {
    [self.class ME_writeData:self toURL:url options:options completion:completion];
}

@end
