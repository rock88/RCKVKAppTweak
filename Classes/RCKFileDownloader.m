// RCKFileDownloader.m
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

#import "RCKFileDownloader.h"
#import <objc/runtime.h>

@interface NSURLSessionDownloadTask (RCKCustomHandlers)

@property (nonatomic,copy) void (^completionHandler)(NSURL *location, NSURLResponse *response, NSError *error);
@property (nonatomic,copy) void (^progressCallback)(CGFloat progress);

@end

@implementation NSURLSessionDownloadTask (RCKCustomHandlers)

+ (void)load
{
    Class class = NSClassFromString(@"__NSCFBackgroundDownloadTask");
    
    class_addMethod(class, @selector(setCompletionHandler:), method_getImplementation(class_getInstanceMethod(self, @selector(setCompletionHandler:))), "v");
    class_addMethod(class, @selector(completionHandler), method_getImplementation(class_getInstanceMethod(self, @selector(completionHandler))), "@?");
    class_addMethod(class, @selector(setProgressCallback:), method_getImplementation(class_getInstanceMethod(self, @selector(setProgressCallback:))), "v");
    class_addMethod(class, @selector(progressCallback), method_getImplementation(class_getInstanceMethod(self, @selector(progressCallback))), "@?");
}

- (void)setCompletionHandler:(void (^)(NSURL *, NSURLResponse *, NSError *))completionHandler
{
    objc_setAssociatedObject(self, @selector(completionHandler), completionHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(NSURL *, NSURLResponse *, NSError *))completionHandler
{
    return objc_getAssociatedObject(self, @selector(completionHandler));
}

- (void)setProgressCallback:(void (^)(CGFloat))progressCallback
{
    objc_setAssociatedObject(self, @selector(progressCallback), progressCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(CGFloat))progressCallback
{
    return objc_getAssociatedObject(self, @selector(progressCallback));
}

@end


@interface RCKFileDownloader () <NSURLSessionDelegate>

@property (nonatomic) NSURLSession* session;

@end

@implementation RCKFileDownloader

+ (instancetype)sharedInstance
{
    static RCKFileDownloader* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfiguration:@"RCKVKAppTweak"] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURL *location, NSURLResponse *response, NSError *error))completionHandler
{
    return [self.session downloadTaskWithRequest:request completionHandler:completionHandler];
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                    completionHandler:(void (^)(NSURL *location, NSURLResponse *response, NSError *error))completionHandler
                                     progressCallback:(void (^)(CGFloat progress))progressCallback
{
    NSURLSessionDownloadTask* task = [self.session downloadTaskWithRequest:request];
    task.completionHandler = completionHandler;
    task.progressCallback = progressCallback;
    return task;
}

#pragma mark -
#pragma mark NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionDownloadTask *)task didCompleteWithError:(NSError *)error
{
    if ([task isKindOfClass:[NSURLSessionDownloadTask class]])
    {
        if (task.completionHandler)
        {
            task.completionHandler(nil,task.response,error);
            task.completionHandler = nil;
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    if (downloadTask.completionHandler)
    {
        downloadTask.completionHandler(location,downloadTask.response,nil);
        downloadTask.completionHandler = nil;
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (downloadTask.progressCallback)
    {
        downloadTask.progressCallback((CGFloat)((double)totalBytesWritten / (double)totalBytesExpectedToWrite));
    }
}

@end
