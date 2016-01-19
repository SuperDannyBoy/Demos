//
//  ThreeViewController.m
//  StoryBoard
//
//  Created by SuperDanny on 15/8/19.
//  Copyright © 2015年 SuperDanny. All rights reserved.
//

#import "ThreeViewController.h"

@interface ThreeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ThreeViewController

- (void)viewDidLoad {
    if (_str) {
        self.label.text = _str;
    }
}

- (IBAction)buttonActoin:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"StoryboardOne" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"test1"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender {
    //原视图控制器
    NSLog(@"Source Controller = %@", [segue sourceViewController]);
    //目标视图控制器
    NSLog(@"Destination Controller = %@", [segue destinationViewController]);
    //过渡标识
    NSLog(@"Segue Identifier = %@", [segue identifier]);
}

@end
