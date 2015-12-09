//
//  AmountTools.m
//
//  Created by Danny on 15/4/24.
//  Copyright (c) 2015年 Danny. All rights reserved.
//

#import "AmountTools.h"
#import "CheckTools.h"

@implementation AmountTools
#pragma mark - 限制输入数字格式（整数位数以及小数位数）
+ (BOOL)limitTheNumberString:(NSString *)number andNextString:(NSString *)nextStr andIntLength:(NSUInteger)intLength andPointLength:(NSUInteger)pointLength {
    //忽略輸入空格字符串
    if ([nextStr isEqualToString:@" "]) {
        return NO;
    }
    if (![CheckTools isPureFloat:number]) {
        return NO;
    }
    //整數部份長度
    NSUInteger tempIntLength = [NSString stringWithFormat:@"%ld",(long)[number integerValue]].length;
    //小數部份長度，包括小數點
    NSUInteger tempPointLength = [number substringFromIndex:tempIntLength].length;
    
    //如果小數部份長度為0，說明限制數字為整數
    if (pointLength == 0) {
        if ([CheckTools isPureInt:number] && tempIntLength <= intLength) {
            if (![number isEqualToString:nextStr]) {
                if (  [number isEqualToString:@"00"]
                    ||[number isEqualToString:@"01"]
                    ||[number isEqualToString:@"02"]
                    ||[number isEqualToString:@"03"]
                    ||[number isEqualToString:@"04"]
                    ||[number isEqualToString:@"05"]
                    ||[number isEqualToString:@"06"]
                    ||[number isEqualToString:@"07"]
                    ||[number isEqualToString:@"08"]
                    ||[number isEqualToString:@"09"]) {
                    return NO;
                }
            }
            return YES;
        }
        return NO;
    }
    
    //
    if (tempIntLength > intLength || tempPointLength > pointLength+1) {
        return NO;
    }
    if ([number isEqualToString:nextStr]) {
        return YES;
    }
    if ([CheckTools isPureFloat:number]) {
        
        //判斷輸入是否0開頭  如果是類似0.1232則允許輸入，否則不允許輸入
        if ([[number substringToIndex:1] isEqualToString:@"0"]) {
            
            if (number.length == 2 && [number isEqualToString:@"0."] && [nextStr isEqualToString:@"."]) {
                return YES;
            }
            else if (number.length >= 3) {
                return YES;
            }
            else {
                return NO;
            }
        }
    }
    else {
        return NO;
    }
    return YES;
}

@end
