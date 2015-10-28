//
//  ViewController.m
//  图片压缩
//
//  Created by SuperDanny on 15/10/23.
//  Copyright © 2015年 SuperDanny. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSData *da = [self resetSizeOfImageData:[UIImage imageNamed:@"IMG_0509.jpg"] maxSize:30];
    NSByteCountFormatter *f = [[NSByteCountFormatter alloc] init];
    f.countStyle = NSByteCountFormatterCountStyleFile;
    f.allowedUnits = NSByteCountFormatterUseKB;
    NSLog(@"%@,%@",[f stringFromByteCount:UIImagePNGRepresentation([UIImage imageNamed:@"IMG_0509.jpg"]).length], [f stringFromByteCount:da.length]);
    UIImage *ima = [UIImage imageWithData:da];
    
    UIImageView *img = [[UIImageView alloc] initWithImage:ima];
    img.frame = CGRectMake(0, 0, 240, 320);
    
    [self.view addSubview:img];
    
    UIImageView *imgSource = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IMG_0509.jpg"]];
    imgSource.frame = CGRectMake(0, 330, 240, 320);
    
    [self.view addSubview:imgSource];
    
    [UIColor colorWithRed:0.443 green:0.549 blue:0.000 alpha:1.000];
    
}

- (NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize
{
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
    
    //调整大小
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    NSUInteger sizeOrigin = [imageData length];
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    if (sizeOriginKB > maxSize) {
        NSData *finallImageData = UIImageJPEGRepresentation(newImage,0.50);
        return finallImageData;
    }
    
    return imageData;
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
