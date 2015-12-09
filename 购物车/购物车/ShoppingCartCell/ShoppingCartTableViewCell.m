//
//  ShoppingCartTableViewCell.m
//  OShopping
//
//  Created by SuperDanny on 15/11/12.
//  Copyright © 2015年 SuperDanny. All rights reserved.
//

#import "ShoppingCartTableViewCell.h"

typedef void(^ChooseBlock)(BOOL isSelect);
typedef void(^ChangeBlock)(NSUInteger count);

@interface ShoppingCartTableViewCell () <UITextFieldDelegate>

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

- (void)configureCellDataWithModel:(GoodsModel *)model cellType:(ShoppingCartCellType)cellType {
    
    _chooseBtn.hidden = (cellType == CellTypeBuying);
    
    //原价
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"$ %@", model.originalPrice]];
    NSRange contentRange = {0,[content length]};
    [content addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle|NSUnderlinePatternSolid) range:contentRange];
    _OriginalPriceLab.attributedText = content;
    
    //单价
    _CurrentPriceLab.text = [NSString stringWithFormat:@"$ %@", model.price];
    
    //数量
    _ProductCountTf.text = model.amount;
    
    //总价
    CGFloat prices = [model.amount integerValue]*[model.price floatValue];
    _totalPrices = [NSString stringWithFormat:@"%.2lf", prices];
    
    //是否选择
    _chooseBtn.selected = model.isSelect;
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
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"親，該寶貝不能購買更多哦", nil)];
        return;
    }
    count++;
    _ProductCountTf.text = [NSString stringWithFormat:@"%lu",count];
    [self updateWithCount:count];
}

#pragma mark - 减少数量
- (IBAction)reduceAction:(UIButton *)sender {
    NSUInteger count = [_ProductCountTf.text integerValue];
    if (count == 1) {
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"親，該寶貝不能再減少了哦", nil)];
        return;
    }
    count--;
    _ProductCountTf.text = [NSString stringWithFormat:@"%lu",count];
    [self updateWithCount:count];
}

#pragma mark - 更新数量
- (void)updateWithCount:(NSUInteger)count {
    if (self.change_Block) {
        self.change_Block(count);
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length) {
        NSString *tempStr = [textField.text stringByAppendingString:string];
        BOOL b = [AmountTools limitTheNumberString:tempStr andNextString:string andIntLength:3 andPointLength:0];
        return b;
    }
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
}

@end
