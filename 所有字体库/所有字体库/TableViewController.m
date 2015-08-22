//
//  TableViewController.m
//  所有字体库
//
//  Created by SuperDanny on 15/3/18.
//  Copyright (c) 2015年 Danny_Changhui. All rights reserved.
//

#import "TableViewController.h"

static NSString *reuseIdentifier = @"Cell";

@interface TableViewController ()

@property (strong, nonatomic) NSArray  *fontArr;
@property (copy, nonatomic  ) NSString *fontNameStr;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fontArr = [UIFont familyNames];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_fontArr.count) {
        return _fontArr.count;
    }else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.textLabel.font = [UIFont fontWithName:_fontArr[indexPath.row] size:14];
    cell.textLabel.text = @"小灰灰！ABCDCFG.。abcdefg***0123456";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _fontNameStr = _fontArr[indexPath.row];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
