//
//  XBWebImageDownloader.m
//  XBWebImage
//
//  Created by xiabob on 17/2/21.
//
//

#import "XBWebImageDownloader.h"
#import "XBWebImageDownloaderOperation.h"

@implementation XBWebImageDownloaderToken

@end

@interface XBWebImageDownloader()

@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) dispatch_queue_t barrierQueue;
@property (nonatomic, strong) NSMutableDictionary <NSURL *, XBWebImageDownloaderOperation *> *urlOperations;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *httpHeaders;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation XBWebImageDownloader

+ (instancetype)sharedDownloader {
    static XBWebImageDownloader *downloader;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        downloader = [XBWebImageDownloader new];
    });
    
    return downloader;
}

- (instancetype)init {
    return [self initWithSessionConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    if (self = [super init]) {
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.maxConcurrentOperationCount = 6;
        _downloadQueue.name = @"com.xiabob.XBWebImageDownloader";
        _barrierQueue = dispatch_queue_create("com.xiabob.XBWebImageDownloader.barrier", DISPATCH_QUEUE_CONCURRENT);
        _urlOperations = [NSMutableDictionary new];
        _httpHeaders = [@{@"Accept": @"image/*;q=0.8"} mutableCopy];
        configuration.timeoutIntervalForRequest = 15;
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        _executionOrder = XBWebImageDownloaderExecutionOrderFIFO;
    }
    
    return self;
}

- (void)dealloc {
    [self.session invalidateAndCancel];
    self.session = nil;
    
    [self.downloadQueue cancelAllOperations];
}

- (void)setMaxConcurrentDownload:(NSUInteger)maxConcurrentDownload {
    self.downloadQueue.maxConcurrentOperationCount = maxConcurrentDownload;
}

- (void)setDownloadTimeout:(NSUInteger)downloadTimeout {
    _downloadTimeout = downloadTimeout <= 0 ? 15 : downloadTimeout;
}

- (XBWebImageDownloaderToken *)downloadImageWithUrl:(NSURL *)url
                                            options:(XBWebImageDownloaderOptions)options
                                           progress:(XBWebImageDownloaderProgressBlock)progressBlock
                                          completed:(XBWebImageDownloaderCompletedBlock)completedBlock {
    __block XBWebImageDownloaderToken *token;
    dispatch_barrier_sync(self.barrierQueue, ^{
        XBWebImageDownloaderOperation *operation = self.urlOperations[url];
        if (!operation) { //需要创建
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:self.downloadTimeout];
            request.allHTTPHeaderFields = self.httpHeaders;
            request.HTTPShouldUsePipelining = YES;
            
            operation = [[XBWebImageDownloaderOperation alloc] initWithRequest:request
                                                                     inSession:self.session];
            __weak XBWebImageDownloaderOperation *wOperation = operation;

            //设置completionBlock，operation完成，移除urlOperations数组中对应的operation。注意，通过kvo，当finished时YES，operationQueue是自动移除对应的operation。这就是为什么自定义operation时，需要重写finished等属性。
            operation.completionBlock = ^{
                XBWebImageDownloaderOperation *sOperation = wOperation;
                if (!sOperation) { return ;}
                if (self.urlOperations[url] == sOperation) {
                    [self.urlOperations removeObjectForKey:url];
                }
            };
            
            //设置queuePriority
            if (options & XBWebImageDownloaderOptionsLowPriority) {
                operation.queuePriority = NSOperationQueuePriorityLow;
            } else if (options & XBWebImageDownloaderOptionsHighPriority) {
                operation.queuePriority = NSOperationQueuePriorityHigh;
            }
            
            //设置execution order
            if (self.executionOrder == XBWebImageDownloaderExecutionOrderFILO) {
                XBWebImageDownloaderOperation *last = [self.downloadQueue.operations lastObject];
                [last addDependency:operation];
            }
            
            self.urlOperations[url] = operation;
            [self.downloadQueue addOperation:operation];
        }
        
        token = [XBWebImageDownloaderToken new];
        token.url = url;
        token.callback = [operation addProgressBlock:progressBlock andCompletedBlock:completedBlock];
    });
    
    return token;
}

- (void)cancle:(XBWebImageDownloaderToken *)token {
    if (!token) {return;}
    dispatch_barrier_async(self.barrierQueue, ^{
        XBWebImageDownloaderOperation *operation = self.urlOperations[token.url];
        if ([operation cancel:token.callback]) {
            [self.urlOperations removeObjectForKey:token.url];
        }
    });
}

- (void)cancleAllOperations {
    [self.downloadQueue cancelAllOperations];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    XBWebImageDownloaderOperation *operation = self.urlOperations[dataTask.response.URL];
    [operation URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    XBWebImageDownloaderOperation *operation = self.urlOperations[dataTask.response.URL];
    [operation URLSession:session dataTask:dataTask didReceiveData:data];
}


- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler {
    XBWebImageDownloaderOperation *operation = self.urlOperations[dataTask.response.URL];
    [operation URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    XBWebImageDownloaderOperation *operation = self.urlOperations[task.response.URL];
    [operation URLSession:session task:task didCompleteWithError:error];
}

@end
