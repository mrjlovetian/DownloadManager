//
//  MRJDownLoaderManager.h
//  DownloadManager_Example
//
//  Created by tops on 2018/7/17.
//  Copyright © 2018年 mrjlovetian@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRJDownLoaderManager : NSObject
    
+ (instancetype)shareDownLoaderManager;
    
- (void)downLoadWithUrl:(NSURL *)url progress:(void (^)(float progress))progress complete:(void (^)(NSString *filePath))complete errorMsg:(void(^)(NSString *errorMsg))errorMsg;
    
- (void)pause:(NSURL *)url;
    
@end
