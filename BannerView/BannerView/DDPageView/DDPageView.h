//
//  DDPageView.h
//  BannerView
//
//  Created by SuperDanny on 16/1/22.
//  Copyright © 2016年 SuperDanny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPageItem.h"

typedef enum : NSUInteger {
    ///默认类型
    DDPageTypeDefault,
    ///点
    DDPageTypeDot,
    ///显示数量
    DDPageTypeNumber,
} DDPageType;

@class DDPageView;

#pragma mark - DDPageViewDelegate
@protocol DDPageViewDelegate <NSObject>

@optional
- (void)foucusView:(DDPageView *)pageView didSelectItem:(DDPageItem *)item index:(int)index;
- (void)foucusView:(DDPageView *)pageView currentItem:(int)index;

@end

@interface DDPageView : UIView

///轮播图类型
@property (nonatomic, assign) DDPageType pageType;

- (id)initWithFrame:(CGRect)frame delegate:(id<DDPageViewDelegate>)delegate imageArray:(NSArray *)array isAuto:(BOOL)isAuto;
- (id)initWithFrame:(CGRect)frame delegate:(id<DDPageViewDelegate>)delegate focusImageItems:(DDPageItem *)items, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithFrame:(CGRect)frame delegate:(id<DDPageViewDelegate>)delegate imageArray:(NSArray *)array;

- (void)scrollToIndex:(int)aIndex;
///在ViewController销毁时需要调用改方法销毁定时器，不然会导致无法释放
- (void)stopTimer;
///刷新数据
- (void)reloadData:(NSArray *)array;

@property (nonatomic, assign) id<DDPageViewDelegate> delegate;

@end

