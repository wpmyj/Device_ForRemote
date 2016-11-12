//
//  MHGatewaySceneMenuView.h
//  MiHome
//
//  Created by guhao on 16/5/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MHGatewaySceneMenuView;
@protocol  MHGatewaySceneMenuViewDelegate <NSObject>
/**
 *  选中回调
 *
 *  @param popMenuView
 *  @param index       选中行
 *  @param identifier  选中行标识,数字标识通过switch不易修改,设备页的更多选项以后也可以考虑改成这种
 */
- (void)menuViewDidSelectedRow:(NSInteger)index did:(id)did name:(NSString *)name;


@end


@interface MHGatewaySceneMenuView : UIView

//- (id)initWithGateway:(MHDeviceGateway *)gateway;

- (id)initWithDataSource:(NSArray *)dataSource;

@property (nonatomic, strong) id<MHGatewaySceneMenuViewDelegate> delegate;
@property (nonatomic, strong) id seletedDid;
@property (nonatomic, copy) void(^footerHide)(void);


- (void)showViewInView:(UIView*)view;

- (void)hideView;
@end
