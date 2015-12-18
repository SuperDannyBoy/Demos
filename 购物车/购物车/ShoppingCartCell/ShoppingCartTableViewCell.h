//
//  ShoppingCartTableViewCell.h
//  OShopping
//
//  Created by SuperDanny on 15/11/12.
//  Copyright © 2015年 MacauIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsModel.h"

typedef enum : NSUInteger {
    ///购物车界面
    CellTypeShoppingCart,
    ///下单界面
    CellTypeBuying,
} ShoppingCartCellType;

@interface ShoppingCartTableViewCell : UITableViewCell

///选择block
- (void)setChooseBlock:(void(^)(BOOL isSelect))block;
///增减数量block
- (void)setChangeBlock:(void(^)(NSUInteger count))block;

/*!
 *  配置Cell数据
 *
 *  @param model      数据模型
 *  @param cellType   Cell类型
 *  @param canEditing Cell是否可编辑
 */
- (void)configureCellDataWithModel:(GoodsModel *)model cellType:(ShoppingCartCellType)cellType CanEditing:(BOOL)canEditing;

@end
