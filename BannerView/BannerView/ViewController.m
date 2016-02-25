//
//  ViewController.m
//  BannerView
//
//  Created by SuperDanny on 16/1/22.
//  Copyright © 2016年 SuperDanny. All rights reserved.
//

#import "ViewController.h"
#import "DDPageView.h"

@interface ViewController () <DDPageViewDelegate>

@property (nonatomic, strong) DDPageView *banner;

@end

@implementation ViewController

- (void)dealloc {
    [_banner stopTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)]];
    
    
    
    NSArray *tempArr = @[@"http://ww1.sinaimg.cn/mw690/81f8a509gw1evdwqs4q4cj20xc0xbjyw.jpg",
                         @"http://ww4.sinaimg.cn/mw690/81f8a509jw9ezzyqfk8o9j21kw0mjae3.jpg",
                         @"http://ww1.sinaimg.cn/mw690/81f8a509gw1ezzd0fwjiej21kw0mcwj5.jpg",
                         @"http://ww4.sinaimg.cn/mw690/81f8a509jw9ezzcyi6n8zj21kw0titig.jpg"];
    NSMutableArray *itemArr = [NSMutableArray array];
    for (NSUInteger i = 0; i < tempArr.count; i++) {
        [itemArr addObject:kItemInfoDic(@"", tempArr[i])];
    }
    CGRect rect = CGRectMake(0, 64, CGRectGetWidth([UIScreen mainScreen].bounds), 300);
//    _banner = [[DDPageView alloc] initWithFrame:rect delegate:self timeInterval:4 placeholderImage:@"placeholderImage1" imageArray:itemArr isAuto:YES];
    
    _banner = [[DDPageView alloc] initWithFrame:rect delegate:self timeInterval:4 placeholderImage:@"placeholderImage1" focusImageItems:itemArr[0],itemArr[1],itemArr[2],itemArr[3], nil];
    
    
    [self.view addSubview:_banner];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_banner.frame)+40, CGRectGetWidth(self.view.frame)-2*20, 40)];
    [btn setTitle:@"刷新数据" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor orangeColor];
    [btn addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)refresh {
    NSArray *tempArr = @[@"http://ww1.sinaimg.cn/mw690/81f8a509gw1evdwqs4q4cj20xc0xbjyw.jpg",
//                         @"http://ww4.sinaimg.cn/mw690/81f8a509jw9ezzyqfk8o9j21kw0mjae3.jpg",
//                         @"http://ww1.sinaimg.cn/mw690/81f8a509gw1ezzd0fwjiej21kw0mcwj5.jpg",
                         @"http://ww4.sinaimg.cn/mw690/81f8a509jw9ezzcyi6n8zj21kw0titig.jpg"];
    NSMutableArray *itemArr = [NSMutableArray array];
    for (NSUInteger i = 0; i < tempArr.count; i++) {
        [itemArr addObject:kItemInfoDic(@"", tempArr[i])];
    }
    [_banner reloadData:itemArr];
}

- (void)foucusView:(DDPageView *)pageView didSelectItem:(DDPageItem *)item index:(NSInteger)index {
    NSLog(@"%@----点击第%ld张图---url:%@", pageView, (long)index, item.imageURL);
}

- (void)foucusView:(DDPageView *)pageView currentItem:(NSInteger)index {
    NSLog(@"%@----第%ld张图", pageView, (long)index);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
