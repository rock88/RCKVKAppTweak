// RCKTweakAFJSONRequestOperation.xm
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

#import "AFJSONRequestOperation.h"
#import "RCKAudioManager.h"
#import "RCKSettings.h"

#import "NSObject+RCKNetworkUtilities.h"
#import "NSURLRequest+RCKUtilities.h"
#import "RCKAudio+Addition.h"

%hook AFJSONRequestOperation

+ (id)JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, id))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id))failure
{
    if ([urlRequest isAudioGetRequest])
    {
        if ([[RCKSettings sharedInstance] audioAlbumShowOptions] == RCKAudioAlbumShowOnlyDownload || [NSObject networkAvailable] == NO)
        {
            success(urlRequest,nil,[RCKAudioManager sharedInstance].audioGetResponse);
            return nil;
        }
    }
    else if ([urlRequest isAudioGetByIdRequest])
    {
        NSString* audioId = [urlRequest audioId];
        if (audioId)
        {
            RCKAudio* audio = [[RCKAudioManager sharedInstance] RCKAudioEntityWithAudioId:audioId];
            if ([audio audioFileExist])
            {
                success(urlRequest,nil,@{@"response":@[audio.requestResponce]});
                return nil;
            }
        }
    }
    
    return %orig;
}

- (id)responseJSON
{
    id responseJSON = %orig;
    
    if ([self.request isAudioGetByIdRequest])
    {
        if (responseJSON)
        {
            NSDictionary* dict = responseJSON[@"response"][0];
            NSString* audioId = [NSString stringWithFormat:@"%@_%@",dict[@"owner_id"],dict[@"id"]];
            
            [[RCKAudioManager sharedInstance] updateRCKAudioEntityWithAudioId:audioId andParameters:dict];
        }
    }
    
    return responseJSON;
}

%end
