//
//  ViewController.m
//  XBWebImage
//
//  Created by xiabob on 17/2/21.
//
//

#import "ViewController.h"
#import "XBWebImage.h"

@interface MyImageCell : UITableViewCell

@property (nonatomic, strong) UIImageView *fullImageView;
@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) UIView *layerView;

- (void)refreshWithUrl:(NSString *)url;

@end

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *images;

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
    
    _images = @[@"http://animetaste.net/wp-content/uploads/2013/06/%E5%A4%A7%E5%9B%BE.jpg", @"http://img02.tooopen.com/images/20160408/tooopen_sy_158723161481.jpg", @"http://img05.tooopen.com/images/20160121/tooopen_sy_155168162826.jpg"];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [_tableView registerClass:[MyImageCell class] forCellReuseIdentifier:NSStringFromClass([MyImageCell class])];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
//    [self dependenciesTest];
//    [self showTest];
//    [self managerTest];
//    [self imageViewTest];
}

- (void)imageViewTest {
    NSString *path = @"http://animetaste.net/wp-content/uploads/2013/06/%E5%A4%A7%E5%9B%BE.jpg";
    [self.imageView xb_setImageWithURL:path placeholderImage:nil options:0 progress:^(NSUInteger receivedSize, NSInteger expectedSize, NSURL *imageUrl) {
        [_progressView setProgress:(float)receivedSize/expectedSize];
    } completed:^(UIImage *image, XBWebImageCacheType imageCache, NSError *error, NSURL *imageUrl) {
        NSLog(@"xb_setImageWithURL finish");
    }];
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



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyImageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MyImageCell class]) forIndexPath:indexPath];
    NSInteger index = indexPath.row % self.images.count;
    [cell refreshWithUrl:self.images[index]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


@implementation MyImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.fullImageView = [[UIImageView alloc] init];
        self.fullImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.fullImageView.clipsToBounds = YES;
        [self addSubview:self.fullImageView];
        
        self.layerView = [[UIView alloc] init];
        self.layerView.layer.contentsGravity = kCAGravityResizeAspect;
//        self.layerView.layer.masksToBounds = YES;
        self.layerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.layerView];
        
        self.tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        self.tagLabel.font = [UIFont systemFontOfSize:14];
        self.tagLabel.textColor = [UIColor redColor];
        self.tagLabel.numberOfLines = 0;
        [self addSubview:self.tagLabel];
    }
    
    return self;
}

- (void)refreshWithUrl:(NSString *)url {
//    self.fullImageView.frame = self.bounds;
//    [self.fullImageView xb_setImageWithURL:url completed:^(UIImage *image, XBWebImageCacheType imageCache, NSError *error, NSURL *imageUrl) {
//        self.tagLabel.text = imageUrl.absoluteString;
//    }];
    
    self.layerView.frame = self.bounds;
    [self.layerView.layer xb_setImageWithURL:url completed:^(UIImage *image, XBWebImageCacheType imageCache, NSError *error, NSURL *imageUrl) {
        self.tagLabel.text = imageUrl.absoluteString;
    }];

}

@end
