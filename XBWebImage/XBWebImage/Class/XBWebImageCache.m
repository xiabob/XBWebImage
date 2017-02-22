//
//  XBWebImageCache.m
//  XBWebImage
//
//  Created by xiabob on 17/2/22.
//
//

#import "XBWebImageCache.h"

@implementation XBWebImageCache

+ (instancetype)sharedCache {
    static XBWebImageCache *cache;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        cache = [XBWebImageCache new];
    });
    return cache;
}


- (UIImage *)memoryCacheForKey:(NSString *)key {
    return nil;
}

- (UIImage *)diskCacheForKey:(NSString *)key {
    return nil;
}

- (void)saveImage:(UIImage *)image imageData:(NSData *)data toDisk:(BOOL)saveToDisk forKey:(NSString *)key {
    
}

@end
