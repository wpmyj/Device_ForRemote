//
//  MHGatewayInfoViewController.h
//  MiHome
//
//  Created by LM21Mac002 on 16/9/13.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHLuViewController.h"
#import "GatewayInfoGetter.h"
@class MHGatewayInfoViewController;
@protocol MHGatewayInfoViewControllerDelegate <NSObject>

- (void)gatewayInfoViewController:(MHGatewayInfoViewController *)viewController didTapEncryptionButton:(UIButton *)encryptionButton;

@end

@interface MHGatewayInfoViewController : MHLuViewController

@property (nonatomic, weak) id<GatewayInfoGetter> gatewayInfoGetter;
@property (nonatomic, weak) id<MHGatewayInfoViewControllerDelegate> delegate;
@end
