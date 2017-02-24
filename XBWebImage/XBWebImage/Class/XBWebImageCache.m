//
//  XBWebImageCache.m
//  XBWebImage
//
//  Created by xiabob on 17/2/22.
//
//

#import "XBWebImageCache.h"
#import "XBWebImageDecoder.h"
#import <CommonCrypto/CommonDigest.h>

@interface XBWebImageCache()

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic, strong) dispatch_queue_t ioQueue;
@property (nonatomic, strong) XBWebImageDecoder *decoder;

@end

@implementation XBWebImageCache

+ (instancetype)sharedCache {
    static XBWebImageCache *cache;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        cache = [XBWebImageCache new];
    });
    return cache;
}

- (instancetype)init {
    if (self = [super init]) {
        _lock = [NSLock new];
        _memoryCache = [NSCache new];
        _memoryCache.totalCostLimit = 1024*1024*50;
        _memoryCache.countLimit = 100;
        _ioQueue = dispatch_queue_create("com.xiabob.XBWebImageCache.io", DISPATCH_QUEUE_CONCURRENT);
        _decoder = [XBWebImageDecoder new];
        
        [self addNotification];
    }
    
    return self;
}

- (void)dealloc {
    [self removeNotification];
}

- (void)setTotalCostLimit:(NSUInteger)totalCostLimit {
    [self.lock lock];
    _totalCostLimit = totalCostLimit;
    _memoryCache.totalCostLimit = _totalCostLimit;
    [self.lock unlock];
}

- (void)setCountLimit:(NSUInteger)countLimit {
    [self.lock lock];
    _countLimit = countLimit;
    _memoryCache.countLimit = countLimit;
    [self.lock unlock];
}

- (NSString *)diskCacheDocument {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    return [path stringByAppendingPathComponent:@"XBWebImageCache"];
}

- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = key.UTF8String;
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

- (NSString *)cachedPathForKey:(NSString *)key {
    NSString *fileName = [self cachedFileNameForKey:key];
    return [[self diskCacheDocument] stringByAppendingPathComponent:fileName];
}

#pragma mark - cache operation

- (UIImage *)memoryCacheForKey:(NSString *)key {
    [self.lock lock];
    UIImage *image = [self.memoryCache objectForKey:key];
    [self.lock unlock];
    
    return image;
}

- (UIImage *)diskCacheForKey:(NSString *)key {
    [self.lock lock];
    NSData *imageData = [NSData dataWithContentsOfFile:[self cachedPathForKey:key]];
    UIImage *image = [UIImage imageWithData:imageData];
    if (self.shouldDecodeImage) {
        image = [self.decoder decodeImage:image];
    }
    [self saveImgaeToMemory:image forKey:key];
    [self.lock unlock];
    
    return image;
}

- (void)saveImage:(UIImage *)image imageData:(NSData *)data toDisk:(BOOL)saveToDisk forKey:(NSString *)key {
    dispatch_async(self.ioQueue, ^{
        [self.lock lock];
        [self saveImgaeToMemory:image forKey:key];
        
        if (data) {
            NSFileManager *manager = [NSFileManager defaultManager];
            if (![manager fileExistsAtPath:[self diskCacheDocument]]) {
                [manager createDirectoryAtPath:[self diskCacheDocument] withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            [manager createFileAtPath:[self cachedPathForKey:key] contents:data attributes:nil];
        }
        
        [self.lock unlock];
    });
}

- (void)saveImgaeToMemory:(UIImage *)image forKey:(NSString *)key {
    if (image) {
        //粗略的计算
        NSUInteger size = image.size.width * image.size.height;
        [self.memoryCache setObject:image forKey:key cost:size];
    }
}

#pragma mark - clear cache

- (void)clearMemoryCache {
    [self.lock lock];
    [self.memoryCache removeAllObjects];
    [self.lock unlock];
}

- (void)clearDiskCache:(XBClearCacheCompletedBlock)block {
    dispatch_async(self.ioQueue, ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:[self diskCacheDocument] error:nil];
        
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block();
            });
        }
    });
}

#pragma mark - notification

- (void)addNotification {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
//    [defaultCenter addObserver:self
//                      selector:@selector(clearMemoryCache)
//                          name:UIApplicationDidEnterBackgroundNotification
//                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(clearMemoryCache)
                          name:UIApplicationDidReceiveMemoryWarningNotification
                        object:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
