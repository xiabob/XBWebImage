//
//  UIButton+XBWebImage.m
//  XBWebImage
//
//  Created by xiabob on 17/2/23.
//
//

#import "UIButton+XBWebImage.h"
#import "UIView+XBWebImage.h"

@implementation UIButton (XBWebImage)

#pragma mark - Image

- (void)xb_setImageWithURL:(nullable NSString *)url forState:(UIControlState)state {
    [self xb_setImageWithURL:url forState:state placeholderImage:nil options:0 completed:nil];
}

- (void)xb_setImageWithURL:(nullable NSString *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder {
    [self xb_setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:nil];
}

- (void)xb_setImageWithURL:(nullable NSString *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(XBWebImageOptions)options {
    [self xb_setImageWithURL:url forState:state placeholderImage:placeholder options:options completed:nil];
}

- (void)xb_setImageWithURL:(nullable NSString *)url forState:(UIControlState)state completed:(nullable XBWebImageExternalCompletedBlock)completedBlock {
    [self xb_setImageWithURL:url forState:state placeholderImage:nil options:0 completed:completedBlock];
}

- (void)xb_setImageWithURL:(nullable NSString *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder completed:(nullable XBWebImageExternalCompletedBlock)completedBlock {
    [self xb_setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)xb_setImageWithURL:(nullable NSString *)url
                  forState:(UIControlState)state
          placeholderImage:(nullable UIImage *)placeholder
                   options:(XBWebImageOptions)options
                 completed:(nullable XBWebImageExternalCompletedBlock)completedBlock {
    __weak typeof(self)weakSelf = self;
    [self xb_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                        operationKey:[NSString stringWithFormat:@"UIButtonImageOperation%@", @(state)]
                       setImageBlock:^(UIImage *image, NSData *imageData) {
                           [weakSelf setImage:image forState:state];
                       }
                            progress:nil
                           completed:completedBlock];
}

#pragma mark - Background image

- (void)xb_setBackgroundImageWithURL:(nullable NSString *)url forState:(UIControlState)state {
    [self xb_setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:nil];
}

- (void)xb_setBackgroundImageWithURL:(nullable NSString *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder {
    [self xb_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:nil];
}

- (void)xb_setBackgroundImageWithURL:(nullable NSString *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(XBWebImageOptions)options {
    [self xb_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options completed:nil];
}

- (void)xb_setBackgroundImageWithURL:(nullable NSString *)url forState:(UIControlState)state completed:(nullable XBWebImageExternalCompletedBlock)completedBlock {
    [self xb_setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:completedBlock];
}

- (void)xb_setBackgroundImageWithURL:(nullable NSString *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder completed:(nullable XBWebImageExternalCompletedBlock)completedBlock {
    [self xb_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)xb_setBackgroundImageWithURL:(nullable NSString *)url
                            forState:(UIControlState)state
                    placeholderImage:(nullable UIImage *)placeholder
                             options:(XBWebImageOptions)options
                           completed:(nullable XBWebImageExternalCompletedBlock)completedBlock {
    __weak typeof(self)weakSelf = self;
    [self xb_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                        operationKey:[NSString stringWithFormat:@"UIButtonBackgroundImageOperation%@", @(state)]
                       setImageBlock:^(UIImage *image, NSData *imageData) {
                           [weakSelf setBackgroundImage:image forState:state];
                       }
                            progress:nil
                           completed:completedBlock];
}

//- (void)xb_setImageLoadOperation:(id<SDWebImageOperation>)operation forState:(UIControlState)state {
//    [self xb_setImageLoadOperation:operation forKey:[NSString stringWithFormat:@"UIButtonImageOperation%@", @(state)]];
//}
//
//- (void)xb_cancelImageLoadForState:(UIControlState)state {
//    [self xb_cancelImageLoadOperationWithKey:[NSString stringWithFormat:@"UIButtonImageOperation%@", @(state)]];
//}
//
//- (void)xb_setBackgroundImageLoadOperation:(id<SDWebImageOperation>)operation forState:(UIControlState)state {
//    [self xb_setImageLoadOperation:operation forKey:[NSString stringWithFormat:@"UIButtonBackgroundImageOperation%@", @(state)]];
//}
//
//- (void)xb_cancelBackgroundImageLoadForState:(UIControlState)state {
//    [self xb_cancelImageLoadOperationWithKey:[NSString stringWithFormat:@"UIButtonBackgroundImageOperation%@", @(state)]];
//}
//
//- (SDStateImageURLDictionary *)imageURLStorage {
//    SDStateImageURLDictionary *storage = objc_getAssociatedObject(self, &imageURLStorageKey);
//    if (!storage) {
//        storage = [NSMutableDictionary dictionary];
//        objc_setAssociatedObject(self, &imageURLStorageKey, storage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    
//    return storage;
//}


@end
