//
//  ViewController.m
//  图片压缩
//
//  Created by SuperDanny on 15/10/23.
//  Copyright © 2015年 SuperDanny. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *lowImg;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //降质量图片
    NSData *da = [self resetSizeOfImageData:[UIImage imageNamed:@"IMG_0509.jpg"] maxSize:30];
    NSByteCountFormatter *f = [[NSByteCountFormatter alloc] init];
    f.countStyle = NSByteCountFormatterCountStyleFile;
    f.allowedUnits = NSByteCountFormatterUseKB;
    NSLog(@"%@,%@",[f stringFromByteCount:UIImagePNGRepresentation([UIImage imageNamed:@"IMG_0509.jpg"]).length], [f stringFromByteCount:da.length]);
    UIImage *ima = [UIImage imageWithData:da];
    
    _lowImg = [[UIImageView alloc] initWithImage:ima];
    _lowImg.frame = CGRectMake(0, 0, 240, 320);
    
    [self.view addSubview:_lowImg];
    
    //原图片
    UIImageView *imgSource = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IMG_0509.jpg"]];
    imgSource.frame = CGRectMake(0, 330, 240, 320);
    
    [self.view addSubview:imgSource];
    
    //图片增加保存本地功能
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_lowImg.frame)+10, 100, 120, 40)];
    [btn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"保存压缩图片" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:btn];
}

- (void)save {
    // 保存图片到相册中
    SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
    UIImageWriteToSavedPhotosAlbum(_lowImg.image, self, selectorToCall, NULL);
}

//保存图片后到相册后，调用的相关方法，查看是否保存成功
- (void)imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        NSLog(@"Image was saved successfully.");
    } else {
        NSLog(@"An error happened while saving the image.");
        NSLog(@"Error = %@", paramError);
    }
}

- (NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize {
    //先调整分辨率
    CGSize newSize = CGSizeMake(source_image.size.width, source_image.size.height);
    
    CGFloat tempHeight = newSize.height / 1024;
    CGFloat tempWidth = newSize.width / 1024;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(source_image.size.width / tempWidth, source_image.size.height / tempWidth);
    }
    else if (tempHeight > 1.0 && tempWidth < tempHeight){
        newSize = CGSizeMake(source_image.size.width / tempHeight, source_image.size.height / tempHeight);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [source_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    NSMutableArray *compressionQualityArr = [NSMutableArray array];
    CGFloat avg = 1.0/250;
    CGFloat value = avg;
    for (int i = 250; i >= 1; i--) {
        value = i*avg;
        [compressionQualityArr addObject:@(value)];
    }
    //调整大小
    __block NSData *finallImageData = UIImageJPEGRepresentation(newImage,1.0);
    [compressionQualityArr enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger sizeOrigin = [finallImageData length];
        NSUInteger sizeOriginKB = [[NSByteCountFormatter stringFromByteCount:sizeOrigin countStyle:NSByteCountFormatterCountStyleBinary] integerValue];
        NSLog(@"当前降到的质量：%ld", sizeOriginKB);
        if (sizeOriginKB > maxSize) {
            NSLog(@"%ld----%lf", idx, [obj floatValue]);
            finallImageData = UIImageJPEGRepresentation(newImage,[obj floatValue]);
        } else {
            *stop = YES;
        }
    }];
    return finallImageData;
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
