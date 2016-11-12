//
//  MHLumiUIOneLineCollectionViewLayout.h
//  OneLineCollectionView
//
//  Created by Noverre on 2016/10/21.
//  Copyright © 2016年 Noverre. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MHLumiUIOneLineCollectionViewLayout;
@protocol MHLumiUIOneLineCollectionViewLayoutDelegate <NSObject>
@required
- (CGSize)oneLineLayout:(MHLumiUIOneLineCollectionViewLayout *)oneLineLayout itemSizeAtIndex:(NSUInteger)index;

@optional
- (CGFloat)oneLineLayout:(MHLumiUIOneLineCollectionViewLayout *)oneLineLayout columnMarginAtIndex:(NSUInteger)index;
- (UIEdgeInsets)edgeInsetsInOneLineLayout:(MHLumiUIOneLineCollectionViewLayout *)oneLineLayout;
- (UIEdgeInsets)oneLineLayout:(MHLumiUIOneLineCollectionViewLayout *)oneLineLayout itemInsetsAtIndex:(NSUInteger)index;
@end


@interface MHLumiUIOneLineCollectionViewLayout : UICollectionViewLayout
@property (weak, nonatomic) id<MHLumiUIOneLineCollectionViewLayoutDelegate> delegate;
@end
