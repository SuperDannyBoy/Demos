//
//  RootViewController.m
//  地图
//
//  Created by SuperDanny on 15/7/2.
//  Copyright (c) 2015年 SuperDanny. All rights reserved.
//

#import "RootViewController.h"
#import "SVProgressHUD.h"

@interface RootViewController () <MKMapViewDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>
{
    ///记录自己的位置
    CLLocationCoordinate2D _coordinate;
    ///记录选中的位置
    CLLocationCoordinate2D _selectCoordinate;
    ///记录上一次规划的路线，用于再次请求新路线清除旧路线
    NSMutableArray *_routePolylineArr;
    CLLocationManager *_locationmanager;
}
@end

@implementation RootViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _routePolylineArr = [NSMutableArray array];
    
    //显示用户位置（蓝色发光圆圈），还有None和FollowWithHeading两种，当有这个属性的时候，iOS8第一次打开地图，会自动定位并显示这个位置。iOS7模拟器上不会。
    self.mapView.userTrackingMode  = MKUserTrackingModeFollow;
    
    //地图模式，默认是standard模式，还有卫星模式satellite和杂交模式Hybrid
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate          = self;
    
    _locationmanager = [[CLLocationManager alloc] init];
    
    //设置精度
    /*
     kCLLocationAccuracyBest
     kCLLocationAccuracyNearestTenMeters
     kCLLocationAccuracyHundredMeters
     kCLLocationAccuracyHundredMeters
     kCLLocationAccuracyKilometer
     kCLLocationAccuracyThreeKilometers
     */
    //设置定位的精度
    [_locationmanager setDesiredAccuracy:kCLLocationAccuracyBest];
    //实现协议
    _locationmanager.delegate = self;
    NSLog(@"开始定位");
    if([_locationmanager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationmanager requestWhenInUseAuthorization];
    }
    //开始定位
    [_locationmanager startUpdatingLocation];
    
    //设置大头针
    //设置地图中心
    CLLocationCoordinate2D coordinate;
    //22.271175,113.558226
    coordinate.latitude  = 22.271175;
    coordinate.longitude = 113.558226;
    MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
    ann.coordinate = coordinate;
    [ann setTitle:@"香洲区"];
    [ann setSubtitle:@"IT"];
    
    //触发viewForAnnotation
    [_mapView addAnnotation:ann];
    //添加多个
//    [_mapView addAnnotations:arr];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (
        ([_locationmanager respondsToSelector:@selector(requestWhenInUseAuthorization)] && status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusAuthorizedWhenInUse) ||
        (![_locationmanager respondsToSelector:@selector(requestWhenInUseAuthorization)] && status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusAuthorized)
        ) {
        
        NSString *message = NSLocalizedString(@"您的手机目前并未开启定位服务，如欲开启定位服务，请至设定->隐私->定位服务，开启本程序的定位服务功能", nil);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"无法定位", nil)
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        
    } else {
        [_locationmanager startUpdatingLocation];
    }
}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"自己的位置：%f,%f",userLocation.location.coordinate.longitude,userLocation.location.coordinate.latitude);
    //点击大头针，会出现以下信息
    userLocation.title    = NSLocalizedString(@"我的位置", nil);
    userLocation.subtitle = nil;
    
    _coordinate.latitude  = userLocation.location.coordinate.latitude;
    _coordinate.longitude = userLocation.location.coordinate.longitude;
    
    [self setMapRegionWithCoordinate:_coordinate];
}

#pragma mark 自定义大头针
#define CustomPinAnnotationViewTag 19921020
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id)annotation {
    MKPinAnnotationView *annotaionView = nil;
    //显示用户位置的那个蓝点也是大头针，我不希望改变它，所以在这里要判断一下
    if (annotation != _mapView.userLocation) {
        annotaionView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:@"PIN_ANNOTATION"];
        if (annotaionView == nil) {
            annotaionView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PIN_ANNOTATION"];
        }
        //标注点颜色
        annotaionView.pinColor       = MKPinAnnotationColorRed;
        //动画
        annotaionView.animatesDrop   = YES;
        //插图编号
        annotaionView.canShowCallout = YES;
        //
        
        //自定义大头针callout
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        btn.tag = CustomPinAnnotationViewTag;
        [btn setFrame:CGRectMake(0, 0, 20, 20)];
        [btn addTarget:self action:@selector(countup:) forControlEvents:UIControlEventTouchUpInside];
        annotaionView.rightCalloutAccessoryView = btn;
    }
    
    return annotaionView;
}

#pragma mark 点击大头针
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    _selectCoordinate = view.annotation.coordinate;
}

- (void)countup:(UIButton *)btn {
    UIAlertView *alertstart = [[UIAlertView alloc] initWithTitle:nil
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                               otherButtonTitles:NSLocalizedString(@"前往", nil), NSLocalizedString(@"已访", nil), nil];
    [alertstart show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self drawLineWithLocation];
    }
    else if (buttonIndex == 2) {
        NSLog(@"已访");
    }
}

