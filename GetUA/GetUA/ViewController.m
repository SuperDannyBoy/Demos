//
//  ViewController.m
//  GetUA
//
//  Created by SuperDanny on 2017/5/17.
//  Copyright © 2017年 SuperDanny. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (copy, nonatomic) NSString *userAgent;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self createHttpRequest];
}

- (void)createHttpRequest {
    _webView = [[UIWebView alloc] init];
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:
                           [NSURL URLWithString:@"http://superdanny.link"]]];
    NSLog(@"%@", [self userAgentString]);
}

- (NSString *)userAgentString {
    while (self.userAgent == nil) {
        NSLog(@"%@", @"in while");
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return self.userAgent;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (webView == _webView) {
        self.userAgent = [request valueForHTTPHeaderField:@"User-Agent"];
        // Return no, we don't care about executing an actual request.
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
