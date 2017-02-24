//
//  XBWebImageManager.m
//  XBWebImage
//
//  Created by xiabob on 17/2/22.
//
//

#import "XBWebImageManager.h"
#import "XBWebImageDownloader.h"

@interface XBWebImageContainerOperation : NSOperation

@property (nonatomic, assign, getter=isCancelled) BOOL cancel;
@property (nonatomic, strong) XBWebImageDownloaderToken *token;

@end

@interface XBWebImageManager()

@property (nonatomic, strong) XBWebImageCache *imageCache;
@property (nonatomic, strong) XBWebImageDownloader *imageDownloader;
@property (nonatomic, strong) NSMutableArray *operationContainers;
@property (nonatomic, strong) dispatch_queue_t loadQueue;

@end

@implementation XBWebImageManager

+ (instancetype)sharedManager {
    static XBWebImageManager *manager;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [XBWebImageManager new];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.imageCache = [XBWebImageCache sharedCache];
        self.imageDownloader = [XBWebImageDownloader sharedDownloader];
        self.operationContainers = [NSMutableArray new];
        self.loadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    }
    
    return self;
}

- (void)safelyRemoveOperation:(XBWebImageContainerOperation *)operation {
    @synchronized (self.operationContainers) {
        if (operation) {
            [self.operationContainers removeObject:operation];
        }
    }
}

- (void)safelyAddOperation:(XBWebImageContainerOperation *)operation {
    @synchronized (self.operationContainers) {
        if (operation) {
            [self.operationContainers addObject:operation];
        }
    }
}


- (NSOperation *)loadImageWithUrl:(NSString *)urlString
                          options:(XBWebImageOptions)options
                         progress:(XBWebImageDownloaderProgressBlock)progressBlock
                        completed:(XBWebImageInternalCompletedBlock)completedBlock {
    __block XBWebImageContainerOperation *operation = [XBWebImageContainerOperation new];
    NSString *url = [urlString copy];
    NSURL *imageUrl = [NSURL URLWithString:url.length == 0 ? @"" : url];
    if (url.length < 8) { //for http://
        [self callCompletionBlockForOperation:operation
                                   completion:completedBlock
                                        error:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSURLLocalizedNameKey: @"invalid url string"}]
                                          url:imageUrl];
        return operation;
    }
    
    
    UIImage *image = [self.imageCache memoryCacheForKey:url];
    if (image) {
        [self callCompletionBlockForOperation:operation completion:completedBlock image:image data:nil error:nil cacheType:XBWebImageCacheTypeMemory finished:YES url:imageUrl];
        return operation;
    }
    
    dispatch_async(self.loadQueue, ^{
        UIImage *image = [self.imageCache diskCacheForKey:url];
        if (image) {
            [self callCompletionBlockForOperation:operation completion:completedBlock image:image data:nil error:nil cacheType:XBWebImageCacheTypeDisk finished:YES url:imageUrl];
        } else {
            //因为是异步，所以cancle可能在downloadImageWithUrl发生
            if (operation.isCancelled) {return ;}
            
            __weak typeof(self) wself = self;
            __weak typeof (XBWebImageContainerOperation *) woperation = operation;
            operation.token = [self.imageDownloader downloadImageWithUrl:imageUrl options:0 progress:progressBlock completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                __strong typeof(woperation) soperation = woperation;
                __strong typeof(wself) sself = wself;
                if (!sself || !soperation) {return ;}
                
                //main thread
                if (image && finished) {
                    [sself.imageCache saveImage:image imageData:data toDisk:YES forKey:url];
                }
                [sself callCompletionBlockForOperation:soperation completion:completedBlock image:image data:data error:error cacheType:XBWebImageCacheTypeNone finished:finished url:imageUrl];
                
                if (finished) {
                    [sself safelyRemoveOperation:soperation];
                }
            }];
            [self safelyAddOperation:operation];
        }
    });
    
    return operation;
}


- (void)callCompletionBlockForOperation:(NSOperation *)operation
                             completion:(XBWebImageInternalCompletedBlock)completionBlock
                                  error:(NSError *)error
                                    url:(NSURL *)url {
    [self callCompletionBlockForOperation:operation completion:completionBlock image:nil data:nil error:error cacheType:XBWebImageCacheTypeNone finished:YES url:url];
}

- (void)callCompletionBlockForOperation:(NSOperation *)operation
                             completion:(XBWebImageInternalCompletedBlock)completionBlock
                                  image:(UIImage *)image
                                   data:(NSData *)data
                                  error:(NSError *)error
                              cacheType:(XBWebImageCacheType)cacheType
                               finished:(BOOL)finished
                                    url:(NSURL *)url {
    if (completionBlock && operation && !operation.isCancelled) {
        dispatch_main_async_safe(^{
            completionBlock(image, data, cacheType, error, finished, url);
        });
    }
}

@end




@implementation XBWebImageContainerOperation

- (void)cancel {
    self.cancel = YES;
    
    if (self.token) {
        [[XBWebImageDownloader sharedDownloader] cancel:self.token];
        self.token = nil;
    }
    
    [[XBWebImageManager sharedManager] safelyRemoveOperation:self];
}

@end
