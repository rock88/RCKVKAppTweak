// RCKErrorManager.m
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

#import "RCKErrorManager.h"
#import "RCKCoreDataManager.h"
#import "RCKError.h"

@implementation RCKErrorManager

+ (instancetype)sharedInstance
{
    static RCKErrorManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)handleErrorWithString:(NSString *)errorStr
{
    NSLog(@"RCKErrorManager::Error - %@",errorStr);
    
    RCKError* entity = [[RCKCoreDataManager sharedInstance] newObjectForEntityForName:NSStringFromClass([RCKError class])];
    entity.date = [NSDate date];
    entity.text = errorStr;
    [[RCKCoreDataManager sharedInstance] saveContext];
}

- (void)handleError:(NSError *)error
{
    if (error)
    {
        [self handleErrorWithString:error.localizedDescription];
    }
}

- (NSArray *)errors
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([RCKError class])];
    return [[RCKCoreDataManager sharedInstance] executeFetchRequest:request error:nil];
}

@end
