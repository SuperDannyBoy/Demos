//
//  ViewController.m
//  AreaPicker
//
//  Created by SuperDanny on 15/11/10.
//  Copyright © 2015年 SuperDanny. All rights reserved.
//

#import "ViewController.h"
#import "DDAreaPickerView.h"

@interface ViewController () <DDAreaPickerDelegate, DDAreaPickerDatasource>
@property (strong, nonatomic) DDAreaPickerView *locatePicker;

-(void)cancelLocatePicker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *areaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    areaBtn.frame = CGRectMake(100, 50, 100, 40);
    areaBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:areaBtn];
    [areaBtn addTarget:self action:@selector(showAreaPicker) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cityBtn.frame = CGRectMake(100, CGRectGetMaxY(areaBtn.frame)+50, 100, 40);
    cityBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:cityBtn];
    [cityBtn addTarget:self action:@selector(showCityPicker) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showAreaPicker {
    [self cancelLocatePicker];
    self.locatePicker = [[DDAreaPickerView alloc] initWithStyle:DDAreaPickerWithStateAndCityAndDistrict
                                                   withDelegate:self
                                                  andDatasource:self];
    [self.locatePicker showInView:self.view];
}

- (void)showCityPicker {
    [self cancelLocatePicker];
    self.locatePicker = [[DDAreaPickerView alloc] initWithStyle:DDAreaPickerWithStateAndCity
                                                   withDelegate:self
                                                  andDatasource:self];
    [self.locatePicker showInView:self.view];
}

#pragma mark - DDAreaPicker delegate
-(void)pickerDidChaneStatus:(DDAreaPickerView *)picker
{
    if (picker.pickerStyle == DDAreaPickerWithStateAndCityAndDistrict) {
        NSLog(@"省、市、区、邮政编码：%@", [NSString stringWithFormat:@"%@ %@ %@ %@", picker.locate.state, picker.locate.city, picker.locate.district, picker.locate.zipCode]);
    } else{
        NSLog(@"省、市、邮政编码：%@", [NSString stringWithFormat:@"%@ %@ %@", picker.locate.state, picker.locate.city, picker.locate.zipCode]);
    }
}

-(NSArray *)areaPickerData:(DDAreaPickerView *)picker
{
    NSArray *data = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"address.plist" ofType:nil]][@"address"];
    return data;
}

-(void)cancelLocatePicker
{
    [self.locatePicker cancelPicker];
    self.locatePicker.delegate = nil;
    self.locatePicker = nil;
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
