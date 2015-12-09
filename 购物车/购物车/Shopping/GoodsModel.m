//
//  GoodsModel.m
//  OShopping
//
//  Created by SuperDanny on 15/12/8.
//  Copyright © 2015年 SuperDanny. All rights reserved.
//

#import "GoodsModel.h"

@implementation GoodsModel

- (GoodsModel *)setModelWithData:(NSDictionary *)dic {
    self.price         = @"556.00";
    self.originalPrice = @"756.00";
    self.amount        = @"86";
    CGFloat prices     = [self.amount integerValue]*[self.price floatValue];
    self.totalPrices   = [NSString stringWithFormat:@"%.2lf", prices];
    return self;
}

- (void)setAmount:(NSString *)amount {
    _amount = amount;
    CGFloat prices   = [_amount integerValue]*[self.price floatValue];
    self.totalPrices = [NSString stringWithFormat:@"%.2lf", prices];
}

@end
