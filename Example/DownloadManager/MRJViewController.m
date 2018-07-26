//
//  MRJViewController.m
//  DownloadManager
//
//  Created by mrjlovetian@gmail.com on 07/17/2018.
//  Copyright (c) 2018 mrjlovetian@gmail.com. All rights reserved.
//

#import "MRJViewController.h"
#import "MRJDownLoaderManager.h"

@interface MRJViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation MRJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)start
{

    [[MRJDownLoaderManager shareDownLoaderManager] downLoadWithUrl:[NSURL URLWithString:@"http://vodsphn1rqs.vod.126.net/vodsphn1rqs/CozhBPHn_1761895104_hd.mp4"] progress:^(float progress) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress;
        });
        
    } complete:^(NSString *filePath) {
        
    } errorMsg:^(NSString *errorMsg) {
        
    } ];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pause {
    [[MRJDownLoaderManager shareDownLoaderManager] pause:[NSURL URLWithString:@"http://vodsphn1rqs.vod.126.net/vodsphn1rqs/CozhBPHn_1761895104_hd.mp4"]];
}

@end
