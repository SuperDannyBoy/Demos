//
//  ViewController.m
//  代码注入
//
//  Created by SuperDanny on 16/1/8.
//  Copyright © 2016年 SuperDanny. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    lab.text = @"代码注入";
    lab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lab];
    lab.center = self.view.center;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
