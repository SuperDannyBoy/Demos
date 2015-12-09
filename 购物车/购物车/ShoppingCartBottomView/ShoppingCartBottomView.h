//
//  ShoppingCartBottomView.h
//  OShopping
//
//  Created by SuperDanny on 15/11/12.
//  Copyright © 2015年 SuperDanny. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ///支付
    TypePayMoney,
    ///删除
    TypeDelete,
} BottomType;

@interface ShoppingCartBottomView : UIView

///选择
@property (strong, nonatomic) UIButton *chooseBtn;
///费用
@property (strong, nonatomic) UILabel  *moneyLab;

///設置視圖類型
- (void)setViewType:(BottomType)type;
///設置選擇block
- (void)setChooseBlock:(void(^)(BOOL isChoose))block;
///支付block
- (void)setPayActionBlock:(void(^)())block;
///刪除block
- (void)setDeleteActionBlock:(void(^)())block;

@end
