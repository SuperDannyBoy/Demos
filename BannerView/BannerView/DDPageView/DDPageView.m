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

@end

static NSString *DDPageItemsKey = @"DDPageItemsKey";

static CGFloat ScrollTime = 5.0;

@implementation DDPageView

- (id)initWithFrame:(CGRect)frame delegate:(id<DDPageViewDelegate>)delegate focusImageItems:(DDPageItem *)firstItem, ... {
    if (self = [super initWithFrame:frame]) {
        NSMutableArray *imageItems = [NSMutableArray array];
        DDPageItem *eachItem;
        va_list argumentList;
        if (firstItem)
        {
            [imageItems addObject: firstItem];
            va_start(argumentList, firstItem);
            while((eachItem = va_arg(argumentList, DDPageItem *)))
            {
                [imageItems addObject: eachItem];
            }
            va_end(argumentList);
        }
        
        objc_setAssociatedObject(self, (__bridge const void *)DDPageItemsKey, imageItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        _isAutoPlay = YES;
        [self setupViews];
        
        self.delegate = delegate;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<DDPageViewDelegate>)delegate imageItems:(NSArray *)items isAuto:(BOOL)isAuto {
    if (self = [super initWithFrame:frame]) {
        NSUInteger length = [items count];
        NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:length+2];
        //添加最后一张图 用于循环
        if (length > 1) {
            NSDictionary *dict = items[length-1];
            DDPageItem *item = [[DDPageItem alloc] initWithDict:dict tag:-1];
            [itemArray addObject:item];
        }
        for (int i = 0; i < length; i++) {
            NSDictionary *dict = items[i];
            DDPageItem *item = [[DDPageItem alloc] initWithDict:dict tag:i];
            [itemArray addObject:item];
        }
        //添加第一张图 用于循环
        if (length >1) {
            NSDictionary *dict = items[0];
            DDPageItem *item = [[DDPageItem alloc] initWithDict:dict tag:length];
            [itemArray addObject:item];
        }
        
        NSMutableArray *imageItems = [NSMutableArray arrayWithArray:itemArray];
        objc_setAssociatedObject(self, (__bridge const void *)DDPageItemsKey, imageItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        _isAutoPlay = isAuto;
        [self setupViews];
        
        self.delegate = delegate;
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<DDPageViewDelegate>)delegate imageItems:(NSArray *)items {
    return [self initWithFrame:frame delegate:delegate imageItems:items isAuto:YES];
}

- (void)dealloc {
    objc_setAssociatedObject(self, (__bridge const void *)DDPageItemsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _scrollView.delegate = nil;
}

#pragma mark - private methods
- (void)setupViews {
    NSArray *imageItems = objc_getAssociatedObject(self, (__bridge const void *)DDPageItemsKey);
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.scrollsToTop = NO;
    float space = 0;
    CGSize size = CGSizeMake(ITEM_WIDTH, 0);
    //    _pageControl = [[GPSimplePageView alloc] initWithFrame:CGRectMake(self.bounds.size.width *.5 - size.width *.5, self.bounds.size.height - size.height, size.width, size.height)];
    //    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height -16-10, 320, 10)];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height -16-10, ITEM_WIDTH, 10)];
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_scrollView];
    [self addSubview:_pageControl];
    
    /*
     _scrollView.layer.cornerRadius = 10;
     _scrollView.layer.borderWidth = 1 ;
     _scrollView.layer.borderColor = [[UIColor lightGrayColor ] CGColor];
     */
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    
    _pageControl.numberOfPages = imageItems.count > 1 ? imageItems.count-2 : 0;
    _pageControl.currentPage = 0;
    
    _scrollView.delegate = self;
    
    // single tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    tapGestureRecognize.delegate = self;
    tapGestureRecognize.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:tapGestureRecognize];
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * imageItems.count, _scrollView.frame.size.height);
    
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
            [self performSelector:@selector(switchFocusImageItems)
                       withObject:nil
                       afterDelay:ScrollTime];
        }
    }
}

- (void)switchFocusImageItems {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(switchFocusImageItems)
                                               object:nil];
    
    CGFloat targetX = _scrollView.contentOffset.x + _scrollView.frame.size.width;
    NSArray *imageItems = objc_getAssociatedObject(self, (__bridge const void *)DDPageItemsKey);
    targetX = (int)(targetX/ITEM_WIDTH) * ITEM_WIDTH;
    [self moveToTargetPosition:targetX];
    
    if (imageItems.count > 1 && _isAutoPlay) {
        [self performSelector:@selector(switchFocusImageItems)
                   withObject:nil
                   afterDelay:ScrollTime];
    }
    
}

- (void)singleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    NSArray *imageItems = objc_getAssociatedObject(self, (__bridge const void *)DDPageItemsKey);
    NSInteger page = (NSInteger)(_scrollView.contentOffset.x / _scrollView.frame.size.width);
    if (page > -1 && page < imageItems.count) {
        DDPageItem *item = imageItems[page];
        if ([self.delegate respondsToSelector:@selector(foucusView:didSelectItem:index:)]) {
            if (imageItems.count <= 1) {
                page = 1;
            }
            [self.delegate foucusView:self didSelectItem:item index:page-1];
        }
    }
}

- (void)moveToTargetPosition:(NSInteger)targetX {
    BOOL animated = YES;
//    NSLog(@"moveToTargetPosition : %f" , targetX);
    [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:animated];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float targetX = scrollView.contentOffset.x;
    NSArray *imageItems = objc_getAssociatedObject(self, (__bridge const void *)DDPageItemsKey);
    if (imageItems.count >= 3) {
        if (targetX >= ITEM_WIDTH * (imageItems.count -1)) {
            targetX = ITEM_WIDTH;
            [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
        }
        else if(targetX <= 0) {
            targetX = ITEM_WIDTH *(imageItems.count-2);
            [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
        }
    }
    NSInteger page = (NSInteger)(_scrollView.contentOffset.x+ITEM_WIDTH/2.0) / ITEM_WIDTH;
    //    NSLog(@"%f %d",_scrollView.contentOffset.x,page);
    if (imageItems.count > 1) {
        page--;
        if (page >= _pageControl.numberOfPages) {
            page = 0;
        } else if (page <= 0) {
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
        targetX = (NSInteger)(targetX/ITEM_WIDTH) * ITEM_WIDTH;
        [self moveToTargetPosition:targetX];
    }
}

- (void)scrollToIndex:(NSInteger)aIndex {
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