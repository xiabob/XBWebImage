//
//  XBWebImageCache.h
//  XBWebImage
//
//  Created by xiabob on 17/2/22.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XBWebImageCacheType) {
    /** get image by download */
    XBWebImageCacheTypeNone,
    
    /** get image from memory */
    XBWebImageCacheTypeMemory,
    
    /** get image from disk */
    XBWebImageCacheTypeDisk,
};

@interface XBWebImageCache : NSObject

+ (instancetype)sharedCache;

- (UIImage *)memoryCacheForKey:(NSString *)key;
- (UIImage *)diskCacheForKey:(NSString *)key;
- (void)saveImage:(UIImage *)image imageData:(NSData *)data toDisk:(BOOL)saveToDisk forKey:(NSString *)key;

@end
