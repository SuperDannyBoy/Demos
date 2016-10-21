//
//  DDActionsheet.m
//  YanYou
//
//  Created by SuperDanny on 16/7/21.
//  Copyright © 2016年 SuperDanny ( http://SuperDanny.link/ ). All rights reserved.
//

#import "DDActionsheet.h"

@interface DDActionsheet ()

@property (nonatomic, strong) UIView *bgView;

@end

@implementation DDActionsheet

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//        _bgView
        
    }
    return self;
}

@end
