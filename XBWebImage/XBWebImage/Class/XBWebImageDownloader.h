//
//  XBWebImageDownloader.h
//  XBWebImage
//
//  Created by xiabob on 17/2/21.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^XBWebImageDownloaderProgressBlock)(NSUInteger receivedSize, NSInteger expectedSize, NSURL *imageUrl);
typedef void(^XBWebImageDownloaderCompletedBlock)(UIImage *image, NSData *data, NSError *error, BOOL finished);

typedef NS_OPTIONS(NSUInteger, XBWebImageDownloaderOptions) {
    /** set operation low queuePriority */
    XBWebImageDownloaderOptionsLowPriority = 1<<0,
    
    /** set operation high queuePriority */
    XBWebImageDownloaderOptionsHighPriority = 1<<1,
};

typedef NS_OPTIONS(NSUInteger, XBWebImageDownloaderExecutionOrder) {
    XBWebImageDownloaderExecutionOrderFIFO = 1<<0,
    XBWebImageDownloaderExecutionOrderFILO = 1<<1,
};


@interface XBWebImageDownloaderToken : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) id callback;

@end


@interface XBWebImageDownloader : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, assign) NSUInteger maxConcurrentDownload;
@property (nonatomic, assign) NSUInteger downloadTimeout;

/** 设置operation的执行顺序，默认是XBWebImageDownloaderExecutionOrderFIFO，先进先出 */
@property (nonatomic, assign) XBWebImageDownloaderExecutionOrder executionOrder;


+ (instancetype)sharedDownloader;

- (XBWebImageDownloaderToken *)downloadImageWithUrl:(NSURL *)url
                                            options:(XBWebImageDownloaderOptions)options
                                           progress:(XBWebImageDownloaderProgressBlock)progressBlock
                                          completed:(XBWebImageDownloaderCompletedBlock)completedBlock;

- (void)cancle:(XBWebImageDownloaderToken *)token;
- (void)cancleAllOperations;

@end
