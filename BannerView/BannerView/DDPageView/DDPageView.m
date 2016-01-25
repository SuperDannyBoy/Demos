//
//  DDPageView.m
//  BannerView
//
//  Created by SuperDanny on 16/1/22.
//  Copyright © 2016年 SuperDanny. All rights reserved.
//

#import "DDPageView.h"
#import <objc/runtime.h>

#define ITEM_WIDTH [[UIScreen mainScreen] bounds].size.width

@interface DDPageView () <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) BOOL          isAutoPlay;
@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer       *timer;

@end

static NSString *DDPageItemsKey = @"DDPageItemsKey";

static CGFloat ScrollTime = 5.0;

@implementation DDPageView

- (id)initWithFrame:(CGRect)frame delegate:(id<DDPageViewDelegate>)delegate focusImageItems:(DDPageItem *)firstItem, ... {
    NSMutableArray *imageItems = [NSMutableArray array];
    DDPageItem *eachItem;
    va_list argumentList;
    if (firstItem) {
        [imageItems addObject: firstItem];
        va_start(argumentList, firstItem);
        while ((eachItem = va_arg(argumentList, DDPageItem *))) {
            [imageItems addObject: eachItem];
        }
        va_end(argumentList);
    }
    return [self initWithFrame:frame delegate:delegate imageArray:imageItems isAuto:YES];
}

- (id)initWithFrame:(CGRect)frame delegate:(id<DDPageViewDelegate>)delegate imageArray:(NSArray *)array isAuto:(BOOL)isAuto {
    if (self = [super initWithFrame:frame]) {
        _isAutoPlay = isAuto;
        [self setImageItems:array];
        [self setupViews];
        self.delegate = delegate;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<DDPageViewDelegate>)delegate imageArray:(NSArray *)array {
    return [self initWithFrame:frame delegate:delegate imageArray:array isAuto:YES];
}

- (void)dealloc {
    objc_setAssociatedObject(self, (__bridge const void *)DDPageItemsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _scrollView.delegate = nil;
}

#pragma mark -
- (void)reloadData:(NSArray *)array {
    [self setImageItems:array];
    [self setupViews];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - private methods
- (void)setImageItems:(NSArray *)array {
    NSUInteger length = [array count];
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:length+2];
    //添加最后一张图 用于循环
    if (length > 1) {
        NSDictionary *dict = array[length-1];
        DDPageItem *item = [[DDPageItem alloc] initWithDict:dict tag:-1];
        [itemArray addObject:item];
    }
    for (int i = 0; i < length; i++) {
        NSDictionary *dict = array[i];
        DDPageItem *item = [[DDPageItem alloc] initWithDict:dict tag:i];
        [itemArray addObject:item];
    }
    //添加第一张图 用于循环
    if (length >1) {
        NSDictionary *dict = array[0];
        DDPageItem *item = [[DDPageItem alloc] initWithDict:dict tag:length];
        [itemArray addObject:item];
    }
    
    NSMutableArray *imageItems = [NSMutableArray arrayWithArray:itemArray];
    objc_setAssociatedObject(self, (__bridge const void *)DDPageItemsKey, imageItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (_timer) {
        [self stopTimer];
    }
    [self createTimer];
}

- (void)createTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:ScrollTime target:self selector:@selector(switchFocusImageItems) userInfo:nil repeats:YES];
}

- (void)setupViews {
    NSArray *imageItems = objc_getAssociatedObject(self, (__bridge const void *)DDPageItemsKey);
    
    if (!_scrollView) {
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        _scrollView = [[UIScrollView alloc] initWithFrame:rect];
        [self addSubview:_scrollView];
    }
    for (UIView *view in _scrollView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    _scrollView.scrollsToTop                   = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled                  = YES;
    _scrollView.delegate                       = self;
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame) * imageItems.count, CGRectGetHeight(_scrollView.frame));
    /*
     _scrollView.layer.cornerRadius = 10;
     _scrollView.layer.borderWidth = 1 ;
     _scrollView.layer.borderColor = [[UIColor lightGrayColor ] CGColor];
     */
    
    float space = 0;
    CGSize size = CGSizeMake(ITEM_WIDTH, 0);
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height -10-5, ITEM_WIDTH, 5)];
        [self addSubview:_pageControl];
    }
    _pageControl.userInteractionEnabled = NO;
    _pageControl.hidesForSinglePage     = YES;
    //    _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    _pageControl.numberOfPages = imageItems.count > 1 ? imageItems.count-2 : imageItems.count;
    _pageControl.currentPage = 0;
    
    // single tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    tapGestureRecognize.delegate = self;
    tapGestureRecognize.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:tapGestureRecognize];
    
    for (int i = 0; i < imageItems.count; i++) {
        //        DDPageItem *item = imageItems[i];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * _scrollView.frame.size.width+space, space, _scrollView.frame.size.width-space*2, _scrollView.frame.size.height-2*space-size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor whiteColor];
        //加载图片
        //        imageView.backgroundColor = i%2?[UIColor redColor]:[UIColor blueColor];
        DDPageItem *item = imageItems[i];
        NSURL *url = [NSURL URLWithString:item.imageURL];
        [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholderImage1"]];
        [_scrollView addSubview:imageView];
    }
    if (imageItems.count > 1) {
        [_scrollView setContentOffset:CGPointMake(ITEM_WIDTH, 0) animated:NO] ;
        if (_isAutoPlay) {
            if (_timer) {
                [self stopTimer];
            }
            [self createTimer];
        }
    }
}

