//
//  GoodsModel.h
//  OShopping
//
//  Created by SuperDanny on 15/12/8.
//  Copyright © 2015年 SuperDanny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoodsModel : NSObject

///是否选择
@property (nonatomic, assign) BOOL isSelect;
///原价
@property (nonatomic, copy) NSString *originalPrice;
///单价
@property (nonatomic, copy) NSString *price;
///数量
@property (nonatomic, copy) NSString *amount;
///总价
@property (nonatomic, copy) NSString *totalPrices;

- (GoodsModel *)setModelWithData:(NSDictionary *)dic;

@end
