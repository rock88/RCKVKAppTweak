// RCKTweakIOS7AudioController.xm
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

#import "AudioPlayer.h"
#import "IOS7AudioController.h"
#import "RCKLoadingView.h"
#import "RCKViewController.h"

static NSString* const RCKTweakAudioPlayerPlayFromFileNotification = @"RCKTweakAudioPlayerPlayFromFileNotification";
static NSString* const RCKTweakAudioPlayerBeginDownloadNotification = @"RCKTweakAudioPlayerBeginDownloadNotification";
static NSString* const RCKTweakAudioPlayerFinishDownloadNotification = @"RCKTweakAudioPlayerFinishDownloadNotification";
static NSString* const RCKTweakAudioPlayerErrorDownloadNotification = @"RCKTweakAudioPlayerErrorDownloadNotification";
static NSString* const RCKTweakAudioPlayerProgressDownloadNotification = @"RCKTweakAudioPlayerProgressDownloadNotification";

%hook IOS7AudioController

- (void)viewDidLoad
{
    %orig;
    
    self.RCKLoadingView = [[RCKLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - 30.0f, 0.0f, 30.0f, 30.0f)];
    [self.cover addSubview:self.RCKLoadingView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayerDidPlayFromFile:) name:RCKTweakAudioPlayerPlayFromFileNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayerDidBeginDownload:) name:RCKTweakAudioPlayerBeginDownloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayerDidFinishDownload:) name:RCKTweakAudioPlayerFinishDownloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayerDidErrorDownload:) name:RCKTweakAudioPlayerErrorDownloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayerDidProgressDownload:) name:RCKTweakAudioPlayerProgressDownloadNotification object:nil];
}

- (void)viewDidUnload
{
    %orig;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCKTweakAudioPlayerPlayFromFileNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCKTweakAudioPlayerBeginDownloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCKTweakAudioPlayerFinishDownloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCKTweakAudioPlayerErrorDownloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCKTweakAudioPlayerProgressDownloadNotification object:nil];
}

%new(v@)
- (void)audioPlayerDidPlayFromFile:(NSNotification *)notification
{
    [self.RCKLoadingView doneLoading];
}

%new(v@)
- (void)audioPlayerDidBeginDownload:(NSNotification *)notification
{
    [self.RCKLoadingView startLoading];
}

%new(v@)
- (void)audioPlayerDidFinishDownload:(NSNotification *)notification
{
    if (notification.userInfo[@"audio"] == self.model.audio)
    {
        [self.RCKLoadingView doneLoading];
    }
}

%new(v@)
- (void)audioPlayerDidErrorDownload:(NSNotification *)notification
{
    if (notification.userInfo[@"audio"] == self.model.audio)
    {
        [self.RCKLoadingView errorLoading];
    }
}

%new(v@)
- (void)audioPlayerDidProgressDownload:(NSNotification *)notification
{
    if (notification.userInfo[@"audio"] == self.model.audio)
    {
        self.RCKLoadingView.progress = [notification.userInfo[@"progress"] floatValue];
    }
}

%end

%hook UINavigationController

- (void)viewDidLoad
{
    %orig;
    
    UILongPressGestureRecognizer* gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(__onTap:)];
    [self.navigationBar addGestureRecognizer:gesture];
}

%new(v@)
- (void)__onTap:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        if ([self.topViewController isKindOfClass:[RCKViewController class]] == NO)
        {
            RCKViewController* controller = [[RCKViewController alloc] init];
            [self.topViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:nil];
        }
    }
}

%end