- (void)switchFocusImageItems {
    CGFloat targetX = _scrollView.contentOffset.x + _scrollView.frame.size.width;
    //    NSArray *imageItems = objc_getAssociatedObject(self, (__bridge const void *)DDPageItemsKey);
    targetX = (int)(targetX/ITEM_WIDTH) * ITEM_WIDTH;
    [self moveToTargetPosition:targetX];
}

- (void)singleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    NSArray *imageItems = objc_getAssociatedObject(self, (__bridge const void *)DDPageItemsKey);
    int page = (int)(_scrollView.contentOffset.x / _scrollView.frame.size.width);
    if (page > -1 && page < imageItems.count) {
        DDPageItem *item = imageItems[page];
        if ([self.delegate respondsToSelector:@selector(foucusView:didSelectItem:index:)]) {
            [self.delegate foucusView:self didSelectItem:item index:item.tag];
        }
    }
}

- (void)moveToTargetPosition:(CGFloat)targetX {
    BOOL animated = YES;
    //    NSLog(@"moveToTargetPosition : %f" , targetX);
    [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:animated];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float targetX = scrollView.contentOffset.x;
    NSArray *imageItems = objc_getAssociatedObject(self, (__bridge const void *)DDPageItemsKey);
    if (imageItems.count >= 3) {
        if (targetX >= ITEM_WIDTH * (imageItems.count-1)) {
            targetX = ITEM_WIDTH;
            [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
        }
        else if(targetX <= 0) {
            targetX = ITEM_WIDTH *(imageItems.count-2);
            [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
        }
    }
    int page = (_scrollView.contentOffset.x+ITEM_WIDTH/2.0) / ITEM_WIDTH;
    //    NSLog(@"%f %d",_scrollView.contentOffset.x,page);
    if (imageItems.count > 1) {
        page--;
        if (page >= _pageControl.numberOfPages) {
            page = 0;
        } else if (page < 0) {
            page = _pageControl.numberOfPages-1;
        }
    }
    if (page != _pageControl.currentPage) {
        if ([self.delegate respondsToSelector:@selector(foucusView:currentItem:)]) {
            [self.delegate foucusView:self currentItem:page];
        }
    }
    _pageControl.currentPage = page;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        CGFloat targetX = _scrollView.contentOffset.x + _scrollView.frame.size.width;
        targetX = (int)(targetX/ITEM_WIDTH) * ITEM_WIDTH;
        [self moveToTargetPosition:targetX];
    }
}

- (void)scrollToIndex:(int)aIndex {
    NSArray *imageItems = objc_getAssociatedObject(self, (__bridge const void *)DDPageItemsKey);
    if (imageItems.count > 1) {
        if (aIndex >= (imageItems.count-2)) {
            aIndex = imageItems.count-3;
        }
        [self moveToTargetPosition:ITEM_WIDTH*(aIndex+1)];
    } else {
        [self moveToTargetPosition:0];
    }
    [self scrollViewDidScroll:_scrollView];
    
}
@end