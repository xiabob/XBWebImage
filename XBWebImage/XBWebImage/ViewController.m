//
//  ViewController.m
//  XBWebImage
//
//  Created by xiabob on 17/2/21.
//
//

#import "ViewController.h"
#import "XBWebImageDownloader.h"
#import "XBWebImageManager.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.clipsToBounds = YES;
    [self.view addSubview:_imageView];
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 30, 320, 10)];
    [self.view addSubview:_progressView];
    
//    [self dependenciesTest];
//    [self showTest];
    [self managerTest];
}

- (void)managerTest {
    XBWebImageManager *manager = [XBWebImageManager sharedManager];
    NSString *path = @"http://animetaste.net/wp-content/uploads/2013/06/%E5%A4%A7%E5%9B%BE.jpg";
    NSOperation *operation = [manager loadImageWithUrl:path options:0 progress:^(NSUInteger receivedSize, NSInteger expectedSize, NSURL *imageUrl) {
        [_progressView setProgress:(float)receivedSize/expectedSize];
    } completed:^(UIImage *image, NSData *data, XBWebImageCacheType imageCache, NSError *error, BOOL finished, NSURL *imageUrl) {
        NSLog(@"finished:%@", @(finished));
        _imageView.image = image;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       [operation cancel];
    });
}

- (void)showTest {
    XBWebImageDownloader *downloader = [XBWebImageDownloader sharedDownloader];
    NSString *path = @"http://animetaste.net/wp-content/uploads/2013/06/%E5%A4%A7%E5%9B%BE.jpg";
    [downloader downloadImageWithUrl:[NSURL URLWithString:path] options:0 progress:^(NSUInteger receivedSize, NSInteger expectedSize, NSURL *imageUrl) {
        [_progressView setProgress:(float)receivedSize/expectedSize];
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        NSLog(@"finished:%@", @(finished));
        _imageView.image = image;
    }];
}

- (void)dependenciesTest {
    XBWebImageDownloader *downloader = [XBWebImageDownloader sharedDownloader];
    [downloader setExecutionOrder:XBWebImageDownloaderExecutionOrderFILO];
    [downloader setMaxConcurrentDownload:1];
    NSString *path = @"http://img05.tooopen.com/images/20160121/tooopen_sy_155168162826.jpg";
    [downloader downloadImageWithUrl:[NSURL URLWithString:path] options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        NSLog(@"1 finished:%@", @(finished));
    }];
    
    path = @"http://img02.tooopen.com/images/20160408/tooopen_sy_158723161481.jpg";
    [downloader downloadImageWithUrl:[NSURL URLWithString:path] options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        NSLog(@"2 finished:%@", @(finished));
    }];
    
    path = @"http://animetaste.net/wp-content/uploads/2013/06/%E5%A4%A7%E5%9B%BE.jpg";
    [downloader downloadImageWithUrl:[NSURL URLWithString:path] options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        NSLog(@"3 finished:%@", @(finished));
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
