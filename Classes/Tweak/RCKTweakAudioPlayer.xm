// RCKTweakAudioPlayer.xm
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

#import "RCKAudio.h"
#import "RCKErrorManager.h"

#import "VKAudio.h"
#import "MOPlaylist.h"
#import "AudioPlayer.h"

#import "RCKFileDownloader.h"
#import "RCKAudioManager.h"
#import "RCKSettings.h"

#import "UIAlertView+RCKTweak.h"

static NSString* const RCKTweakAudioPlayerPlayFromFileNotification = @"RCKTweakAudioPlayerPlayFromFileNotification";
static NSString* const RCKTweakAudioPlayerBeginDownloadNotification = @"RCKTweakAudioPlayerBeginDownloadNotification";
static NSString* const RCKTweakAudioPlayerFinishDownloadNotification = @"RCKTweakAudioPlayerFinishDownloadNotification";
static NSString* const RCKTweakAudioPlayerErrorDownloadNotification = @"RCKTweakAudioPlayerErrorDownloadNotification";
static NSString* const RCKTweakAudioPlayerProgressDownloadNotification = @"RCKTweakAudioPlayerProgressDownloadNotification";

@interface AudioPlayer ()

- (VKAudio *)VKAudioByURL:(NSURL *)URL;
- (void)startDownloadAudioWithURL:(NSURL *)URL;

@end

%hook NSURL

+ (id)URLWithString:(NSString *)URLString
{
    if ([URLString hasPrefix:@"/var"])
    {
        return [NSURL fileURLWithPath:URLString];
    }
    else
    {
        return %orig;
    }
}

%end

%hook AudioPlayer

- (void)setPlayer:(AVPlayer *)player
{
    AVURLAsset* asset = (id)player.currentItem.asset;
    
    if ([asset isKindOfClass:[AVURLAsset class]] && [asset.URL.scheme isEqualToString:@"http"])
    {
        RCKAudio* entity = [[RCKAudioManager sharedInstance] RCKAudioEntityWithAudioId:[NSString stringWithFormat:@"%@_%@",self.audio.iden.oid,self.audio.iden.iid]];
        if (entity.path)
        {
            AVPlayer* player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:entity.path]];
            %orig(player);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:RCKTweakAudioPlayerPlayFromFileNotification object:self];
        }
        else
        {
            %orig;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:RCKTweakAudioPlayerBeginDownloadNotification object:self];
            
            RCKAudioDownloadOptions options = [[RCKSettings sharedInstance] audioDownloadOptions];
            
            if (options == RCKAudioDownloadAsk)
            {
                __weak __typeof(self) weakSelf = self;
                
                VKAudio* audio = [self VKAudioByURL:asset.URL];
                NSString* message = [NSString stringWithFormat:@"%@ %@?", NSLocalizedString(@"store_alert_purchase_download", nil), audio.title];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"RCKVKAppTweak" message:message delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                [alert showWithBlock:^(NSUInteger buttonIndex)
                 {
                     if (buttonIndex != 0)
                     {
                         [weakSelf startDownloadAudioWithURL:asset.URL];
                     }
                 }];
            }
            else if (options == RCKAudioDownloadAlwaysDownload)
            {
                [self startDownloadAudioWithURL:asset.URL];
            }
        }
    }
    else
    {
        if ([asset.URL.path hasPrefix:@"/var"])
        {
            AVPlayer* player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:asset.URL.path]];
            %orig(player);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:RCKTweakAudioPlayerPlayFromFileNotification object:self];
        }
        else
        {
            %orig;
        }
    }
}

%new(v@)
- (VKAudio *)VKAudioByURL:(NSURL *)URL
{
    for (VKAudio* audio in self.playlist.items)
    {
        if ([audio.url isEqualToString:URL.absoluteString])
        {
            return audio;
        }
    }
    return nil;
}

%new(v@)
- (void)startDownloadAudioWithURL:(NSURL *)URL
{
    __weak __typeof(self) weakSelf = self;
    
    void (^completionHandler)(NSURL *location, NSURLResponse *response, NSError *error) = ^(NSURL *location, NSURLResponse *response, NSError *error)
    {
        VKAudio* audio = [weakSelf VKAudioByURL:response.URL];
        
        if (location)
        {
            if (audio)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:RCKTweakAudioPlayerFinishDownloadNotification object:weakSelf userInfo:@{@"audio":audio}];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:RCKTweakAudioPlayerFinishDownloadNotification object:weakSelf];
            }
            
            NSString* audioId = [NSString stringWithFormat:@"%@_%@",audio.iden.oid,audio.iden.iid];
            [[RCKAudioManager sharedInstance] updateRCKAudioEntityWithAudioId:audioId andAudioPath:location.path];
            
            if ([audio.url isEqualToString:weakSelf.audio.url])
            {
                RCKAudio* entity = [[RCKAudioManager sharedInstance] RCKAudioEntityWithAudioId:audioId];
                if (entity)
                {
                    audio.url = entity.path;
                    
                    CMTime time = weakSelf.player.currentTime;
                    BOOL isPlaying = (weakSelf.player.rate != 0.0f);
                    
                    [weakSelf.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:audio.url]]];
                    [weakSelf.player seekToTime:time];
                    
                    if (isPlaying)
                    {
                        [weakSelf.player play];
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:RCKTweakAudioPlayerPlayFromFileNotification object:weakSelf];
                }
            }
        }
        else
        {
            if (audio)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:RCKTweakAudioPlayerErrorDownloadNotification object:weakSelf userInfo:@{@"error":error,@"audio":audio}];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:RCKTweakAudioPlayerErrorDownloadNotification object:weakSelf userInfo:@{@"error":error}];
            }
            
            [[RCKErrorManager sharedInstance] handleError:error];
        }
    };
    
    void (^progressCallback)(CGFloat progress) = ^(CGFloat progress)
    {
        VKAudio* audio = [weakSelf VKAudioByURL:URL];
        if (audio)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:RCKTweakAudioPlayerProgressDownloadNotification object:weakSelf userInfo:@{@"progress":@(progress),@"audio":audio}];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:RCKTweakAudioPlayerProgressDownloadNotification object:weakSelf userInfo:@{@"progress":@(progress)}];
        }
    };
    
    [[[RCKFileDownloader sharedInstance] downloadTaskWithRequest:[NSURLRequest requestWithURL:URL] completionHandler:completionHandler progressCallback:progressCallback] resume];
}

%end
