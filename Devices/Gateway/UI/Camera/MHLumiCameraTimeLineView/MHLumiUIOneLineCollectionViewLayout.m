//
//  MHLumiUIOneLineCollectionViewLayout.m
//  OneLineCollectionView
//
//  Created by Noverre on 2016/10/21.
//  Copyright © 2016年 Noverre. All rights reserved.
//

#import "MHLumiUIOneLineCollectionViewLayout.h"

/** 每一列之间的间距 */
static const CGFloat defaultColumnMargin = 10;

static const CGSize defaultItemSize = {50,50};

/** 边缘间距 */
static const UIEdgeInsets defaultEdgeInsets = {0, 0, 0, 0};

static const UIEdgeInsets defaultItemEdgeInsets = {0, 0, 0, 0};


@interface MHLumiUIOneLineCollectionViewLayout()
/** 存放所有cell的布局属性 */
@property (strong, nonatomic) NSMutableArray *attrsArray;

@property (assign, nonatomic) CGFloat currentX;

@property (assign, nonatomic) CGFloat aWidthOfContentSize;
- (CGFloat)columnMarginAtIndex:(NSUInteger) index;
- (CGSize)itemSizeAtIndex:(NSUInteger) index;
- (UIEdgeInsets)itemInsetsAtIndex:(NSUInteger) index;
- (UIEdgeInsets)edgeInsets;
@end

@implementation MHLumiUIOneLineCollectionViewLayout

#pragma mark - 常见数据处理

- (CGFloat)columnMarginAtIndex:(NSUInteger) index{
    if ([self.delegate respondsToSelector:@selector(oneLineLayout:columnMarginAtIndex:)]) {
        return [self.delegate oneLineLayout:self columnMarginAtIndex:index];
    } else {
        return defaultColumnMargin;
    }
}

- (UIEdgeInsets)edgeInsets{
    if ([self.delegate respondsToSelector:@selector(edgeInsetsInOneLineLayout:)]) {
        return [self.delegate edgeInsetsInOneLineLayout:self];
    } else {
        return defaultEdgeInsets;
    }
}

- (CGSize)itemSizeAtIndex:(NSUInteger)index{
    if ([self.delegate respondsToSelector:@selector(oneLineLayout:itemSizeAtIndex:)]) {
        return [self.delegate oneLineLayout:self itemSizeAtIndex:index];
    } else {
        return defaultItemSize;
    }
}

- (UIEdgeInsets)itemInsetsAtIndex:(NSUInteger)index{
    if ([self.delegate respondsToSelector:@selector(oneLineLayout:itemInsetsAtIndex:)]) {
        return [self.delegate oneLineLayout:self itemInsetsAtIndex:index];
    } else {
        return defaultItemEdgeInsets;
    }
}
/**
 * 初始化
 */
- (void)prepareLayout
{
    NSLog(@"0-0-0-0-0-0-0-0-0-0-0-0-0");
    [super prepareLayout];

    // 清除之前所有的布局属性
    [self.attrsArray removeAllObjects];
    self.currentX = self.edgeInsets.left;
    self.aWidthOfContentSize = self.collectionView.frame.size.width;
    // 开始创建每一个cell对应的布局属性
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < count; i++) {
        // 创建位置
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        // 获取indexPath位置cell对应的布局属性
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attrsArray addObject:attrs];
    }
}

/**
 * 决定cell的排布
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *resetAttay = [NSMutableArray array];
    for (NSUInteger index = 0; index < self.attrsArray.count; index ++) {
        UICollectionViewLayoutAttributes *toAttr = self.attrsArray[index];
        if (CGRectIntersectsRect(rect,toAttr.frame)) {
            [resetAttay addObject:toAttr];
        }
    }
    return resetAttay;
}

/**
 * 返回indexPath位置cell对应的布局属性
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 创建布局属性
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    // 设置布局属性的frame
    CGSize size = [self itemSizeAtIndex:indexPath.item];
    if (size.height > CGRectGetHeight(self.collectionView.bounds)){
        size = CGSizeMake(size.width, CGRectGetHeight(self.collectionView.bounds));
    }
    UIEdgeInsets itemInsets = [self itemInsetsAtIndex:indexPath.item];
    CGFloat x = self.currentX + itemInsets.left;
    CGFloat y = self.edgeInsets.top + itemInsets.top;
    attrs.frame = CGRectMake(x, y, size.width, size.height);
    self.currentX = CGRectGetMaxX(attrs.frame);
    CGFloat w = self.currentX + itemInsets.right + self.edgeInsets.right;
    self.aWidthOfContentSize = MAX(self.aWidthOfContentSize, w);
    return attrs;
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.aWidthOfContentSize, 0);
}

#pragma mark - getter and setter
- (NSMutableArray *)attrsArray{
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

@end
