//
//  AmountTools.h
//
//  Created by Danny on 15/4/24.
//  Copyright (c) 2015年 Danny. All rights reserved.
//
//  金额工具类

#import <Foundation/Foundation.h>

@interface AmountTools : NSObject

/**
 *  @author LvChanghui, 15-08-07 14:08:01
 *
 *  限制输入数字格式（整数位数以及小数位数）
 *
 *  @param number      输入的字符串
 *  @param nextStr     当前输入的字符
 *  @param intLength   整数位置长度
 *  @param pointLength 小数位置长度
 *
 *  @return 是否允许继续输入
 */
+ (BOOL)limitTheNumberString:(NSString *)number andNextString:(NSString *)nextStr andIntLength:(NSUInteger)intLength andPointLength:(NSUInteger)pointLength;

@end
