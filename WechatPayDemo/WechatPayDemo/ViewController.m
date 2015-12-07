//
//  ViewController.m
//  WechatPayDemo
//
//  Created by SuperDanny on 15/12/7.
//  Copyright © 2015年 SuperDanny. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)wechatPay:(id)sender {
    NSDictionary *orderDic = @{@"ExchangeNo": @"订单号：VR201508035968",
                               @"ExchangeObjectName": @"商品名称",
                               @"Price": @"0.01"};
    [WXApiRequestHandler sendReq:[[WXApiRequestHandler sharedManager] sendPay_demoWithOrderMessageDic:orderDic]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
