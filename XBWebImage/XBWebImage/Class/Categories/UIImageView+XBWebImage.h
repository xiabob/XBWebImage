//
//  UIImageView+XBWebImage.h
//  XBWebImage
//
//  Created by xiabob on 17/2/23.
//
//

#import <UIKit/UIKit.h>
#import "XBWebImageManager.h"

@interface UIImageView (XBWebImage)

- (void)xb_setImageWithURL:(nullable NSString *)url;

- (void)xb_setImageWithURL:(nullable NSString *)url
                   options:(XBWebImageOptions)options;

- (void)xb_setImageWithURL:(nullable NSString *)url
          placeholderImage:(nullable UIImage *)placeholder;

- (void)xb_setImageWithURL:(nullable NSString *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(XBWebImageOptions)options;

- (void)xb_setImageWithURL:(nullable NSString *)url
                 completed:(nullable XBWebImageExternalCompletedBlock)completedBlock;

- (void)xb_setImageWithURL:(nullable NSString *)url
          placeholderImage:(nullable UIImage *)placeholder
                 completed:(nullable XBWebImageExternalCompletedBlock)completedBlock;

- (void)xb_setImageWithURL:(nullable NSString *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(XBWebImageOptions)options
                 completed:(nullable XBWebImageExternalCompletedBlock)completedBlock;

- (void)xb_setImageWithURL:(nullable NSString *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(XBWebImageOptions)options
                  progress:(nullable XBWebImageDownloaderProgressBlock)progressBlock
                 completed:(nullable XBWebImageExternalCompletedBlock)completedBlock;

@end
