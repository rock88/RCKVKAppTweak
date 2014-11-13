// RCKCoreDataModelSerialization.m
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

#import "RCKCoreDataModelSerialization.h"

@implementation RCKCoreDataModelSerialization

+ (instancetype)sharedInstance
{
    static RCKCoreDataModelSerialization* sharedInstance = nil;
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
        
    }
    return self;
}

- (void)serializeDataModelWithURL:(NSURL *)URL
{
    NSString* templateHeader =
    @"/*\n"
    @" * Auto generated header for Core Data Model \n"
    @" * Include RCKCoreDataModelSerializeData object \n"
    @" * \n"
    @" * Warning: Do not edit manually! \n"
    @" */\n\n"
    @"RCKCoreDataModelSerializeData %@ = \n"    // Data object name
    @"{\n"
    @"    \"%@\",\n"                            // Data model file name
    @"    %d,\n"                                // Files count in data model
    @"    {\n";
    
    NSString* templateMiddle =
    @"        {\n"
    @"            \"%@\",\n"                    // File name
    @"            \"%@\"\n"                     // Base64 data
    @"        },\n";
    
    NSString* templateEnd =
    @"    }\n"
    "};\n";
    
    if ([[[URL lastPathComponent] pathExtension] isEqualToString:@"momd"])
    {
        NSMutableString* string = [NSMutableString string];
        
        NSArray* fileURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:URL includingPropertiesForKeys:nil options:0 error:nil];
        NSString* varName = [NSString stringWithFormat:@"%@",[[URL lastPathComponent] stringByReplacingOccurrencesOfString:@"." withString:@"_"]];
        [string appendFormat:templateHeader,varName,[URL lastPathComponent],fileURLs.count];
        
        for (NSURL* fileURL in fileURLs)
        {
            NSData* data = [NSData dataWithContentsOfURL:fileURL];
            [string appendFormat:templateMiddle,[fileURL lastPathComponent],[data base64EncodedStringWithOptions:0]];
        }
        
        NSString* fileName = [NSString stringWithFormat:@"%@_%@.h",NSStringFromClass([self class]),[[URL lastPathComponent] stringByReplacingOccurrencesOfString:@"." withString:@"_"]];
        
        [string appendString:templateEnd];
        [string writeToFile:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

- (void)deserializeDataModel:(RCKCoreDataModelSerializeData *)data andWriteToPath:(NSString *)path
{
    NSString* dataModelContentPath = [path stringByAppendingPathComponent:[NSString stringWithUTF8String:data->fileName]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataModelContentPath] == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataModelContentPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        for (NSInteger i = 0; i < data->filesCount; i++)
        {
            NSString* path = [dataModelContentPath stringByAppendingPathComponent:[NSString stringWithUTF8String:data->RCKCoreDataModelSerializeDataFiles[i].fileName]];
            NSString* base64String = [NSString stringWithUTF8String:data->RCKCoreDataModelSerializeDataFiles[i].base64data];
            
            [[[NSData alloc] initWithBase64EncodedString:base64String options:0] writeToFile:path atomically:YES];
        }
    }
}

@end
