//
//  MHDeviceGatewayBaseService.h
//  MiHome
//
//  Created by Lynn on 2/19/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHDeviceGatewayBaseService : NSObject

@property (nonatomic,assign) int serviceId;
@property (nonatomic,strong) NSString *serviceParentDid;
@property (nonatomic,strong) NSString *serviceParentClass;
@property (nonatomic,strong) NSString *serviceParentModel;
@property (nonatomic,strong) NSString *serviceName;
@property (nonatomic,strong) UIImage *serviceIcon;
@property (nonatomic,strong) NSString *serviceIconId;
@property (nonatomic,assign) BOOL isOpen;
@property (nonatomic,assign) BOOL isOnline;
@property (nonatomic,assign) BOOL isDisable;

- (void)serviceMethod;
@property (nonatomic,strong) void (^serviceMethodCallBack)(MHDeviceGatewayBaseService *service);
@property (nonatomic,strong) void (^serviceMethodSuccess)(id obj);
@property (nonatomic,strong) void (^serviceMethodFailure)(NSError *error);

- (void)changeName;
@property (nonatomic,strong) void (^serviceChangeNameCall)(MHDeviceGatewayBaseService *service);
@property (nonatomic,strong) void (^serviceChangeNameSuccess)(id obj);
@property (nonatomic,strong) void (^serviceChangeNameFailure)(NSError *error);

- (void)changeIcon;

/**
 *  获取图片名字
 *
 *  @param header            首页传 home，设备页传 lumi
 *
 *  @return icon Id
 */
- (NSString *)fetchIconNameWithHeader:(NSString *)header;

@end
