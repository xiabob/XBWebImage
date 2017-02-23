//
//  CALayer+XBWebImage.m
//  XBWebImage
//
//  Created by xiabob on 17/2/23.
//
//

#import "CALayer+XBWebImage.h"
#import "objc/runtime.h"

@implementation CALayer (XBWebImage)

- (void)xb_setImageWithURL:(nullable NSString *)url {
    [self xb_setImageWithURL:url placeholderImage:nil];
}

- (void)xb_setImageWithURL:(nullable NSString *)url
                   options:(XBWebImageOptions)options {
    [self xb_setImageWithURL:url placeholderImage:nil options:options];
}

- (void)xb_setImageWithURL:(nullable NSString *)url
          placeholderImage:(nullable UIImage *)placeholder {
    [self xb_setImageWithURL:url placeholderImage:placeholder options:0];
}

- (void)xb_setImageWithURL:(nullable NSString *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(XBWebImageOptions)options {
    [self xb_setImageWithURL:url placeholderImage:placeholder options:options completed:nil];
}

- (void)xb_setImageWithURL:(nullable NSString *)url
                 completed:(nullable XBWebImageExternalCompletedBlock)completedBlock {
    [self xb_setImageWithURL:url placeholderImage:nil completed:completedBlock];
}

- (void)xb_setImageWithURL:(nullable NSString *)url
          placeholderImage:(nullable UIImage *)placeholder
                 completed:(nullable XBWebImageExternalCompletedBlock)completedBlock {
    [self xb_setImageWithURL:url placeholderImage:placeholder options:0 completed:completedBlock];
}


- (void)xb_setImageWithURL:(nullable NSString *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(XBWebImageOptions)options
                 completed:(nullable XBWebImageExternalCompletedBlock)completedBlock {
    [self xb_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)xb_setImageWithURL:(nullable NSString *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(XBWebImageOptions)options
                  progress:(nullable XBWebImageDownloaderProgressBlock)progressBlock
                 completed:(nullable XBWebImageExternalCompletedBlock)completedBlock {
    NSString *validOperationKey = NSStringFromClass([self class]);
    [self xb_cancelContainerOperationWithKey:validOperationKey];
    dispatch_main_async_safe(^{
        [self xb_setImage:placeholder imageData:nil];
    });
    
    if (url.length > 0) {
        __weak typeof(self) wself = self;
        NSOperation *operation = [[XBWebImageManager sharedManager] loadImageWithUrl:url options:options progress:progressBlock completed:^(UIImage *image, NSData *data, XBWebImageCacheType imageCache, NSError *error, BOOL finished, NSURL *imageUrl) {
            __strong typeof(wself) sself = wself;
            if (!sself) {return ;}
            
            dispatch_main_async_safe(^{
                if (!sself) {return ;}
                [sself xb_setImage:image imageData:data];
                if (finished && completedBlock) {
                    completedBlock(image, imageCache, error, imageUrl);
                }
            });
            
        }];
        [self xb_setContainerOperation:operation forKey:validOperationKey];
    } else {
        dispatch_main_async_safe(^{
            if (completedBlock) {
                completedBlock(nil, XBWebImageCacheTypeNone, [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSURLLocalizedNameKey: @"url can't be empty"}], nil);
            }
        });
    }
}

- (void)xb_setImage:(UIImage *)image imageData:(NSData *)imageData {
    self.contents = (__bridge id _Nullable)([image CGImage]);
    //[self setNeedsDisplay]; 导致contents被重新设置了
}


#pragma mark - Container Operation

- (NSMutableDictionary *)containerOperationDictionary {
    NSMutableDictionary *operations = objc_getAssociatedObject(self, @selector(containerOperationDictionary));
    if (operations) {
        return operations;
    }
    
    objc_setAssociatedObject(self, @selector(containerOperationDictionary), [NSMutableDictionary new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return operations;
}

- (void)xb_setContainerOperation:(NSOperation *)operation forKey:(NSString *)key {
    if (key.length > 0) {
        [self xb_cancelContainerOperationWithKey:key];
        if (operation) {
            NSMutableDictionary *operationDictionary = [self containerOperationDictionary];
            operationDictionary[key] = operation;
        }
    }
}

- (void)xb_cancelContainerOperationWithKey:(NSString *)key {
    if (key.length > 0) {
        NSMutableDictionary *operationDictionary = [self containerOperationDictionary];
        NSOperation *operation = operationDictionary[key];
        if (operation) {
            [operation cancel];
        }
        [operationDictionary removeObjectForKey:key];
    }
    
}

@end
