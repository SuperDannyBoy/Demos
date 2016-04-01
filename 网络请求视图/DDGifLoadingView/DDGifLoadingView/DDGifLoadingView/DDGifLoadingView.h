//
//  DDGifLoadingView.h
//  DDGifLoadingView
//
//  Created by SuperDanny on 16/4/1.
//  Copyright © 2016年 SuperDanny. All rights reserved.

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import <UIKit/UIKit.h>

@interface DDGifLoadingView : UIView

+ (void)show;
+ (void)showWithOverlay;

+ (void)dismiss;

+ (void)setGifWithImages:(NSArray *)images;
+ (void)setGifWithImageName:(NSString *)imageName;
+ (void)setGifWithURL:(NSURL *)gifUrl;

@end
