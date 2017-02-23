//
//  XBWebImageDownloaderOperation.m
//  XBWebImage
//
//  Created by xiabob on 17/2/21.
//
//

#import "XBWebImageDownloaderOperation.h"


typedef NSMutableDictionary<NSString *, id> XBCallbacksDictionary;
static NSString *const kProgressCallbackKey = @"kProgressCallbackKey";
static NSString *const kCompletedCallbackKey = @"kCompletedCallbackKey";


@interface XBWebImageDownloaderOperation()

//两个参数在NSOperation中是read only，但是自定义Operation我们需要修改它们的值
@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, assign, getter=isExecuting) BOOL executing;

@property (nonatomic, weak) NSURLSession *unownedSession;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@property (nonatomic, strong) NSMutableArray<XBCallbacksDictionary *> *callbackBlocks;
@property (nonatomic, assign) NSInteger expectedSize;
@property (nonatomic, strong) NSMutableData *imageData;
@property (nonatomic, strong) dispatch_queue_t barrierQueue; //http://stackoverflow.com/questions/8904206/what-property-should-i-use-for-a-dispatch-queue-after-arc

@end

@implementation XBWebImageDownloaderOperation
@synthesize finished = _finished;
@synthesize executing = _executing;


- (instancetype)initWithRequest:(NSURLRequest *)request inSession:(NSURLSession *)session {
    if (self = [super init]) {
        _request = request;
        _unownedSession = session;
        _finished = NO;
        _executing = NO;
        _callbackBlocks = [NSMutableArray new];
        _barrierQueue = dispatch_queue_create("com.xiabob.XBWebImageDownloaderOperation.barrierQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}


#pragma mark - handle block

- (NSMutableDictionary *)addProgressBlock:(XBWebImageDownloaderProgressBlock)progressBlock
                        andCompletedBlock:(XBWebImageDownloaderCompletedBlock)completeBlock {
    //对于多个视图对同一个url做请求，operation只有一个，但保存相应的回调，回调会有多个，这样避免重复请求
    XBCallbacksDictionary *callback = [NSMutableDictionary new];
    callback[kProgressCallbackKey] = progressBlock;
    callback[kCompletedCallbackKey] = completeBlock;
    dispatch_barrier_sync(self.barrierQueue, ^{
        [self.callbackBlocks addObject:callback];
    });
    
    return callback;
}

- (NSArray *)callbacksForKey:(NSString *)key {
    __block NSMutableArray *callbacks = [NSMutableArray new];
    dispatch_barrier_sync(self.barrierQueue, ^{
        callbacks = [[self.callbackBlocks valueForKey:key] mutableCopy];
        //progress block maybe not set, is nil
        [callbacks removeObjectIdenticalTo:[NSNull null]];
    });
    
    return [callbacks copy];
}

- (NSArray *)progressCallbacks {
    return [self callbacksForKey:kProgressCallbackKey];
}

- (NSArray *)completedCallbacks {
    return [self callbacksForKey:kCompletedCallbackKey];
}

- (void)callProgressBlockWithReceivedSize:(NSUInteger)receivedSize andExpectedSize:(NSInteger)expectedSize {
    NSArray *blocks = [self progressCallbacks];
    dispatch_main_async_safe(^{
        for (XBWebImageDownloaderProgressBlock progressBlock in blocks) {
            progressBlock(receivedSize, expectedSize, self.request.URL);
        }
    })
}

- (void)callCompletedBlockWithError:(NSError *)error {
    [self callCompletedBlockWithImage:nil data:nil error:error andFinished:YES];
}

- (void)callCompletedBlockWithImage:(UIImage *)image
                               data:(NSData *)data
                              error:(NSError *)error
                        andFinished:(BOOL)finished {
    //注意：如果[self completedCallbacks]放在dispatch_main_async_safe里面，就有可能出问题，clear方法会remove这些block，这样就无法保证操作的原子性。因此取block时，可能block已经被删除了，无法发生回调。
    NSArray *blocks = [self completedCallbacks];
    dispatch_main_async_safe(^{
        for (XBWebImageDownloaderCompletedBlock completedBlock in blocks) {
            completedBlock(image, data, error, finished);
        }
    });
}

#pragma mark -

//编程指南：https://developer.apple.com/library/content/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationObjects/OperationObjects.html
- (void)start {
    //isReady为NO，start方法不会执行,比如operation有其他dependencies，那么isReady就是NO，正常情况下，你不需要重写isReady，除非自定义的operation中有其他因素会影响isReady的状态
    //operation的执行影响因素：1、isReady；2、queuePriority。isReady都是YES，则优先级高的先执行
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            [self clear];
        }
        
        self.dataTask = [self.unownedSession dataTaskWithRequest:self.request];
        self.executing = YES;
        [self.dataTask resume];
        
        if (self.dataTask) {
            [self callProgressBlockWithReceivedSize:0 andExpectedSize:NSURLResponseUnknownLength];
        } else {
            [self callCompletedBlockWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSURLLocalizedNameKey: @"Session connection can't be initialized"}]];
        }
    }
}


