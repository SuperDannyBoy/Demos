//
//  WXApiRequestHandler.m
//  Created by SuperDanny on 15/12/7.
//


#import "WXApiRequestHandler.h"
#import "WXApiManager.h"
//#import "MyBillDetailsViewController.h"

@interface WXApiRequestHandler ()

///debug信息
@property (nonatomic, copy) NSMutableString *debugInfo;
///
@property long last_errcode;

@end

@implementation WXApiRequestHandler

#pragma mark - Public Methods
+ (instancetype)sharedManager {
    static WXApiRequestHandler *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[WXApiRequestHandler alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - 真實環境下支付
- (NSString *)jumpToBizPay {
    NSString *urlString = @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php?plat=ios";
        //解析服务端返回json数据
        NSError *error;
        //加载一个NSURL对象
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        //将请求的url数据放到NSData对象中
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        if (response != nil) {
            NSMutableDictionary *dict = NULL;
            //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
            dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
            
            NSLog(@"url:%@",urlString);
            if(dict != nil){
                NSMutableString *retcode = [dict objectForKey:@"retcode"];
                if (retcode.intValue == 0){
                    NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
                    
                    //调起微信支付
                    PayReq *req             = [[PayReq alloc] init];
                    req.partnerId           = [dict objectForKey:@"partnerid"];
                    req.prepayId            = [dict objectForKey:@"prepayid"];
                    req.nonceStr            = [dict objectForKey:@"noncestr"];
                    req.timeStamp           = stamp.intValue;
                    req.package             = [dict objectForKey:@"package"];
                    req.sign                = [dict objectForKey:@"sign"];
                    [WXApi sendReq:req];
                    //日志输出
                    NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[dict objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
                    return @"";
                }else{
                    return [dict objectForKey:@"retmsg"];
                }
            }else{
                return @"服务器返回错误，未获取到json对象";
            }
        }else{
            return @"服务器返回错误";
        }
}

#pragma mark - 创建package签名
- (NSString*)createMd5Sign:(NSMutableDictionary*)dict {
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
        
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", PARTNER_ID];
    //得到MD5 sign签名
    NSString *md5Sign =[WXUtil md5:contentString];
    
    //输出Debug Info
    [_debugInfo appendFormat:@"MD5签名字符串：\n%@\n\n",contentString];
    
    return md5Sign;
}

#pragma mark - 获取package带参数的签名包
- (NSString *)genPackage:(NSMutableDictionary*)packageParams
{
    NSString *sign;
    NSMutableString *reqPars = [NSMutableString string];
    //生成签名
    sign = [self createMd5Sign:packageParams];
    //生成xml的package
    NSArray *keys = [packageParams allKeys];
    [reqPars appendString:@"<xml>\n"];
    for (NSString *categoryId in keys) {
        [reqPars appendFormat:@"<%@>%@</%@>\n", categoryId, [packageParams objectForKey:categoryId],categoryId];
    }
    [reqPars appendFormat:@"<sign>%@</sign>\n</xml>", sign];
    
    return [NSString stringWithString:reqPars];
}
//提交预支付
-(NSString *)sendPrepay:(NSMutableDictionary *)prePayParams {
    
    NSString *prepayid = nil;
    
    _debugInfo = [NSMutableString string];
    [_debugInfo setString:@""];
    
    //获取提交支付
    NSString *send = [self genPackage:prePayParams];
    
    //输出Debug Info
    [_debugInfo appendFormat:@"API链接:%@\n", PREPAY_URL];
    [_debugInfo appendFormat:@"发送的xml:%@\n", send];
    
    //发送请求post xml数据
    NSData *res = [WXUtil httpSend:PREPAY_URL method:@"POST" data:send];
    
    //输出Debug Info
    [_debugInfo appendFormat:@"服务器返回：\n%@\n\n",[[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding]];
    
    XMLHelper *xml  = [[XMLHelper alloc] init];
    
    //开始解析
    [xml startParse:res];
    
    NSMutableDictionary *resParams = [xml getDict];
    
    //判断返回
    NSString *return_code   = [resParams objectForKey:@"return_code"];
    NSString *result_code   = [resParams objectForKey:@"result_code"];
    if ( [return_code isEqualToString:@"SUCCESS"] )
    {
        //生成返回数据的签名
        NSString *sign      = [self createMd5Sign:resParams ];
        NSString *send_sign =[resParams objectForKey:@"sign"] ;
        
        //验证签名正确性
        if( [sign isEqualToString:send_sign]){
            if( [result_code isEqualToString:@"SUCCESS"]) {
                //验证业务处理状态
                prepayid    = [resParams objectForKey:@"prepay_id"];
                return_code = 0;
                
                [_debugInfo appendFormat:@"获取预支付交易标示成功！\n"];
            }
        }else{
            _last_errcode = 1;
            [_debugInfo appendFormat:@"gen_sign=%@\n   _sign=%@\n",sign,send_sign];
            [_debugInfo appendFormat:@"服务器返回签名验证错误！！！\n"];
        }
    }else{
        _last_errcode = 2;
        [_debugInfo appendFormat:@"接口返回错误！！！\n"];
    }
    
    return prepayid;
}

#pragma mark - 模擬環境下支付
//============================================================
// V3V4支付流程模拟实现，只作帐号验证和演示
// 注意:此demo只适合开发调试，参数配置和参数加密需要放到服务器端处理
//============================================================
- (NSMutableDictionary *)sendPay_demoWithOrderMessageDic:(NSDictionary *)OrderMessageDic {
    /*
    @{
         @"ExchangeNo": @"",
         @"ExchangeObjectName": @"",
         @"Price": @""
     }
     */
    //订单标题，展示给用户
    NSString *order_name  = OrderMessageDic[@"ExchangeObjectName"];
    //订单金额,单位（分）
    NSInteger pri = [OrderMessageDic[@"Price"] doubleValue]*100;
    NSString *order_price = [NSString stringWithFormat:@"%ld",(long)pri];//1分钱测试
    //订单号
    NSString *orderNum    = OrderMessageDic[@"ExchangeNo"];
    //記錄當前訂單號，用於支付成功跳轉
    self.ExchangeNo = orderNum;
    
    //================================
    //预付单参数订单设置
    //================================
    srand((unsigned)time(0));
    NSString *noncestr = [NSString stringWithFormat:@"%d", rand()];
    NSMutableDictionary *packageParams = [NSMutableDictionary dictionary];
    
    //开放平台appid
    [packageParams setObject: APP_ID            forKey:@"appid"];
    //商户号
    [packageParams setObject: MCH_ID            forKey:@"mch_id"];
    //支付设备号或门店号
    [packageParams setObject: @"APP-001"        forKey:@"device_info"];
    //随机串
    [packageParams setObject: noncestr          forKey:@"nonce_str"];
    //支付类型，固定为APP
    [packageParams setObject: @"APP"            forKey:@"trade_type"];
    //订单描述，展示给用户
    [packageParams setObject: order_name        forKey:@"body"];
    //支付结果异步通知
    [packageParams setObject: NOTIFY_URL        forKey:@"notify_url"];
    //商户订单号
    [packageParams setObject: orderNum          forKey:@"out_trade_no"];
    //发起支付的机器ip
    [packageParams setObject: @"196.168.1.1"    forKey:@"spbill_create_ip"];
    //订单金额，单位为分
    [packageParams setObject: order_price       forKey:@"total_fee"];
    
    //获取prepayId（预支付交易会话标识）
    NSString *prePayid;
    prePayid = [self sendPrepay:packageParams];
    
    if ( prePayid != nil) {
        //获取到prepayid后进行第二次签名
        NSString    *package, *time_stamp, *nonce_str;
        //设置支付参数
        time_t now;
        time(&now);
        time_stamp  = [NSString stringWithFormat:@"%ld", now];
        nonce_str	= [WXUtil md5:time_stamp];
        //重新按提交格式组包，微信客户端暂只支持package=Sign=WXPay格式，须考虑升级后支持携带package具体参数的情况
        //package       = [NSString stringWithFormat:@"Sign=%@",package];
        package         = @"Sign=WXPay";
        //第二次签名参数列表
        NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
        [signParams setObject: APP_ID        forKey:@"appid"];
        [signParams setObject: nonce_str    forKey:@"noncestr"];
        [signParams setObject: package      forKey:@"package"];
        [signParams setObject: MCH_ID        forKey:@"partnerid"];
        [signParams setObject: time_stamp   forKey:@"timestamp"];
        [signParams setObject: prePayid     forKey:@"prepayid"];
        //[signParams setObject: @"MD5"       forKey:@"signType"];
        //生成签名
        NSString *sign  = [self createMd5Sign:signParams];
        
        //添加签名
        [signParams setObject: sign         forKey:@"sign"];
        
        [_debugInfo appendFormat:@"第二步签名成功，sign＝%@\n",sign];
        
        //返回参数列表
        return signParams;
        
    }else{
        [_debugInfo appendFormat:@"获取prepayid失败！\n"];
    }
    return nil;
}

#pragma mark - 调起微信支付
+ (void)sendReq:(NSDictionary *)dict {
    NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
    
    //调起微信支付
    PayReq* req             = [[PayReq alloc] init];
    req.openID              = [dict objectForKey:@"appid"];
    req.partnerId           = [dict objectForKey:@"partnerid"];
    req.prepayId            = [dict objectForKey:@"prepayid"];
    req.nonceStr            = [dict objectForKey:@"noncestr"];
    req.timeStamp           = stamp.intValue;
    req.package             = [dict objectForKey:@"package"];
    req.sign                = [dict objectForKey:@"sign"];
    [WXApi sendReq:req];
}

@end
