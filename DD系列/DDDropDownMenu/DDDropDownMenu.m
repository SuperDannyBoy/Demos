//
//  DDDropDownMenu.m
//  YanYou_Merchant
//
//  Created by SuperDanny on 16/4/28.
//  Copyright © 2016年 SuperDanny ( http://SuperDanny.link/ ). All rights reserved.
//

#import "DDDropDownMenu.h"

@interface DDDropDownMenu () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (copy, nonatomic) void(^Select_Block)(NSUInteger index);
@property (copy, nonatomic) NSString *(^Title_Block)(NSUInteger index);
@property (copy, nonatomic) NSInteger(^Row_Block)();
@property (assign, nonatomic) NSUInteger viewHeight;

@end

@implementation DDDropDownMenu

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.viewHeight = CGRectGetHeight(frame);
        [self setUp];
    }
    return self;
}

- (void)setUp {
    self.clipsToBounds = YES;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor colorWithWhite:0.651 alpha:1.000].CGColor;
    [self addSubview:self.tableView];
}

- (void)setRowBlock:(NSInteger (^)())block {
    self.Row_Block = block;
}

- (void)setSelectBlock:(void (^)(NSUInteger))block {
    self.Select_Block = block;
}

- (void)setTitleForRowAtIndexBlock:(NSString *(^)(NSUInteger))block {
    self.Title_Block = block;
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

#pragma mark - show
- (void)showInView:(UIView *)view {
    WEAKSELF
    CGRect rect = self.frame;
    rect.size.height = 0;
    self.frame = rect;
    [view addSubview:weakSelf];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = weakSelf.frame;
        rect.size.height = weakSelf.viewHeight;
        weakSelf.frame = rect;
    } completion:^(BOOL finished) {
    }];
}

- (void)reladData {
    [_tableView reloadData];
}

- (void)dismiss {
    WEAKSELF
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = weakSelf.frame;
        rect.size.height = 0;
        weakSelf.frame = rect;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.Row_Block) {
        return self.Row_Block();
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    if (self.Title_Block) {
        cell.textLabel.text = self.Title_Block(indexPath.row);
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.Select_Block) {
        self.Select_Block(indexPath.row);
    }
    [self dismiss];
}

@end
