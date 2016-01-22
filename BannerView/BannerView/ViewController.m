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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *tempArr = @[@"http://ww1.sinaimg.cn/mw690/81f8a509gw1evdwqs4q4cj20xc0xbjyw.jpg",
                         @"http://ww1.sinaimg.cn/mw690/81f8a509gw1evdwqs4q4cj20xc0xbjyw.jpg",
//                         @"http://ww1.sinaimg.cn/mw690/81f8a509gw1evdwqs4q4cj20xc0xbjyw.jpg",
//                         @"http://ww1.sinaimg.cn/mw690/81f8a509gw1evdwqs4q4cj20xc0xbjyw.jpg"
                         ];
    NSMutableArray *itemArr = [NSMutableArray array];
    for (NSUInteger i = 0; i < tempArr.count; i++) {
        [itemArr addObject:kItemInfoDic(@"", tempArr[i])];
    }
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 300);
    DDPageView *banner = [[DDPageView alloc] initWithFrame:rect delegate:self imageItems:itemArr isAuto:YES];
    [self.view addSubview:banner];
}

- (void)foucusView:(DDPageView *)pageView didSelectItem:(DDPageItem *)item index:(NSInteger)index {
    NSLog(@"%@----点击第%d张图", pageView, index);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
