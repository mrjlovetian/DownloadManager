//
//  MRJDownLoaderManager.m
//  DownloadManager_Example
//
//  Created by tops on 2018/7/17.
//  Copyright © 2018年 mrjlovetian@gmail.com. All rights reserved.
//

#import "MRJDownLoaderManager.h"
#import "MRJDownLoad.h"

@interface MRJDownLoaderManager()

@property (nonatomic, strong) NSMutableDictionary *downCache;

@end

@implementation MRJDownLoaderManager

+ (instancetype)shareDownLoaderManager {
    static MRJDownLoaderManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MRJDownLoaderManager alloc] init];
    });
    return manager;
}

- (void)downLoadWithUrl:(NSURL *)url progress:(void (^)(float progress))progressBlock complete:(void (^)(NSString *filePath))completeBlock errorMsg:(void(^)(NSString *errorMsg))errorMsgBlock {
    
    if (self.downCache[url.path]){
        return;
    }
    MRJDownLoad *downLoader = [[MRJDownLoad alloc] init];
    [downLoader downLoadWithUrl:url progress:progressBlock complete:^(NSString *filePath) {
        [self.downCache removeObjectForKey:url.path];
        if (completeBlock) {
            completeBlock(filePath);
        }
    } errorMsg:^(NSString *errorMsg) {
        [self.downCache removeObjectForKey:url.path];
        if (errorMsg) {
            errorMsgBlock(errorMsg);
        }
    }];
    [self.downCache setObject:downLoader forKey:url.path];
}
    
- (void)pause:(NSURL *)url {
    MRJDownLoad *downLoader = self.downCache[url.path];
    if (downLoader) {
        [downLoader pause];
        [self.downCache removeObjectForKey:url.path];
    }
}

- (NSMutableDictionary *)downCache {
    if (!_downCache){
        _downCache = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _downCache;
}
    
@end
