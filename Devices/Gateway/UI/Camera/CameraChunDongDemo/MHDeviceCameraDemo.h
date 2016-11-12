//
//  MHDeviceCameraDemo.h
//  MiHome
//
//  Created by huchundong on 2016/8/23.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MiHomeKit/MHDevice.h>
#import "MHDeviceGateway.h"
#import "MHGetP2PIdResponse.h"
#import "TUTKClient.h"
typedef NS_ENUM(NSInteger,MHLumiDeviceCameraMode){
    MHLumiDeviceCameraModeFloor            = 0,
    MHLumiDeviceCameraModeCeiling,
    MHLumiDeviceCameraModeWall,
};

@interface MHDeviceCameraDemo : MHDeviceGateway

@property(nonatomic, strong) TUTKClient* client;
@property(nonatomic, copy) NSString *udid;
@property(nonatomic, copy) NSString *password;
@property(nonatomic, assign) MHLumiDeviceCameraMode cameraMode;

- (void)getP2PId:(NSString*)did callback:(void(^)(MHGetP2PIdResponse*))handle;
- (void)getUidSuccess:(void(^)(NSString *udid,NSString *password))success failure:(FailedBlock)failure;
- (void)setVideoWithOnOff:(BOOL) onOrOff
                      uid:(NSString *)uid
                  success:(void(^)(BOOL currentOnOrOff))success
                  failure:(void(^)(NSError *error))failure;

- (void)setCameraMode:(MHLumiDeviceCameraMode)mode
              success:(void (^)(MHDeviceCameraDemo *deviceCamera, MHLumiDeviceCameraMode mode))completedHandler
              failure:(FailedBlock)failure;
@end
