//
//  RootViewController.h
//  地图
//
//  Created by SuperDanny on 15/7/2.
//  Copyright (c) 2015年 SuperDanny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
/**
 系统自带导航
 当前位置导航到目的地
 1.根据目的地进行地理编码
 2.把当前位置和目的地封装成MKMapItem对象
 3.使用 MKMapItem openMapsWithItems: launchOptions: 方法进行导航
 */
@interface RootViewController : UIViewController

// 地图的View
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

// 目的地的输入框
@property (weak, nonatomic) IBOutlet UITextField *destinationField;
@property (weak, nonatomic) IBOutlet UITextView *destinationTxt;

/**
 *  点击之后开始画线
 */
- (IBAction)drawLine;

/**
 *  根据经纬度画线
 */
- (IBAction)drawLineWithLocation;

@end
