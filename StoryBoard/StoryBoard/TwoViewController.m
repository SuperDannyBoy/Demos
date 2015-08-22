//
//  TwoViewController.m
//  StoryBoard
//
//  Created by SuperDanny on 15/8/19.
//  Copyright © 2015年 SuperDanny. All rights reserved.
//

#import "TwoViewController.h"
#import "ThreeViewController.h"

@implementation TwoViewController

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender {
    //原视图控制器
    NSLog(@"Source Controller = %@", [segue sourceViewController]);
    //目标视图控制器
    NSLog(@"Destination Controller = %@", [segue destinationViewController]);
    //过渡标识
    NSLog(@"Segue Identifier = %@", [segue identifier]);
    ThreeViewController *vc = segue.destinationViewController;
    vc.str = @"dataStr";
}

@end