#pragma mark - Operation Status

- (void)setFinished:(BOOL)finished {
    //手动调用kvo，应该是automaticallyNotifiesObserversOfFinished返回的是NO，自动调用被关闭了https://objccn.io/issue-7-3/ ,http://stackoverflow.com/questions/3573236/why-does-nsoperation-disable-automatic-key-value-observing
    [self willChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
    _finished = finished;
    [self didChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
    _executing = executing;
    [self didChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
}

//isConcurrent To be deprecated; use and override 'asynchronous' below
- (BOOL)isAsynchronous {
    //设置同步还是异步，同步情况下不需要reimplement上面两个参数
    return YES;
}

- (BOOL)cancel:(id)callback {
    //回调可能有多个，只有当所有回调被清楚，表明所有的请求被取消了
    __block BOOL shouldCancel = NO;
    dispatch_barrier_sync(self.barrierQueue, ^{
        [self.callbackBlocks removeObject:callback];
        if (self.callbackBlocks.count == 0) {
            shouldCancel = YES;
        }
    });
    if (shouldCancel) {
        [self cancel];
    }
    
    return shouldCancel;
}

- (void)cancel {
    @synchronized (self) {
        [self cancelInternal];
    }
}

- (void)cancelInternal {
    if (self.isFinished) {return;}
    [super cancel];
    
    if (self.dataTask) {
        [self.dataTask cancel];
        if (self.isExecuting) {self.executing = NO;}
        if (!self.isFinished) {self.finished = YES;}
    }
    
    [self clear];
}

- (void)done {
    self.executing = NO;
    self.finished = YES;
    [self clear];
}

- (void)clear { //清理操作
    dispatch_barrier_async(self.barrierQueue, ^{
        [self.callbackBlocks removeAllObjects];
    });
    
    _request = nil;
    _dataTask = nil;
    _imageData = nil;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSInteger statusCode = 0;
    if ([response respondsToSelector:@selector(statusCode)]) {
        statusCode = ((NSHTTPURLResponse *)response).statusCode;
    }
    
    // '304 Not Modified' 客户端有缓存的图片，指的是URL Cache
    if (statusCode < 400 && statusCode != 304) {
        NSInteger length = response.expectedContentLength < 0 ? 0 : (NSInteger)response.expectedContentLength;
        self.expectedSize = length;
        self.imageData = [NSMutableData dataWithCapacity:length];
        [self callProgressBlockWithReceivedSize:0 andExpectedSize:self.expectedSize];
    } else {
        if (statusCode == 304) {NSLog(@"statusCode:304");}
        
        [self cancel];
        [self callCompletedBlockWithError:[NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:nil]];
    }
    
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    //This delegate method may be called more than once, and each call provides only data received since the previous call.
    [self.imageData appendData:data];
    [self callProgressBlockWithReceivedSize:self.imageData.length andExpectedSize:self.expectedSize];
}


- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler {
    NSCachedURLResponse *cachedResponse = proposedResponse;
    if (self.request.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData) {
        cachedResponse = nil;
    }
    
    if (completionHandler) {
        completionHandler(cachedResponse);
    }
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    //http://stackoverflow.com/questions/26984241/nsurlsessiontaskdelegate-method-urlsessiontaskdidcompletewitherror-never-call
    
    if (error) {
        [self callCompletedBlockWithError:error];
    } else {
        UIImage *image = [UIImage imageWithData:self.imageData];
        if (CGSizeEqualToSize(image.size, CGSizeZero)) {
            [self callCompletedBlockWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSURLLocalizedNameKey: @"image size is zero"}]];
        } else {
            [self callCompletedBlockWithImage:image data:self.imageData error:error andFinished:YES];
        }
        
        [self done];
    }
}



@end
