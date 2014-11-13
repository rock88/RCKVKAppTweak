// RCKViewController.m
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

#import "RCKViewController.h"
#import "RCKAudioManager.h"
#import "RCKCoreDataManager.h"
#import "RCKErrorManager.h"
#import "RCKAudio.h"
#import "RCKError.h"
#import "RCKSettings.h"

#import "UIAlertView+RCKTweak.h"

typedef NS_ENUM(NSUInteger, TableViewSection)
{
    TableViewSectionAudios = 0,
    TableViewSectionErrors,
    TableViewSectionSettings,
};

@interface RCKViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic) TableViewSection section;
@property (nonatomic) NSMutableArray* audios;
@property (nonatomic) NSArray* errors;
@property (nonatomic) UISegmentedControl* segmentedControl;
@property (nonatomic) UITableView* tableView;
@property (nonatomic) NSDateFormatter* dateFormatter;

@end

@implementation RCKViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"RCKVKAppTweak";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]};
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Change", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onButtonEditDown:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onButtonDoneDown:)];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Music", nil),@"Errors",NSLocalizedString(@"Settings", nil)]];
    self.segmentedControl.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.segmentedControl.bounds) + 4.0f);
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self action:@selector(onSegmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
    
    CGRect frame = CGRectMake(0.0f, CGRectGetMaxY(self.segmentedControl.frame) + 4.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.segmentedControl.frame) - 4.0f);
    self.tableView = [[UITableView alloc] initWithFrame:frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    self.audios = [NSMutableArray arrayWithArray:[[RCKAudioManager sharedInstance] audios]];
    [self.tableView reloadData];
}

- (void)onSegmentedControlChanged:(UISegmentedControl *)control
{
    self.section = control.selectedSegmentIndex;
    
    if (self.section != TableViewSectionAudios)
    {
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Change", nil);
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    else
    {
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
    
    switch (self.section)
    {
        case TableViewSectionAudios:
            self.audios = [NSMutableArray arrayWithArray:[[RCKAudioManager sharedInstance] audios]];
            break;
        case TableViewSectionErrors:
            self.errors = [[RCKErrorManager sharedInstance] errors];
            break;
        default:
            break;
    }
    
    self.tableView.editing = NO;
    [self.tableView reloadData];
}

- (void)onButtonEditDown:(UIBarButtonItem *)button
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    if (self.tableView.editing)
    {
        button.title = NSLocalizedString(@"Done", nil);
    }
    else
    {
        button.title = NSLocalizedString(@"Change", nil);
    }
}

- (void)onButtonDoneDown:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.section)
    {
        case TableViewSectionAudios:    return self.audios.count;
        case TableViewSectionErrors:    return self.errors.count;
        case TableViewSectionSettings:  return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (self.section)
    {
        case TableViewSectionAudios:
        case TableViewSectionErrors:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellStyleSubtitleId"];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellStyleSubtitleId"];
            }
            break;
        }
        case TableViewSectionSettings:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellStyleValue1Id"];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellStyleValue1Id"];
                cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:14.0f];
                cell.detailTextLabel.font = [UIFont fontWithName:cell.detailTextLabel.font.fontName size:14.0f];
            }
            break;
        }
    }
    
    switch (self.section)
    {
        case TableViewSectionAudios:
        {
            RCKAudio* audio = self.audios[indexPath.row];
            cell.textLabel.text = audio.artist;
            cell.detailTextLabel.text = audio.title;
            break;
        }
        case TableViewSectionErrors:
        {
            RCKError* error = self.errors[indexPath.row];
            cell.textLabel.text = error.text;
            cell.detailTextLabel.text = [self.dateFormatter stringFromDate:error.date];
            break;
        }
        case TableViewSectionSettings:
        {
            if (indexPath.row == 0)
            {
                cell.textLabel.text = @"When playing audio:";
                
                switch ([[RCKSettings sharedInstance] audioDownloadOptions])
                {
                    case RCKAudioDownloadAsk:
                        cell.detailTextLabel.text = @"Ask before download";
                        break;
                    case RCKAudioDownloadAlwaysDownload:
                        cell.detailTextLabel.text = @"Start download";
                        break;
                    case RCKAudioDownloadDontDownload:
                        cell.detailTextLabel.text = @"Don't download";
                        break;
                }
                
            }
            else
            {
                cell.textLabel.text = @"Show in audio album:";
                
                switch ([[RCKSettings sharedInstance] audioAlbumShowOptions])
                {
                    case RCKAudioAlbumShowMyAudio:
                        cell.detailTextLabel.text = @"My audio";
                        break;
                    case RCKAudioAlbumShowOnlyDownload:
                        cell.detailTextLabel.text = @"Downloaded audio";
                        break;
                }
            }
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.section == TableViewSectionAudios);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath && editingStyle == UITableViewCellEditingStyleDelete)
    {
        RCKAudio* audio = self.audios[indexPath.row];
        
        [[NSFileManager defaultManager] removeItemAtPath:audio.path error:nil];
        [[RCKCoreDataManager sharedInstance] deleteEntity:audio];
        [self.audios removeObject:audio];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [tableView endUpdates];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (self.section)
    {
        case TableViewSectionAudios:
            break;
        case TableViewSectionErrors:
        {
            RCKError* error = self.errors[indexPath.row];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[self.dateFormatter stringFromDate:error.date] message:error.text delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            break;
        }
        case TableViewSectionSettings:
        {
            __weak __typeof(self) weakSelf = self;
            
            if (indexPath.row == 0)
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"RCKVKAppTweak" message:@"When playing audio" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ask before download", @"Start download", @"Don't download", nil];
                [alert showWithBlock:^(NSUInteger buttonIndex)
                 {
                     if (buttonIndex != 0)
                     {
                         [[RCKSettings sharedInstance] setAudioDownloadOptions:(buttonIndex - 1)];
                         
                         [weakSelf.tableView beginUpdates];
                         [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                         [weakSelf.tableView endUpdates];
                     }
                 }];
            }
            else
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"RCKVKAppTweak" message:@"Show in audio album" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"My audio", @"Downloaded audio", nil];
                [alert showWithBlock:^(NSUInteger buttonIndex)
                 {
                     if (buttonIndex != 0)
                     {
                         [[RCKSettings sharedInstance] setAudioAlbumShowOptions:(buttonIndex - 1)];
                         
                         [weakSelf.tableView beginUpdates];
                         [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                         [weakSelf.tableView endUpdates];
                     }
                 }];
            }
            break;
        }
    }
}

@end
