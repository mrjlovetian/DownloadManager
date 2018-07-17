//
//  MRJDownLoad.m
//  DownloadManager_Example
//
//  Created by tops on 2018/7/17.
//  Copyright © 2018年 mrjlovetian@gmail.com. All rights reserved.
//

#import "MRJDownLoad.h"

@interface MRJDownLoad() <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

/// 下载地址
@property (nonatomic, strong) NSURL *downUrl;
/// 服务器给定下载文件长度
@property (nonatomic, assign) long long expectedContentLength;
/// 文件下载存放目录
@property (nonatomic, copy) NSString *filePath;
/// 当前文件保存长度
@property (nonatomic, assign) long long  curreLength;

/// 初始化URL链接类
@property (nonatomic, strong) NSURLConnection *connect;
/// runloop保证线程不退出
@property (nonatomic, assign) CFRunLoopRef curreRunloop;
/// 文件输入输出流，用来保存下载文件
@property (nonatomic, strong) NSOutputStream *outPutFileStream;

/// 下载回调进度
@property (nonatomic, copy) void (^progressBlock)(float);
/// 下载完成回调
@property (nonatomic, copy) void (^completeBlock)(NSString *);
/// 下载失败完成回调
@property (nonatomic, copy) void (^errorBlock)(NSString *);

@end

@implementation MRJDownLoad

- (void)downLoadWithUrl:(NSURL *)url progress:(void (^)(float progress))progressBlock complete:(void (^)(NSString *filePath))completeBlock errorMsg:(void(^)(NSString *errorMsg))errorMsgBlock {
    
    self.downUrl = url;
    self.progressBlock = progressBlock;
    self.completeBlock = completeBlock;
    self.errorBlock = errorMsgBlock;
    
    // 检查远程服务器文件大小
    [self checkFileWithUrl:url];
    
    // 判断在本地是否有文件
    if (![self checkLoaclFileInfo]) {
        // 下载完成
        if (self.completeBlock) {
            self.completeBlock(self.filePath);
        }
        return;
    };
    // 开始下载
    [self downloadFile];
}

#pragma mark 私有方法
/// 通过URL检查远程服务器文件信息
- (void)checkFileWithUrl:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"HEAD";
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    self.expectedContentLength = response.expectedContentLength;
    
    // 建议保存的文件名,将在的文件保存在tmp ,系统会自动回收
    self.filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename];
}

/// 拿到本地已下载文件信息
- (BOOL)checkLoaclFileInfo {
    long long localFileSize = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        NSDictionary *fileDic = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:NULL];
        localFileSize = fileDic.fileSize;
    };
    
    /// 本地文件大于服务器文件时删除本地文件，这样的情况就是服务器换文件，或者下载出错
    if (localFileSize > self.expectedContentLength) {
        localFileSize = 0;
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:NULL];
    }
    
    self.curreLength = localFileSize;
    /// 如果本地文件大小和服务器文件大小相等，可认定文件已下载完成，当然还是以MD5校验为准
    if (self.curreLength == self.expectedContentLength) {
        // 下载完成
        return NO;
    }
    return YES;
}

/// 文件下载
- (void)downloadFile {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.downUrl];
        /// 在请求头里有一个关键字段Range，用来告诉服务器我需要从哪里开始已下载
        /// bytes=10- 表示从10字节以后完全获取
        /// bytes=20-400 表示从20-400之间的数据
        /// bytes= -500 表示需要最后的500字节数据
        [request setValue:[NSString stringWithFormat:@"bytes=%lld-", self.curreLength] forHTTPHeaderField:@"Range"];
        self.connect = [NSURLConnection connectionWithRequest:request delegate:self];
        [self.connect start];
        self.curreRunloop = CFRunLoopGetCurrent();
        CFRunLoopRun();
    });
}

#pragma mark 暂停任务
    
/// 任务暂停
- (void)pause {
    [self.connect cancel];
}

#pragma mark NSURLConnectionDataDelegate

/// 收到服务器相应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.outPutFileStream = [[NSOutputStream alloc] initToFileAtPath:self.filePath append:YES];
    [self.outPutFileStream open];
}
    
/// 收到数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.outPutFileStream write:data.bytes maxLength:data.length];
    self.curreLength += data.length;
    float progress = (float)self.curreLength / self.expectedContentLength;
    if (self.progressBlock) {
        self.progressBlock(progress);
    }
}

/// 数据接收完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    CFRunLoopStop(self.curreRunloop);
    [self.outPutFileStream close];
    if (self.completeBlock) {
        self.completeBlock(self.filePath);
    }
}

/// 出现错误
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    CFRunLoopStop(self.curreRunloop);
    [self.outPutFileStream close];
    if (self.errorBlock) {
        self.errorBlock(error.localizedDescription);
    }
}

@end
