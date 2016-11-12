//
//  MHGatewayPopMenuView.h
//  MiHome
//
//  Created by guhao on 4/14/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MHGatewayPopMenuView;
@protocol  MHGatewayPopMenuViewDelegate <NSObject>
/**
 *  选中回调
 *
 *  @param popMenuView
 *  @param index       选中行
 *  @param identifier  选中行标识,数字标识通过switch不易修改,设备页的更多选项以后也可以考虑改成这种
 */
- (void)popMenuView:(MHGatewayPopMenuView*)popMenuView didSelectedRow:(NSInteger)index identifier:(NSString *)identifier;

@optional
/**
 *  下拉菜单数据源
 *
 *  @return
 */
- (NSArray*)popMenuDataSource;

@end

@interface MHGatewayPopMenuView : UIView

@property(nonatomic, strong) id<MHGatewayPopMenuViewDelegate> delegate;


- (void)showViewInView:(UIView*)view;

- (void)hideView;

- (void)updateData;
@end
