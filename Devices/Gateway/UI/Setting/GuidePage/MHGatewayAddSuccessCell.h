//
//  MHGatewayAddSuccessCell.h
//  MiHome
//
//  Created by ayanami on 16/6/14.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHLumiNamingSpeedCell.h"
#import "MHGatewayAddSubDeviceViewController.h"
#import "MHLumiChooseLogoListManager.h"
#import "MHLumiJavascriptObjectBridge.h"
#import "MHGatewayAddSubDeviceSucceedViewController.h"
#import "MHLumiChangeIconManager.h"
#import "MHLuTextField.h"

#define kCELLID @"MHLumiNamingSpeedCell"


@interface MHGatewayAddSuccessCell : UITableViewCell
@property (nonatomic, strong) MHDeviceGatewayBase *subDevice;
@property (nonatomic, strong) MHLuTextField *nameField;
@property (nonatomic, strong) NSMutableArray *locaitonNames;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, assign) NSInteger selectedItem;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *iconID;


@property (nonatomic, assign) BOOL isLocation;
@property (nonatomic, assign) BOOL isLogo;
@property (nonatomic, assign) BOOL showChangeLogo;
@property (nonatomic, assign) NSInteger serviceIndex;

@property (nonatomic, strong) void (^selectLocation)(BOOL isloaction, NSString *loaction);

- (void)refreshUI;
@end
