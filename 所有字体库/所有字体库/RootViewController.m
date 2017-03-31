//
//  RootViewController.m
//  所有字体库
//
//  Created by SuperDanny on 2017/3/31.
//  Copyright © 2017年 Danny_Changhui. All rights reserved.
//

#import "RootViewController.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define kNavHeight 64.0f
#define kTabHeight 40.0f

static NSString *reuseIdentifier = @"Cell";

@interface RootViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) NSArray  *fontArr;
@property (nonatomic, copy) NSString *fontNameStr;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"字体库";
    [self createTabView];
    [self.view addSubview:[self createTableView]];
    self.fontArr = [UIFont familyNames];
}

- (void)createTabView {
    UIView *tabView = [[UIView alloc]initWithFrame:CGRectMake(0, kNavHeight, ScreenWidth, kTabHeight)];
    [tabView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:tabView];
    
    CGFloat bWidth = 60.0f;
    CGFloat hMargin = 3.0f;
    CGFloat sMargin = 5.0f;
    self.textField = [[UITextField alloc]initWithFrame:CGRectMake(sMargin, hMargin, ScreenWidth - bWidth - 2*sMargin, kTabHeight - hMargin*2)];
    [_textField setTextAlignment:NSTextAlignmentLeft];
    [_textField setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型
    
    _textField.placeholder = @"请输入文字"; //默认显示的字
    _textField.secureTextEntry = NO; //密码
    _textField.font = [UIFont systemFontOfSize:14];
    _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.delegate = self;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing; //编辑时会出现个修改X
    [tabView addSubview:_textField];
    
    UIButton *setBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - bWidth, 0, bWidth, kTabHeight)];
    [setBtn setBackgroundColor:[UIColor clearColor]];
    [setBtn setTitle:@"设置" forState:UIControlStateNormal];
    [setBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [setBtn addTarget:self action:@selector(fontSetClick:) forControlEvents:UIControlEventTouchUpInside];
    [tabView addSubview:setBtn];
}

- (UITableView *)createTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight + kTabHeight, ScreenWidth, ScreenHeight - kTabHeight - kNavHeight)];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setMultipleTouchEnabled:NO];
    [_tableView setDelaysContentTouches:NO];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    return _tableView;
}

- (void)fontSetClick:(UIButton *)font {
    if ([[_textField text] length] > 0) {
        [_textField resignFirstResponder];
        [self.tableView reloadData];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请输入文字" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _fontArr[section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _fontArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *familyName = _fontArr[section];
    return [[UIFont fontNamesForFamilyName:familyName] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    //字体家族名称
    NSString *familyName = _fontArr[indexPath.section];
    //字体家族中的字体库名称
    NSString *fontName  = [UIFont fontNamesForFamilyName:familyName][indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:fontName size:14];
    if (_textField.text.length>0) {
        cell.textLabel.text = _textField.text;
    } else {
        cell.textLabel.text = @"小灰灰！ABCDCFG.。abcdefg*0123456";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //字体家族名称
    NSString *familyName = _fontArr[indexPath.section];
    //字体家族中的字体库名称
    NSString *fontName  = [UIFont fontNamesForFamilyName:familyName][indexPath.row];
    _fontNameStr = fontName;
    NSString *message = [NSString stringWithFormat:@"是否拷贝字体名称\n%@",_fontNameStr];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIPasteboard generalPasteboard] setPersistent:YES];
        [[UIPasteboard generalPasteboard] setValue:_fontNameStr forPasteboardType:[UIPasteboardTypeListString objectAtIndex:0]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
