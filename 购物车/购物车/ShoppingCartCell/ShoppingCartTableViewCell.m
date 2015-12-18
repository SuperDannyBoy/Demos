//
//  ShoppingCartTableViewCell.m
//  OShopping
//
//  Created by SuperDanny on 15/11/12.
//  Copyright © 2015年 MacauIT. All rights reserved.
//

#import "ShoppingCartTableViewCell.h"

typedef void(^ChooseBlock)(BOOL isSelect);
typedef void(^ChangeBlock)(NSUInteger count);

@interface ShoppingCartTableViewCell () <UITextFieldDelegate>

@property (strong, nonatomic) GoodsModel *model;

///选择按钮
@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;
///图片
@property (weak, nonatomic) IBOutlet UIImageView *ProductImageView;
///名称
@property (weak, nonatomic) IBOutlet UILabel     *ProductNameLab;
///规格
@property (weak, nonatomic) IBOutlet UILabel     *ProductSizeLab;
///原价
@property (weak, nonatomic) IBOutlet UILabel     *OriginalPriceLab;
///现价
@property (weak, nonatomic) IBOutlet UILabel     *CurrentPriceLab;
///商品数量
@property (weak, nonatomic) IBOutlet UITextField *ProductCountTf;

///总价
@property (nonatomic, copy) NSString *totalPrices;
///记录数据库最新数量，用于手动编辑数量时做比较
@property (nonatomic, assign) NSUInteger ProductNumber;
///记录是否Cell可以编辑数量
@property (assign, nonatomic) BOOL canEditing;

@property (weak, nonatomic) IBOutlet UIButton *reduceBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;


@property (copy, nonatomic) ChooseBlock choose_Block;
@property (copy, nonatomic) ChangeBlock change_Block;

@end

@implementation ShoppingCartTableViewCell

- (void)awakeFromNib {
    // Initialization code
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    _ProductCountTf.delegate = self;
    _chooseBtn.exclusiveTouch = _addBtn.exclusiveTouch = _reduceBtn.exclusiveTouch = YES;
    _canEditing = YES;
    
    self.backgroundColor = [UIColor grayColor];
}

//- (void)KeyboardWillHideNotification:(NSNotification *)notification {
//    NSUInteger count = [_ProductCountTf.text integerValue];
//    if (count < 1) {
//        [self performSelector:@selector(soLess) withObject:nil afterDelay:0.25];
//        _ProductCountTf.text = @"1";
//    } else if (count > 99) {
//        [self performSelector:@selector(soMore) withObject:nil afterDelay:0.25];
//        _ProductCountTf.text = @"99";
//    }
//}

- (void)soMore {
    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"親，該寶貝不能購買更多哦", nil)];
}

- (void)soLess {
    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"親，該寶貝不能再減少了哦", nil)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setChooseBlock:(void (^)(BOOL))block {
    self.choose_Block = block;
}

- (void)setChangeBlock:(void (^)(NSUInteger))block {
    self.change_Block = block;
}

- (void)configureCellDataWithModel:(GoodsModel *)model cellType:(ShoppingCartCellType)cellType CanEditing:(BOOL)canEditing {
    
    self.model = model;
    self.canEditing = canEditing;
    
    _chooseBtn.hidden = (cellType == CellTypeBuying);
    //圖片
    [_ProductImageView sd_setImageWithURL:[NSURL URLWithString:model.picImage]
                         placeholderImage:[UIImage imageNamed:@"流量副本"]];
    //名稱
    _ProductNameLab.text = model.name;
    //規格
    _ProductSizeLab.text = model.size;
    //原价
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"$ %.2lf", [model.originalPrice floatValue]]];
    NSRange contentRange = {0,[content length]};
    [content addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle|NSUnderlinePatternSolid) range:contentRange];
    _OriginalPriceLab.attributedText = content;
    
    //单价
    _CurrentPriceLab.text = [NSString stringWithFormat:@"$ %.2lf", [model.price floatValue]];
    
    //数量
    _ProductCountTf.text = model.amount;
    _ProductNumber = [model.amount integerValue];
    //检测数量有效性
    [self numberValidity:_ProductCountTf.text];
    
    //总价
    CGFloat prices = [model.amount integerValue]*[model.price floatValue];
    _totalPrices = [NSString stringWithFormat:@"%.2lf", prices];
    
    //是否选择
    _chooseBtn.selected = model.isSelect;
    
    //判断是否可编辑数量
    if (!canEditing) {
        _addBtn.hidden = _reduceBtn.hidden = YES;
        _ProductCountTf.enabled = NO;
        _ProductCountTf.text = [NSString stringWithFormat:@"x%@", model.amount];
        _ProductCountTf.background = nil;
        CGRect rect = _addBtn.frame;
        rect.size.width = 50;
        rect.origin.x = KScreenWidth-50;
        _ProductCountTf.frame = rect;
    }
}

