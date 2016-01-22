//
//  DDPageView.h
//  BannerView
//
//  Created by SuperDanny on 16/1/22.
//  Copyright © 2016年 SuperDanny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPageItem.h"

@class DDPageView;

#pragma mark - DDPageViewDelegate
@protocol DDPageViewDelegate <NSObject>

@optional
- (void)foucusView:(DDPageView *)pageView didSelectItem:(DDPageItem *)item index:(NSInteger)index;
- (void)foucusView:(DDPageView *)pageView currentItem:(NSInteger)index;

@end

@interface DDPageView : UIView

- (id)initWithFrame:(CGRect)frame delegate:(id<DDPageViewDelegate>)delegate imageItems:(NSArray *)items isAuto:(BOOL)isAuto;

- (id)initWithFrame:(CGRect)frame delegate:(id<DDPageViewDelegate>)delegate focusImageItems:(DDPageItem *)items, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithFrame:(CGRect)frame delegate:(id<DDPageViewDelegate>)delegate imageItems:(NSArray *)items;
- (void)scrollToIndex:(NSInteger)aIndex;

@property (nonatomic, assign) id<DDPageViewDelegate> delegate;

@end

