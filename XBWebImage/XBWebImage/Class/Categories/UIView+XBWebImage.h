//
//  UIView+XBWebImage.h
//  XBWebImage
//
//  Created by xiabob on 17/2/22.
//
//

#import <UIKit/UIKit.h>
#import "XBWebImageManager.h"

typedef void(^XBSetImageBlock)(UIImage *image, NSData *imageData);

@interface UIView (XBWebImage)


- (void)xb_internalSetImageWithURL:(NSString *)url
                  placeholderImage:(UIImage *)placeholder
                           options:(XBWebImageOptions)options
                      operationKey:(NSString *)operationKey
                     setImageBlock:(XBSetImageBlock)setImageBlock
                          progress:(XBWebImageDownloaderProgressBlock)progressBlock
                         completed:(XBWebImageExternalCompletedBlock)completedBlock;

@end
