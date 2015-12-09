//
//  ShoppingCartsViewController.m
//  OShopping
//
//  Created by SuperDanny on 15/11/12.
//  Copyright © 2015年 SuperDanny. All rights reserved.
//

#import "ShoppingCartsViewController.h"
#import "ShoppingCartTableViewCell.h"
#import "ShoppingCartBottomView.h"

@interface ShoppingCartsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UITableView    *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) ShoppingCartBottomView *bottomView;
///存儲已選擇的商品數據
@property (strong, nonatomic) NSMutableArray *chooseData;
///是否处于编辑状态
@property BOOL isEditing;

@end

@implementation ShoppingCartsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"購物車", nil);
    {
        //模拟数据
        _dataArray = [NSMutableArray array];
        for (int i = 0; i < 5; i++) {
            GoodsModel *model = [[GoodsModel alloc] init];
            [model setModelWithData:nil];
            [_dataArray addObject:model];
        }
    }
    [self createContentView];
}

- (void)setRightItemImages:(NSArray *)norImages selectedImages:(NSArray *)selectedimages {
    __block NSMutableArray *items = [NSMutableArray array];
    [norImages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *imageName = obj;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTag:idx];
        UIImage *norImage = [UIImage imageNamed:imageName];
        [button setBackgroundImage:norImage forState:UIControlStateNormal];
        if (selectedimages.count) {
            UIImage *selectedImage = [UIImage imageNamed:selectedimages[idx]];
            [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
        }
        [button setFrame:CGRectMake(0, 0, norImage.size.width+2, norImage.size.height+2)];
        [button setExclusiveTouch:YES];
        
        [button addTarget:self action:@selector(rightMenuPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        item.tag = idx;
        [items addObject:item];
    }];
    self.navigationItem.rightBarButtonItems = items;
}

- (void)createContentView {
    [self setRightItemImages:@[@"shoppingEdit"] selectedImages:@[@"shoppingEdit"]];
    
    CGFloat bottomViewHeight = 44.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-bottomViewHeight)];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.639];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"ShoppingCartTableViewCell" bundle:nil] forCellReuseIdentifier:@"ShoppingCartCell"];
    [self.view addSubview:self.tableView];
    WEAKSELF
    _bottomView = [[ShoppingCartBottomView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tableView.frame), KScreenWidth, bottomViewHeight)];
    [_bottomView setChooseBlock:^(BOOL isChoose) {
        NSLog(@"全选：%@", @(isChoose));
        //更新商品选择状态
        [weakSelf chooseAll:isChoose];
    }];
    [_bottomView setPayActionBlock:^{
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"isSelect == 1"];
        if ([weakSelf.dataArray filteredArrayUsingPredicate:pre].count) {
            //进入支付界面
        } else {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"至少選擇一件商品進行支付", nil)];
        }
    }];
    [_bottomView setDeleteActionBlock:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"是否刪除選中商品?", nil)
                                                       delegate:weakSelf
                                              cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                              otherButtonTitles:NSLocalizedString(@"確定", nil), nil];
        [alert show];
    }];
    [self.view addSubview:_bottomView];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"刪除選擇商品");
    }
}

#pragma mark - 编辑/删除切换
- (void)rightMenuPressed:(id)sender {
    if (_isEditing) {
        [self setRightItemImages:@[@"shoppingEdit"] selectedImages:@[@"shoppingEdit"]];
    } else {
        [self setRightItemImages:@[@"shoppingComplete"] selectedImages:@[@"shoppingComplete"]];
    }
    _isEditing = !_isEditing;
    [_bottomView setViewType:_isEditing ? TypeDelete : TypePayMoney];
}

#pragma mark - 统计总价
- (void)statistics {
    CGFloat prices = 0;
    //统计选中的有几项，用于判断是否全选
    __block NSUInteger selectCount = 0;
    for (GoodsModel *model in _dataArray) {
        if (model.isSelect) {
            selectCount++;
            prices += [model.totalPrices floatValue];
        }
    }
    if (selectCount == _dataArray.count) {
        _bottomView.chooseBtn.selected = YES;
    } else {
        _bottomView.chooseBtn.selected = NO;
    }
    _bottomView.moneyLab.text = [NSString stringWithFormat:@"合計：$ %.2lf", prices];
}

#pragma mark - 全选
- (void)chooseAll:(BOOL)isChoose {
    for (GoodsModel *model in _dataArray) {
        model.isSelect = isChoose;
    }
    //重新计算总价
    [self statistics];
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WEAKSELF
    ShoppingCartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShoppingCartCell" forIndexPath:indexPath];
    
    __block GoodsModel *model = _dataArray[indexPath.row];
    
    [cell configureCellDataWithModel:model cellType:CellTypeShoppingCart];
    
    [cell setChooseBlock:^(BOOL isSelect) {
        model.isSelect = isSelect;
        NSLog(@"选择：%@---行数：%ld", @(isSelect), indexPath.row);
        [weakSelf statistics];
    }];
    
    [cell setChangeBlock:^(NSUInteger count) {
        NSLog(@"当前商品数量：%lu", count);
        model.amount = [NSString stringWithFormat:@"%lu", count];
        [weakSelf statistics];
    }];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77;
}

@end
