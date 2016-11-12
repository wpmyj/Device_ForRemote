//
//  MHLumiJavascriptObjectBridge.h
//  MiHome
//
//  Created by guhao on 3/14/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "MHDeviceGateway.h"
#import "MHDeviceGatewaySensorHumiture.h"
#import "MHDeviceGatewaySensorPlug.h"

typedef NS_ENUM(NSInteger, SHAREPLATFORM) {
    WXTIMELINE = 1,
    WXSESSION,
    WBTIMELINE,
};
typedef void (^addSubDevice)(NSString *className, NSString *deviceName);
typedef void (^userChooseLogo)(NSString *gid, NSArray *imageUrls);

@protocol MHLumiJavascriptObjectBridgeProtocol <JSExport>

/**
 *  @brief web端调用分享接口,JSExportAs(<#PropertyName#>, <#Selector#>)将OC方法名简写
 
 */
//米聊号
- (NSString *)sendUserID;
//用户昵称
- (NSString *)sendNickName;
//网关id
- (NSString *)sendGatewayDeviceID;
//网关model
- (NSString *)sendGatewayDeviceModel;
//温湿度id
- (NSString *)sendHumitureDeviceDid;
//插座id
- (NSString *)sendPlugDeviceDid;
//app版本
- (NSString *)sendAppVersion;
//当前设备的did
- (NSString *)sendCurrentDeviceDid;
//当前设备的model
- (NSString *)sendCurrentDeviceModel;


//购买跳转app商城
- (void)goToMall;
/**
 *  子设备开始入网
 *
 *  @param subdeviceModel 子设备model类名
 *  @param deviceName     子设备名字
 *
 */
JSExportAs(startAddSubDevice, - (void)startAddSubdevice:(NSString *)subdeviceModel andDeviceName:(NSString *)deviceName);

JSExportAs(sendImageIDAndImageUrls, -(void)sendImageID:(NSString *)imageID andImageName:(NSString *)imageName andImageUrls:(NSArray *)imageUrls);


/**
 *  分享链接
 *
 *  @param shareType   分享平台(1-朋友圈, 2-朋友, 3-微博)
 *  @param title       标题
 *  @param description 描述
 *  @param thumbnail   内容缩略图
 *  @param url         url
 */
JSExportAs(shareUrlMethod, - (void)shareUrlWithType:(SHAREPLATFORM)shareType
           Title:(NSString *)title
           description:(NSString *)description
           thumbnail:(NSString *)thumbnailUrl
           url:(NSString *)url);

@end
@interface MHLumiJavascriptObjectBridge : NSObject <MHLumiJavascriptObjectBridgeProtocol>

@property (nonatomic, strong) MHDeviceGateway *gatewayDevice;
@property (nonatomic, strong) MHDeviceGatewayBase *currentDevice;
@property (nonatomic, strong) NSString *deviceDid;
@property (nonatomic, strong) addSubDevice addSubDeviceCallBack;
@property (nonatomic, strong) userChooseLogo chooseLogoCallBack;

- (id)initWithJSContext:(JSContext *)jsContext;

@end