/**
 *  @author LvChanghui, 15-07-02 17:07:38
 *
 *  设置当前位置可视范围
 *
 *  @param coordinate 当前位置
 */
- (void)setMapRegionWithCoordinate:(CLLocationCoordinate2D)coordinate
{
//    MKCoordinateRegion region;
//    
//    region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(.1, .1));
//    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:region];
//    [_mapView setRegion:adjustedRegion animated:YES];
}

/**
 *  当一个遮盖添加到地图上时会执行该方法
 *
 *  @param overlay 遵守MKOverlay的对象
 *
 *  @return 画线的渲染
 */
#pragma mark - 设置画线渲染
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(MKPolyline *)overlay
{
    MKPolylineRenderer *poly = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    
    poly.strokeColor = [UIColor colorWithRed:0.000 green:0.389 blue:1.000 alpha:0.870];
    poly.lineWidth = 5.0;
    
    return poly;
}

#pragma mark - 根据目的地地理位置规划路线
- (IBAction)drawLine {
    // 0.退出键盘
    [self.view endEditing:YES];
    
    // 1.获取用户输入的目的地
    NSString *destination = self.destinationField.text;
    if (destination.length == 0) {
        return;
    }
    
    // 2.地理编码
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:destination completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count == 0 || error) return;
        
        // 2.1.获取CLPlaceMark对象
        CLPlacemark *clpm = [placemarks firstObject];
        
        // 2.2.利用CLPlacemark来创建MKPlacemark
        MKPlacemark *mkpm = [[MKPlacemark alloc] initWithPlacemark:clpm];
        
        // 2.3.创建目的地的MKMapItem对象
        MKMapItem *destinationItem = [[MKMapItem alloc] initWithPlacemark:mkpm];
        
        // 2.4.起点的MKMapItem
        MKMapItem *sourceItem = [MKMapItem mapItemForCurrentLocation];
        
        // 2.5.开始画线
        [self drawLineWithSourceItem:sourceItem destinationItem:destinationItem];
    }];
}

#pragma mark - 根据目的地经纬度规划路线
- (IBAction)drawLineWithLocation {
    // 0.退出键盘
    [self.view endEditing:YES];
    
    // 2.地理编码
    CLLocationCoordinate2D fromCoordinate = _coordinate;
//    CLLocationCoordinate2D toCoordinate   = CLLocationCoordinate2DMake(22.271175,113.558226);
    CLLocationCoordinate2D toCoordinate   = _selectCoordinate;
    
    MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:fromCoordinate
                                                       addressDictionary:nil];

    MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:toCoordinate
                                                       addressDictionary:nil];
    
    MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];

    MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
    
    //开始画线
    [self findDirectionsFrom:fromItem to:toItem];
}

/**
 *  开始画线
 *
 *  @param source      起点的Item
 *  @param destination 终点的Item
 */
#pragma mark - 开始画线
- (void)findDirectionsFrom:(MKMapItem *)source
                        to:(MKMapItem *)destination
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"规划路线中...", nil) maskType:SVProgressHUDMaskTypeBlack];
    MKDirectionsRequest *request    = [[MKDirectionsRequest alloc] init];
    request.source                  = source;
    request.destination             = destination;
    request.transportType = MKDirectionsTransportTypeAutomobile;
    request.requestsAlternateRoutes = YES;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         [SVProgressHUD dismiss];
         if (error) {
             NSLog(@"error:%@", error.localizedDescription);
         }
         else {
             MKRoute *route = response.routes[0];
             NSLog(@"route.polyline:%@",route.polyline);
             [self.mapView removeOverlays:_routePolylineArr];
             [_routePolylineArr removeAllObjects];
             [_routePolylineArr addObject:route.polyline];
             [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
         }
     }];
}

/**
 *  开始画线
 *
 *  @param sourceItem      起点的Item
 *  @param destinationItem 终点的Item
 */
- (void)drawLineWithSourceItem:(MKMapItem *)sourceItem destinationItem:(MKMapItem *)destinationItem
{
    // 1.创建MKDirectionsRequest对象
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    // 1.1.设置起点的Item
    request.source = sourceItem;
    
    // 1.2.设置终点的Item
    request.destination = destinationItem;
    
    // 2.创建MKDirections对象
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    // 3.请求/计算(当请求到路线信息的时候会来到该方法)
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        // 3.1.当有错误,或者路线数量为0直接返回
        if (error || response.routes.count == 0) return;
        
        NSLog(@"%ld", response.routes.count);
        
        
        // 3.2.遍历所有的路线
        for (MKRoute *route in response.routes) {
            
            NSLog(@"route.polyline:%@",route.polyline);
            [self.mapView removeOverlays:_routePolylineArr];
            [_routePolylineArr removeAllObjects];
            [_routePolylineArr addObject:route.polyline];
            
            // 3.3.取出路线(遵守MKOverlay)
            MKPolyline *polyLine = route.polyline;
            
            // 3.4.将路线添加到地图上
            [self.mapView addOverlay:polyLine level:MKOverlayLevelAboveRoads];
        }
    }];
}

@end
