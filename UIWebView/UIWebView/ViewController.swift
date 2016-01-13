//
//  ViewController.swift
//  UIWebView
//
//  Created by SuperDanny on 16/1/12.
//  Copyright © 2016年 SuperDanny. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate {

    var webView: UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        let rect = CGRect(x: 0, y: 64, width: CGRectGetWidth(self.view.frame), height: CGRectGetHeight(self.view.frame)-64)
        
        webView = UIWebView(frame: rect)
//        webView!.scalesPageToFit = true
        webView!.delegate = self
        
        let fileURL = NSBundle.mainBundle().URLForResource("index", withExtension: "html")
        let request = NSURLRequest(URL: fileURL!)
        
        var response: NSURLResponse?
        
        var data: NSData?
        
        do {
            data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
        } catch {
            print(error)
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        print("\(response?.MIMEType)")
        
        // 在iOS开发中,如果不是特殊要求,所有的文本编码都是用UTF8
        // 先用UTF8解释接收到的二进制数据流
        webView!.loadData(data!, MIMEType: (response?.MIMEType)!, textEncodingName: "UTF8", baseURL: NSURL(string: "")!)
        
        webView!.loadRequest(request)
    }
    
    private func createHeaderView() -> UIView {
        let view = UILabel(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(self.view.frame), height: 50))
        view.text = "这是头部视图"
        view.backgroundColor = UIColor.orangeColor()
        return view
    }
    
    private func addHeaderView(headerView: UIView) {
        
        let browserCanvas = webView!.bounds
        
        for subView in webView!.scrollView.subviews {
            var subViewRect = subView.frame
            if(subViewRect.origin.x == browserCanvas.origin.x &&
                subViewRect.origin.y == browserCanvas.origin.y &&
                subViewRect.size.width == browserCanvas.size.width &&
                subViewRect.size.height == browserCanvas.size.height)
            {
                let height              = headerView.frame.size.height
                subViewRect.origin.y    = height
                subViewRect.size.height = height
                subView.frame           = subViewRect
            }
        }
        webView!.scrollView.addSubview(headerView)
        webView!.scrollView.bringSubviewToFront(headerView)
    }
    
    //MARK: UIWebViewDelegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        print("webViewDidStartLoad")
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print("webViewDidFinishLoad")
        
        //添加头部视图
        self.addHeaderView(self.createHeaderView())
        self.view.addSubview(webView)
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print("didFailLoadWithError--->\(error?.localizedDescription)")
    }
    
    // MARK:
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

