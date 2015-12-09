//
//  ShoppingCartBottomView.m
//  OShopping
//
//  Created by SuperDanny on 15/11/12.
//  Copyright © 2015年 SuperDanny. All rights reserved.
//

#import "ShoppingCartBottomView.h"

typedef void(^ChooseBlock)(BOOL);
typedef void(^PayBlock)();
typedef void(^DeleteBlock)();

@interface ShoppingCartBottomView ()

///付款
@property (strong, nonatomic) UIButton *payBtn;
///删除
@property (strong, nonatomic) UIButton *deleteBtn;
///运费
@property (strong, nonatomic) UILabel  *freightLab;

@property (copy, nonatomic) ChooseBlock choose_block;
@property (copy, nonatomic) PayBlock    pay_block;
@property (copy, nonatomic) DeleteBlock delete_block;

@end

@implementation ShoppingCartBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self createContentView];
    }
    return self;
}

- (void)createContentView {
    CGFloat buttonHeight = 44;
    CGFloat buttonWidth  = 80.f;

    _chooseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    [_chooseBtn setTitle:@"  全選" forState:(UIControlStateNormal&UIControlStateSelected)];
    [_chooseBtn setImage:[UIImage imageNamed:@"shoppingNonSelect"] forState:UIControlStateNormal];
    [_chooseBtn setImage:[UIImage imageNamed:@"shoppingSelected"] forState:UIControlStateSelected];
    [_chooseBtn addTarget:self action:@selector(chooseAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_chooseBtn];
    
    _moneyLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_chooseBtn.frame), 2, 145, 22)];
    _moneyLab.textColor = [UIColor whiteColor];
    _moneyLab.textAlignment = NSTextAlignmentRight;
    _moneyLab.font = [UIFont boldSystemFontOfSize:14];
    _moneyLab.text = @"合計：$ 0.00";
    [self addSubview:_moneyLab];
    
    CGRect rect = _moneyLab.frame;
    rect.origin.y = CGRectGetMaxY(_moneyLab.frame);
    _freightLab = [[UILabel alloc] initWithFrame:rect];
    _freightLab.textColor = [UIColor whiteColor];
    _freightLab.font = [UIFont systemFontOfSize:14];
    _freightLab.textAlignment = NSTextAlignmentRight;
    _freightLab.text = @"(不含運費)";
    [self addSubview:_freightLab];
    
    _deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(KScreenWidth-buttonWidth, 0, buttonWidth, buttonHeight)];
    [_deleteBtn setTitle:@"刪除" forState:(UIControlStateNormal&UIControlStateHighlighted)];
    [_deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"取消"] forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_deleteBtn];
    
    _payBtn = [[UIButton alloc] initWithFrame:_deleteBtn.frame];
    [_payBtn setTitle:@"付款" forState:(UIControlStateNormal&UIControlStateHighlighted)];
    [_payBtn setTitleColor:RGBCOLOR(53, 49, 51) forState:UIControlStateNormal];
    [_payBtn setBackgroundImage:[UIImage imageNamed:@"ensure"] forState:UIControlStateNormal];
    [_payBtn addTarget:self action:@selector(payMoneyAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_payBtn];
}

- (void)setChooseBlock:(void (^)(BOOL))block {
    self.choose_block = block;
}

- (void)setPayActionBlock:(void (^)())block {
    self.pay_block = block;
}

- (void)setDeleteActionBlock:(void (^)())block {
    self.delete_block = block;
}

- (void)setViewType:(BottomType)type {
//    if (type == TypePayMoney) {
//        _moneyLab.hidden = _freightLab.hidden = NO;
//        _payBtn.hidden = NO;
//    } else if (type == TypeDelete) {
//        _moneyLab.hidden = _freightLab.hidden = YES;
//        _payBtn.hidden = YES;
//    }
    
    _moneyLab.hidden = _freightLab.hidden = !(type == TypePayMoney);
    _payBtn.hidden = !(type == TypePayMoney);
}

#pragma mark - 付款
- (void)payMoneyAction:(UIButton *)sender {
    if (self.pay_block) {
        self.pay_block();
    }
}

#pragma mark - 刪除
- (void)deleteAction:(UIButton *)sender {
    if (self.delete_block) {
        self.delete_block();
    }
}

#pragma mark - 選擇
- (void)chooseAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.choose_block) {
        self.choose_block(sender.selected);
    }
}

@end
