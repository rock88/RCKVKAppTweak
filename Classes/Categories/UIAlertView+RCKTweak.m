// UIAlertView+RCKTweak.m
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

#import "UIAlertView+RCKTweak.h"
#import <objc/runtime.h>

@interface UIAlertView () <UIAlertViewDelegate>

@property (nonatomic,copy) void(^RCKblock)(NSUInteger buttonIndex);

@end

@implementation UIAlertView (RCKTweak)

#pragma mark -
#pragma mark Setter/Getter for RCKblock

- (void)setRCKblock:(void (^)(NSUInteger))RCKblock
{
    objc_setAssociatedObject(self, @selector(RCKblock), RCKblock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(NSUInteger))RCKblock
{
    return objc_getAssociatedObject(self, @selector(RCKblock));
}

#pragma mark -
#pragma mark Show

- (void)showWithBlock:(void(^)(NSUInteger buttonIndex))block
{
    self.RCKblock = block;
    
    __weak __typeof(self) weakSelf = self;
    self.delegate = weakSelf;
    
    [self show];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.RCKblock)
    {
        self.RCKblock(buttonIndex);
        self.RCKblock = nil;
    }
}

@end
