//
//  WechatPayHeader.h
//  Created by SuperDanny on 15/12/7.
//

#ifndef WechatPayHeader_h
#define WechatPayHeader_h

//////////////////////////////////
///商户相关信息请到微信开发者平台查看///
//////////////////////////////////

#define APP_ID          @"wx2be937c56f9f3faf"               //AppID
#define APP_SECRET      @"d56c26fea525e5761830fb57d19adffd" //AppSecret
//商户号，填写商户对应参数
#define MCH_ID          @"1261441801"
//商户API密钥，填写相应参数
#define PARTNER_ID      @"0891c9c2015b96bb7962129df6689111"
//预支付网关URL地址
#define PREPAY_URL      @"https://api.mch.weixin.qq.com/pay/unifiedorder"
//支付结果回调页面
#define NOTIFY_URL      @"http://wxpay.weixin.qq.com/pub_v2/pay/notify.v2.php"

#endif /* WechatPayHeader_h */
