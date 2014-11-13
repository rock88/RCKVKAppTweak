// RCKAudioManager.m
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

#import "RCKAudioManager.h"
#import "RCKCoreDataManager.h"
#import "RCKErrorManager.h"

#import "RCKAudio+Addition.h"

@interface RCKAudioManager ()

@property (nonatomic) NSURL* applicationDocumentsDirectory;

@end

@implementation RCKAudioManager

+ (instancetype)sharedInstance
{
    static RCKAudioManager* sharedInstance = nil;
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
        self.applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    }
    return self;
}

#pragma mark -
#pragma mark RCKAudio Entity base

- (RCKAudio *)newRCKAudioEntity
{
    return [[RCKCoreDataManager sharedInstance] newObjectForEntityForName:NSStringFromClass([RCKAudio class])];
}

- (RCKAudio *)RCKAudioEntityWithAudioId:(NSString *)audioId
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([RCKAudio class])];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"audio_id == %@",audioId];
    
    NSArray* results = [[RCKCoreDataManager sharedInstance] executeFetchRequest:request error:nil];
    return [results firstObject];
}

- (void)updateRCKAudioEntityWithAudioId:(NSString *)audioId andParameters:(NSDictionary *)params
{
    if (audioId && params)
    {
        RCKAudio* entity = [self RCKAudioEntityWithAudioId:audioId];
        if (entity == nil)
        {
            entity = [self newRCKAudioEntity];
            entity.audio_id = audioId;
        }
        
        entity.artist = params[@"artist"];
        entity.title = params[@"title"];
        entity.id = [params[@"id"] stringValue];
        entity.oid = [params[@"owner_id"] stringValue];
        entity.duration = @([params[@"duration"] integerValue]);
        
        [[RCKCoreDataManager sharedInstance] saveContext];
    }
    else
    {
        [[RCKErrorManager sharedInstance] handleErrorWithString:@"Failed update RCKAudio: audioId or params is nil"];
    }
}

- (void)updateRCKAudioEntityWithAudioId:(NSString *)audioId andAudioPath:(NSString *)path
{
    if (audioId && path)
    {
        RCKAudio* entity = [self RCKAudioEntityWithAudioId:audioId];
        if (entity == nil)
        {
            [[RCKErrorManager sharedInstance] handleErrorWithString:@"Create new RCKAudio entity from -updateRCKAudioEntityWithAudioId:andAudioPath:"];
            
            entity = [self newRCKAudioEntity];
            entity.audio_id = audioId;
        }
        
        NSURL* url = [self.applicationDocumentsDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"RCKVKAppTweakFiles/%@-%@-%@.mp3",entity.artist,entity.title,audioId]];
        NSString* newPath = url.path;
        NSError* error = nil;
        
        [[NSFileManager defaultManager] removeItemAtPath:newPath error:nil];
        if ([[NSFileManager defaultManager] copyItemAtPath:path toPath:newPath error:&error])
        {
            entity.path = newPath;
            
            [[RCKCoreDataManager sharedInstance] saveContext];
        }
        else
        {
            [[RCKErrorManager sharedInstance] handleError:error];
        }
    }
    else
    {
        [[RCKErrorManager sharedInstance] handleErrorWithString:@"Failed update RCKAudio: audioId or path is nil"];
    }
}

- (NSArray *)audios
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([RCKAudio class])];
    return [[RCKCoreDataManager sharedInstance] executeFetchRequest:request error:nil];
}

#pragma mark -
#pragma mark Response

- (NSDictionary *)audioGetResponse
{
    NSMutableArray* items = [NSMutableArray array];
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([RCKAudio class])];
    NSArray* audios = [[RCKCoreDataManager sharedInstance] executeFetchRequest:request error:nil];
    
    [audios enumerateObjectsUsingBlock:^(RCKAudio* audio, NSUInteger index, BOOL *stop)
     {
         if ([audio audioFileExist])
         {
             [items addObject:audio.requestResponce];
         }
     }];
    
    return @{
             @"response":@{
                     @"count":@(items.count),
                     @"items":items
                     }
             };
}

@end
