//
//  AppDelegate.m
//  WechatPayDemo
//
//  Created by SuperDanny on 15/12/7.
//  Copyright © 2015年 SuperDanny. All rights reserved.
//

#import "AppDelegate.h"
#import "WXApi.h"
#import "WXApiManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //向微信注册appId
    [WXApi registerApp:APP_ID withDescription:[NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"]];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

@end