#pragma mark - 选择
- (IBAction)chooseAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.choose_Block) {
        self.choose_Block(sender.selected);
    }
}

#pragma mark - 增加数量
- (IBAction)addAction:(UIButton *)sender {
    
    NSUInteger count = [_ProductCountTf.text integerValue];
    if (count >= 99) {
        [self soMore];
        return;
    }
    count++;
    _ProductCountTf.text = [NSString stringWithFormat:@"%lu",(unsigned long)count];
    _ProductNumber = count;
    //检测数量有效性
    [self numberValidity:_ProductCountTf.text];
    [self updateWithCount:count];
    
    if (sender) {
        [self requestUpdateNum:1];
    }
}

#pragma mark - 减少数量
- (IBAction)reduceAction:(UIButton *)sender {
    NSUInteger count = [_ProductCountTf.text integerValue];
    if (count == 1) {
        [self soLess];
        return;
    }
    count--;
    _ProductCountTf.text = [NSString stringWithFormat:@"%lu",(unsigned long)count];
    _ProductNumber = count;
    //检测数量有效性
    [self numberValidity:_ProductCountTf.text];
    [self updateWithCount:count];
    if (sender) {
        [self requestUpdateNum:0];
    }
}

#pragma mark - 更新数量
- (void)updateWithCount:(NSUInteger)count {
    if (self.change_Block) {
        self.change_Block(count);
    }
}

#pragma mark - 判断数量有效性
- (void)numberValidity:(NSString *)number {
    //判断数量是否小于等于1。如果是则禁止减少按钮
    if ([number integerValue] <= 1) {
        self.reduceBtn.enabled = NO;
    } else {
        self.reduceBtn.enabled = YES;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length) {
        NSString *tempStr = [textField.text stringByAppendingString:string];
        BOOL b = [AmountTools limitTheNumberString:tempStr andNextString:string andIntLength:3 andPointLength:0];
        if (b) {
            //检测数量有效性
            [self numberValidity:tempStr];
        }
        return b;
    }
    //检测数量有效性
    [self numberValidity:[textField.text substringToIndex:textField.text.length-1]];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSUInteger count = [textField.text integerValue];
    if (count < 1) {
        [self soLess];
        textField.text = @"1";
    } else if (count > 99) {
        [self soMore];
        textField.text = @"99";
    }
    [self updateWithCount:[textField.text integerValue]];
    
    [self requestUpdateNum:2];
}

#pragma mark - 数据回滚
- (void)rollback:(NSUInteger)tag {
    //tag：0->减少 1->增加 2->手动编辑数量
    if (tag == 0) {
        [self addAction:nil];
    } else if (tag == 1) {
        [self reduceAction:nil];
    } else if (tag == 2) {
        _ProductCountTf.text = [NSString stringWithFormat:@"%lu",(unsigned long)_ProductNumber];
        [self updateWithCount:_ProductNumber];
    }
}

#pragma mark - Request
#pragma mark 购物车商品数量编辑
- (void)requestUpdateNum:(NSUInteger)tag {
    [SVProgressHUD show];
    /*更新数量失败时，数据回滚*/
    //tag：0->减少 1->增加 2->手动编辑数量
    WEAKSELF
    NSInteger count = 0;
    if (tag == 0) {
        count = -1;
    } else if (tag == 1) {
        count = 1;
    } else if (tag == 2) {
        count = [_ProductCountTf.text integerValue] - _ProductNumber;
    }
//    NSString *goodsNum = [NSString stringWithFormat:@"%ld", (long)count];
    
    //模拟数据请求成功/失败
    BOOL flag = (rand() % 7 != 0);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        if (flag) {
            //手动编辑数量时，成功更新数量做处理。其他情况不做处理
            if (tag == 2) {
                NSUInteger finallyCount = weakSelf.ProductNumber+count;
                weakSelf.ProductCountTf.text = [NSString stringWithFormat:@"%lu",(unsigned long)finallyCount];
                [weakSelf updateWithCount:finallyCount];
            }
        } else {
            [weakSelf rollback:tag];
        }
    });
    
}

@end
