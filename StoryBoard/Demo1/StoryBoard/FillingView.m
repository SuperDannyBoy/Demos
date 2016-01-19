//
//  FillingView.m
//  StoryBoard
//
//  Created by SuperDanny on 15/8/17.
//  Copyright © 2015年 SuperDanny. All rights reserved.
//

#import "FillingView.h"

@implementation FillingView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //setFill 为当前上下文设置要填充的颜色
    [[UIColor brownColor] setFill];
    //UIRectFill 按照刚才设置的颜色进行填充矩形
    UIRectFill(rect);
    
    //setStroke 设置图形上下文描边颜色
    [[UIColor whiteColor] setStroke];
    //UIRectFrame 矩形描边
    UIRectFrame(CGRectMake(20, 30+64, 100, 300));
    
    
}

@end
