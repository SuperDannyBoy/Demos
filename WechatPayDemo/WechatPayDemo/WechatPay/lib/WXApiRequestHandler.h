//
//  WXApiRequestHandler.h
//  Created by SuperDanny on 15/12/7.
//

#import <Foundation/Foundation.h>
#import "WXApiObject.h"
#import "WechatPayHeader.h"
#import "WXUtil.h"
#import "ApiXml.h"
#import "WXApi.h"

@interface WXApiRequestHandler : NSObject

///訂單號,用於支付成功跳轉訂單詳情界面
@property (nonatomic, copy) NSString *ExchangeNo;

+ (instancetype)sharedManager;

///真实环境下支付
- (NSString *)jumpToBizPay;

///模擬環境下支付
- (NSMutableDictionary *)sendPay_demoWithOrderMessageDic:(NSDictionary *)OrderMessageDic;

///调起微信支付
+ (void)sendReq:(NSDictionary *)dict;

@end
