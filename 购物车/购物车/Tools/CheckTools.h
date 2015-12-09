//
//  CheckTools.h
//
//  Created by Danny on 15/4/24.
//  Copyright (c) 2015年 Danny. All rights reserved.
//
//  逻辑检查工具

#import <Foundation/Foundation.h>
@interface CheckTools : NSObject
/**
 *  只能输入数字
 *
 *  @param str
 */
+ (BOOL)isNumber:(NSString *)str;
/**
 *  只能输入数字小数点
 *
 *  @param str sf
 *
 *  @return asdf
 */
+ (BOOL)isCountNumber:(NSString *)str;
/**
 *  判断是否为整型
 */
+ (BOOL)isPureInt:(NSString*)string;
/**
 *  判断是否为浮点型
 */
+ (BOOL)isPureFloat:(NSString*)string;
@end
