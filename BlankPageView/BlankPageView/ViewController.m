//
//  ViewController.m
//  BlankPageView
//
//  Created by SuperDanny on 15/12/11.
//  Copyright © 2015年 SuperDanny. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (strong, nonatomic) UITableView *tb;
@property (strong, nonatomic) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArray = [@[@"1", @"2", @"3", @"4", @"5", @"6"] mutableCopy];
    
    _tb = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.bgView.bounds];
        tableView.backgroundColor = [UIColor colorWithWhite:0.933 alpha:1.000];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        [self.bgView addSubview:tableView];
        tableView;
    });
    [_tb reloadData];
}

#pragma mark - Animation
- (IBAction)start {
    self.bgView.blankPageView.hidden = YES;
    [self.bgView beginLoading];
}

- (IBAction)end {
    self.bgView.blankPageView.hidden = YES;
    [self.bgView endLoading];
}

#pragma mark - Request
- (IBAction)requestFail {
    self.bgView.blankPageView.hidden = YES;
    [self start];
    [self performSelector:@selector(Fail) withObject:nil afterDelay:1.5];
}

- (void)Fail {
    [self end];
    __weak typeof(self) weakSelf = self;
    [self.bgView configBlankPage:EaseBlankPageTypeView hasData:NO hasError:YES reloadButtonBlock:^(id sender) {
        NSLog(@"失败重试");
        [weakSelf requestFail];
    }];
    [_dataArray removeAllObjects];
    [_tb reloadData];
}

- (IBAction)requestNoData {
    self.bgView.blankPageView.hidden = YES;
    [self start];
    [self performSelector:@selector(NoData) withObject:nil afterDelay:1.5];
}

- (void)NoData {
    [self end];
    [self.bgView configBlankPage:EaseBlankPageTypeView hasData:NO hasError:NO reloadButtonBlock:nil];
    [_dataArray removeAllObjects];
    [_tb reloadData];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = _dataArray[indexPath.row];
    cell.backgroundColor = [UIColor colorWithWhite:0.933 alpha:1.000];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
