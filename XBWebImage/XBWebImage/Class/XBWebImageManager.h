//
//  XBWebImageManager.h
//  XBWebImage
//
//  Created by xiabob on 17/2/22.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XBWebImageCache.h"
#import "XBWebImageDownloaderOperation.h"

typedef NS_OPTIONS(NSUInteger, XBWebImageOptions) {
    /** set operation low queuePriority */
    XBWebImageOptionsLowPriority = 1<<0,
    
    /** set operation high queuePriority */
    XBWebImageOptionsHighPriority = 1<<1,
};

typedef void(^XBWebImageExternalCompletedBlock)(UIImage *image, XBWebImageCacheType imageCache, NSError *error, NSURL *imageUrl);
typedef void(^XBWebImageInternalCompletedBlock)(UIImage *image, NSData *data, XBWebImageCacheType imageCache, NSError *error, BOOL finished, NSURL *imageUrl);



@interface XBWebImageManager : NSObject

/** 是否提前将图片解码，默认是YES */
@property (nonatomic, assign) BOOL shouldDecodeImage;


+ (instancetype)sharedManager;

- (NSOperation *)loadImageWithUrl:(NSString *)urlString
                          options:(XBWebImageOptions)options
                         progress:(XBWebImageDownloaderProgressBlock)progressBlock
                        completed:(XBWebImageInternalCompletedBlock)completedBlock;

@end
