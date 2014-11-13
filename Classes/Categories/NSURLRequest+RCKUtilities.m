// NSURLRequest+RCKUtilities.m
//
// RCKVKAppTweak
//
// Copyright (c) 2014 rock88
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "NSURLRequest+RCKUtilities.h"

NSString* const RCKAudioGetURLString = @"https://api.vk.com/method/audio.get";
NSString* const RCKAudioGetByIdURLString = @"https://api.vk.com/method/audio.getById";

@implementation NSURLRequest (RCKUtilities)

- (BOOL)isAudioGetRequest
{
    return [self.URL.absoluteString isEqualToString:RCKAudioGetURLString];
}

- (BOOL)isAudioGetByIdRequest
{
    return [self.URL.absoluteString isEqualToString:RCKAudioGetByIdURLString];
}

- (NSString *)audioId
{
    NSArray* params = [[NSString stringWithCString:(const char*)self.HTTPBody.bytes encoding:NSStringEncodingConversionAllowLossy] componentsSeparatedByString:@"&"];
    for (NSString* param in params)
    {
        NSArray* items = [param componentsSeparatedByString:@"="];
        if (items.count == 2 && [items[0] isEqualToString:@"audios"])
        {
            return items[1];
        }
    }
    return nil;
}

@end
