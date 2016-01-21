//
//  ViewController.m
//  NOTIFICATIONS
//
//  Created by SuperDanny on 16/1/21.
//  Copyright © 2016年 SuperDanny. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //需要事先在项目中的info.plist中添加 URL types 并设置一项URL Schemes为prefs
    
    NSURL *url = [NSURL URLWithString:@"prefs:root=NOTIFICATIONS_ID"];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
