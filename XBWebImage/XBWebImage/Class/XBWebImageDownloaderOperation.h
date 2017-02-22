//
//  XBWebImageDownloaderOperation.h
//  XBWebImage
//
//  Created by xiabob on 17/2/21.
//
//

#import <Foundation/Foundation.h>
#import "XBWebImageDownloader.h"

//有的系统框架更要求在主队列，而不仅仅是主线程
#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

@interface XBWebImageDownloaderOperation : NSOperation <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong, readonly) NSURLSessionDataTask *dataTask;

- (instancetype)initWithRequest:(NSURLRequest *)request inSession:(NSURLSession *)session;

- (NSMutableDictionary *)addProgressBlock:(XBWebImageDownloaderProgressBlock)progressBlock
                        andCompletedBlock:(XBWebImageDownloaderCompletedBlock)completeBlock;

- (BOOL)cancel:(id)callback;

@end
