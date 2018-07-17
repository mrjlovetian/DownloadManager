# DownloadManager

[![CI Status](https://img.shields.io/travis/mrjlovetian@gmail.com/DownloadManager.svg?style=flat)](https://travis-ci.org/mrjlovetian@gmail.com/DownloadManager)
[![Version](https://img.shields.io/cocoapods/v/DownloadManager.svg?style=flat)](https://cocoapods.org/pods/DownloadManager)
[![License](https://img.shields.io/cocoapods/l/DownloadManager.svg?style=flat)](https://cocoapods.org/pods/DownloadManager)
[![Platform](https://img.shields.io/cocoapods/p/DownloadManager.svg?style=flat)](https://cocoapods.org/pods/DownloadManager)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


```
/*
 * url 具体的下载URL
 * progress 下载进度回调
 * complete 下载完成后回调下载路径
 * errorMsg 下载出错回调错误信息
 */
- (void)downLoadWithUrl:(NSURL *)url progress:(void (^)(float progress))progress complete:(void (^)(NSString *filePath))complete errorMsg:(void(^)(NSString *errorMsg))errorMsg;
```


```
/*
 * 暂停下载
 */
- (void)pause;
```

## Requirements

## Installation

DownloadManager is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DownloadManager'
```

## Author

mrjlovetian@gmail.com, yuhongjiang642@tops001.com

## License

DownloadManager is available under the MIT license. See the LICENSE file for more info.
# DownloadManager


