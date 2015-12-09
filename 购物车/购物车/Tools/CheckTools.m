//
//  CheckTools.m
//
//  Created by Danny on 15/4/24.
//  Copyright (c) 2015年 Danny. All rights reserved.
//

#import "CheckTools.h"

@implementation CheckTools
#pragma mark - 只能输入数字
+ (BOOL)isNumber:(NSString *)str
{
    NSString *keyRegex = @"[0-9]{1,10000}";
    NSPredicate *keyTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", keyRegex];
    return [keyTest evaluateWithObject:str];
}
#pragma mark - 只能输入数字小数点
+ (BOOL)isCountNumber:(NSString *)str
{
    //    /^\d+\.{0,1}\d*$/
    NSString *countRegex = @"^?\\d*(\\.)?\\d*$";
    NSPredicate *countTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", countRegex];
    return [countTest evaluateWithObject:str];
}
#pragma mark - 判断是否为整型
+ (BOOL)isPureInt:(NSString*)string {
    NSScanner *scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

#pragma mark - 判断是否为浮点型
+ (BOOL)isPureFloat:(NSString*)string {
    NSScanner *scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}
@end
