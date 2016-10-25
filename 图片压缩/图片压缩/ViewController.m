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
    
    UIScrollView *scrol = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrol];
    
    //降质量图片
    NSData *da = [self resetSizeOfImageData:[UIImage imageNamed:@"IMG_0509.jpg"] maxSize:30];
    NSByteCountFormatter *f = [[NSByteCountFormatter alloc] init];
    f.countStyle = NSByteCountFormatterCountStyleFile;
    f.allowedUnits = NSByteCountFormatterUseKB;
    NSLog(@"%@,%@",[f stringFromByteCount:UIImagePNGRepresentation([UIImage imageNamed:@"IMG_0509.jpg"]).length], [f stringFromByteCount:da.length]);
    UIImage *ima = [UIImage imageWithData:da];
    
    _lowImg = [[UIImageView alloc] initWithImage:ima];
    _lowImg.frame = CGRectMake(0, 0, 240, 320);
    
    [scrol addSubview:_lowImg];
    
    UILabel *labLow = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_lowImg.frame)+10, CGRectGetWidth(_lowImg.frame), 20)];
    labLow.text = [NSString stringWithFormat:@"压缩之后大小：%@", [f stringFromByteCount:da.length]];
    [scrol addSubview:labLow];
    
    //原图片
    UIImageView *imgSource = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IMG_0509.jpg"]];
    imgSource.frame = CGRectMake(0, CGRectGetMaxY(labLow.frame)+20, 240, 320);
    
    [scrol addSubview:imgSource];
    
    UILabel *labSource = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imgSource.frame)+10, CGRectGetWidth(imgSource.frame), 20)];
    labSource.text = [NSString stringWithFormat:@"原图大小：%@", [f stringFromByteCount:UIImagePNGRepresentation([UIImage imageNamed:@"IMG_0509.jpg"]).length]];
    [scrol addSubview:labSource];
    
    //图片增加保存本地功能
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_lowImg.frame)+10, 100, 120, 40)];
    [btn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"保存压缩图片" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor orangeColor];
    [scrol addSubview:btn];
    
    scrol.contentSize = CGSizeMake(CGRectGetMaxX(btn.frame)+10, CGRectGetMaxY(labSource.frame)+10);
}

- (void)save {
    // 保存图片到相册中
    SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
    UIImageWriteToSavedPhotosAlbum(_lowImg.image, self, selectorToCall, NULL);
}

//保存图片后到相册后，调用的相关方法，查看是否保存成功
- (void)imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil) {
        [[[UIAlertView alloc] initWithTitle:@"提示"
                                    message:@"保存成功"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil, nil] show];
        NSLog(@"Image was saved successfully.");
    } else {
        NSLog(@"An error happened while saving the image.");
        NSLog(@"Error = %@", paramError);
    }
}

- (NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize {
    //先判断当前质量是否满足要求，不满足再进行压缩
    __block NSData *finallImageData = UIImageJPEGRepresentation(source_image,1.0);
    NSUInteger sizeOrigin   = finallImageData.length;
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    
    if (sizeOriginKB <= maxSize) {
        return finallImageData;
    }
    
    //先调整分辨率
    CGSize defaultSize = CGSizeMake(1024, 1024);
    UIImage *newImage = [self newSizeImage:defaultSize image:source_image];
    
    finallImageData = UIImageJPEGRepresentation(newImage,1.0);
    
    //保存压缩系数
    NSMutableArray *compressionQualityArr = [NSMutableArray array];
    CGFloat avg   = 1.0/250;
    CGFloat value = avg;
    for (int i = 250; i >= 1; i--) {
        value = i*avg;
        [compressionQualityArr addObject:@(value)];
    }
    
    /*
     调整大小
     说明：压缩系数数组compressionQualityArr是从大到小存储。
     */
    //思路：使用二分法搜索
    finallImageData = [self halfFuntion:compressionQualityArr image:newImage sourceData:finallImageData maxSize:maxSize];
    //如果还是未能压缩到指定大小，则进行降分辨率
    while (finallImageData.length == 0) {
        //每次降100分辨率
        if (defaultSize.width-100 <= 0 || defaultSize.height-100 <= 0) {
            break;
        }
        defaultSize = CGSizeMake(defaultSize.width-100, defaultSize.height-100);
        UIImage *image = [self newSizeImage:defaultSize
                                      image:[UIImage imageWithData:UIImageJPEGRepresentation(newImage,[[compressionQualityArr lastObject] floatValue])]];
        finallImageData = [self halfFuntion:compressionQualityArr image:image sourceData:UIImageJPEGRepresentation(image,1.0) maxSize:maxSize];
    }
    return finallImageData;
}

#pragma mark 调整图片分辨率/尺寸（等比例缩放）
- (UIImage *)newSizeImage:(CGSize)size image:(UIImage *)source_image {
    CGSize newSize = CGSizeMake(source_image.size.width, source_image.size.height);
    
    CGFloat tempHeight = newSize.height / size.height;
    CGFloat tempWidth = newSize.width / size.width;
    
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
    return newImage;
}

#pragma mark 二分法
- (NSData *)halfFuntion:(NSArray *)arr image:(UIImage *)image sourceData:(NSData *)finallImageData maxSize:(NSInteger)maxSize {
    NSData *tempData = [NSData data];
    NSUInteger start = 0;
    NSUInteger end = arr.count - 1;
    NSUInteger index = 0;
    
    NSUInteger difference = NSIntegerMax;
    while(start <= end) {
        index = start + (end - start)/2;
        
        finallImageData = UIImageJPEGRepresentation(image,[arr[index] floatValue]);
        
        NSUInteger sizeOrigin = finallImageData.length;
        NSUInteger sizeOriginKB = sizeOrigin / 1024;
        NSLog(@"当前降到的质量：%ld", (unsigned long)sizeOriginKB);
        NSLog(@"%lu----%lf", (unsigned long)index, [arr[index] floatValue]);
        
        if (sizeOriginKB > maxSize) {
            start = index + 1;
        } else if (sizeOriginKB < maxSize) {
            if (maxSize-sizeOriginKB < difference) {
                difference = maxSize-sizeOriginKB;
                tempData = finallImageData;
            }
            end = index - 1;
        } else {
            break;
        }
    }
    return tempData;
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
