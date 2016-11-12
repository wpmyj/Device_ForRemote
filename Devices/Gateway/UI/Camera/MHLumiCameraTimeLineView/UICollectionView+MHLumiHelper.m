//
//  UICollectionView+MHLumiHelper.m
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 16/10/22.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import "UICollectionView+MHLumiHelper.h"

@implementation UICollectionView (MHLumiHelper)
- (NSArray<NSIndexPath *> *)indexPathsForElementsInRect:(CGRect)rect{
   NSArray<__kindof UICollectionViewLayoutAttributes *> * attributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    NSMutableArray<NSIndexPath *> *indexpaths = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attr in attributes) {
        [indexpaths addObject:attr.indexPath];
    }
    return indexpaths;
}
@end
