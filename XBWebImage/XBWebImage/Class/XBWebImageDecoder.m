//
//  XBWebImageDecoder.m
//  XBWebImage
//
//  Created by xiabob on 17/2/24.
//
//

#import "XBWebImageDecoder.h"

@implementation XBWebImageDecoder

- (UIImage *)decodeImage:(UIImage *)image {
    if (!image) {return nil;}
    
    //http://blog.leichunfeng.com/blog/2017/02/20/talking-about-the-decompression-of-the-image-in-ios/
    CGImageRef imageRef = image.CGImage;
    size_t width = CGImageGetWidth(imageRef); size_t height = CGImageGetHeight(imageRef);
    
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
    BOOL hasAlphaInfo = NO;
    if (alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaFirst ||
        alphaInfo == kCGImageAlphaLast) {
        hasAlphaInfo = YES;
    }
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    //for premultiplied ARGB or XRGB
    bitmapInfo |= hasAlphaInfo ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, CGColorSpaceCreateDeviceRGB(), bitmapInfo);
    if (!context) {return image;}
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); //decode
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    CFRelease(context);
    
    return [UIImage imageWithCGImage:newImageRef];
}

@end
