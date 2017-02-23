//
//  UIButton+XBWebImage.h
//  XBWebImage
//
//  Created by xiabob on 17/2/23.
//
//

#import <UIKit/UIKit.h>
#import "XBWebImageManager.h"

@interface UIButton (XBWebImage)

#pragma mark - Image

- (void)xb_setImageWithURL:(nullable NSString *)url forState:(UIControlState)state;

- (void)xb_setImageWithURL:(nullable NSString *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder;

- (void)xb_setImageWithURL:(nullable NSString *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(XBWebImageOptions)options;

- (void)xb_setImageWithURL:(nullable NSString *)url forState:(UIControlState)state completed:(nullable XBWebImageExternalCompletedBlock)completedBlock;

- (void)xb_setImageWithURL:(nullable NSString *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder completed:(nullable XBWebImageExternalCompletedBlock)completedBlock ;

- (void)xb_setImageWithURL:(nullable NSString *)url
                  forState:(UIControlState)state
          placeholderImage:(nullable UIImage *)placeholder
                   options:(XBWebImageOptions)options
                 completed:(nullable XBWebImageExternalCompletedBlock)completedBlock;

#pragma mark - Background image

- (void)xb_setBackgroundImageWithURL:(nullable NSString *)url forState:(UIControlState)state;

- (void)xb_setBackgroundImageWithURL:(nullable NSString *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder;

- (void)xb_setBackgroundImageWithURL:(nullable NSString *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(XBWebImageOptions)options ;

- (void)xb_setBackgroundImageWithURL:(nullable NSString *)url forState:(UIControlState)state completed:(nullable XBWebImageExternalCompletedBlock)completedBlock;

- (void)xb_setBackgroundImageWithURL:(nullable NSString *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder completed:(nullable XBWebImageExternalCompletedBlock)completedBlock ;

- (void)xb_setBackgroundImageWithURL:(nullable NSString *)url
                            forState:(UIControlState)state
                    placeholderImage:(nullable UIImage *)placeholder
                             options:(XBWebImageOptions)options
                           completed:(nullable XBWebImageExternalCompletedBlock)completedBlock ;

@end
