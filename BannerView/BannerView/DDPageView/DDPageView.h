//
//  DDPageView.h
//  BannerView
//
//  Created by SuperDanny on 16/1/22.
//  Copyright © 2016年 SuperDanny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPageItem.h"

typedef NS_ENUM(NSUInteger, DDPageType) {
    ///默认类型
    DDPageTypeDefault,
    ///显示点
    DDPageTypeDot,
    ///显示数量(页码)
    DDPageTypeNumber,
    ///显示标题
    DDPageTypeTitle,
};

@class DDPageView;

#pragma mark - DDPageViewDelegate
@protocol DDPageViewDelegate <NSObject>

@optional
- (void)foucusView:(DDPageView *)pageView didSelectItem:(DDPageItem *)item index:(NSInteger)index;
- (void)foucusView:(DDPageView *)pageView currentItem:(NSInteger)index;

@end

@interface DDPageView : UIView

///轮播图类型
@property (nonatomic, assign) DDPageType pageType;

- (id)initWithFrame:(CGRect)frame
           delegate:(id<DDPageViewDelegate>)delegate
       timeInterval:(NSTimeInterval)time
   placeholderImage:(NSString *)placeholderImage
         imageArray:(NSArray *)array
             isAuto:(BOOL)isAuto;

- (id)initWithFrame:(CGRect)frame
           delegate:(id<DDPageViewDelegate>)delegate
       timeInterval:(NSTimeInterval)time
   placeholderImage:(NSString *)placeholderImage
    focusImageItems:(DDPageItem *)items, ... NS_REQUIRES_NIL_TERMINATION;

- (id)initWithFrame:(CGRect)frame
           delegate:(id<DDPageViewDelegate>)delegate
       timeInterval:(NSTimeInterval)time
   placeholderImage:(NSString *)placeholderImage
         imageArray:(NSArray *)array;

- (void)scrollToIndex:(NSInteger)aIndex;
///销毁定时器
- (void)stopTimer;
///刷新数据
- (void)reloadData:(NSArray *)array;

@property (nonatomic, assign) id<DDPageViewDelegate> delegate;
///轮播图背景颜色
@property (nonatomic, strong) UIColor *pageBackgroundColor;

@end

