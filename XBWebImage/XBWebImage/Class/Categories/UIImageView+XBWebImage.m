//
//  UIImageView+XBWebImage.m
//  XBWebImage
//
//  Created by xiabob on 17/2/23.
//
//

#import "UIImageView+XBWebImage.h"
#import "UIView+XBWebImage.h"

@implementation UIImageView (XBWebImage)

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
    [self xb_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                        operationKey:NSStringFromClass([self class])
                       setImageBlock:nil
                            progress:progressBlock
                           completed:completedBlock];
}

@end
