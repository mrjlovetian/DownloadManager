//
//  MRJDownLoad.m
//  DownloadManager_Example
//
//  Created by tops on 2018/7/17.
//  Copyright © 2018年 mrjlovetian@gmail.com. All rights reserved.
//

#import "MRJDownLoad.h"

@interface MRJDownLoad() <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURL *downUrl;
@property (nonatomic, assign) long long expectedContentLength;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) long long  curreLength;

@property (nonatomic, strong) NSURLConnection *connect;
@property (nonatomic, assign) CFRunLoopRef curreRunloop;
@property (nonatomic, strong) NSOutputStream *outPutFileStream;

@property (nonatomic, copy) void (^progressBlock)(float);
@property (nonatomic, copy) void (^completeBlock)(NSString *);
@property (nonatomic, copy) void (^errorBlock)(NSString *);

@end

@implementation MRJDownLoad

- (void)downLoadWithUrl:(NSURL *)url progress:(void (^)(float progress))progress complete:(void (^)(NSString *filePath))complete errorMsg:(void(^)(NSString *errorMsg))errorMsg {
    
    self.downUrl = url;
    self.progressBlock = progress;
    self.completeBlock = complete;
    self.errorBlock = errorMsg;
    
    // 检查远程服务器文件大小
    [self checkFileWithUrl:url];
    
    // 判断在本地是否有文件
    if (![self checkLoaclFileInfo]) {
        // 下载完成
        NSLog(@"下载完成");
        return;
    };
    // 开始下载
    [self downloadFile];
}

#pragma mark 私有方法

- (void)checkFileWithUrl:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"HEAD";
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    self.expectedContentLength = response.expectedContentLength;
    
    // 建议保存的文件名,将在的文件保存在tmp ,系统会自动回收
    self.filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename];
}

- (BOOL)checkLoaclFileInfo {
    long long localFileSize = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        NSDictionary *fileDic = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:NULL];
        localFileSize = fileDic.fileSize;
    };
    
    if (localFileSize > self.expectedContentLength) {
        localFileSize = 0;
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:NULL];
    }
    
    self.curreLength = localFileSize;
    if (self.curreLength == self.expectedContentLength) {
        // 下载完成
        NSLog(@"下载完成");
        return NO;
    }
    return YES;
}

- (void)downloadFile {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.downUrl];
        [request setValue:[NSString stringWithFormat:@"bytes=%lld-", self.curreLength] forHTTPHeaderField:@"Range"];
        self.connect = [NSURLConnection connectionWithRequest:request delegate:self];
        [self.connect start];
        self.curreRunloop = CFRunLoopGetCurrent();
        CFRunLoopRun();
    });
}

#pragma mark 暂停任务
- (void)pause {
    [self.connect cancel];
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"收到服务器相应");
    self.outPutFileStream = [[NSOutputStream alloc] initToFileAtPath:self.filePath append:YES];
    [self.outPutFileStream open];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.outPutFileStream write:data.bytes maxLength:data.length];
    self.curreLength += data.length;
    float progress = (float)self.curreLength / self.expectedContentLength;
    NSLog(@"收到数据%f", progress);
    if (self.progressBlock) {
        self.progressBlock(progress);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"数据接收完毕");
    CFRunLoopStop(self.curreRunloop);
    [self.outPutFileStream close];
    if (self.completeBlock) {
        self.completeBlock(self.filePath);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"出现错误");
    CFRunLoopStop(self.curreRunloop);
    [self.outPutFileStream close];
    if (self.errorBlock) {
        self.errorBlock(error.localizedDescription);
    }
}

@end
