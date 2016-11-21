//
//  MHDeviceCamera.h
//  MiHome
//
//  Created by ayanami on 8/20/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHDeviceGateway.h"

typedef NS_ENUM(NSInteger,MHLumiDeviceCameraMode){
    MHLumiDeviceCameraModeFloor            = 0,
    MHLumiDeviceCameraModeCeiling,
    MHLumiDeviceCameraModeWall,
};

@interface MHDeviceCamera : MHDeviceGateway

@property (nonatomic, assign)MHLumiDeviceCameraMode OperatingMode;
@property (nonatomic, copy) NSString *UID;
@property (nonatomic, copy) NSString *udid;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) CGFloat centerPointOffsetX;
@property (nonatomic, assign) CGFloat centerPointOffsetY;
@property (nonatomic, assign) CGFloat centerPointOffsetR;

- (void)getUidSuccess:(void(^)(NSString *udid,NSString *password))success failure:(FailedBlock)failure ;
/**
 *  开关摄像头
 *
 *  @param toggle  @"on"/@"off"
 *  @param success success description
 *  @param failure failure description
 */
- (void)setVideoParams:(NSString *)toggle Success:(SucceedBlock)success failure:(FailedBlock)failure;

- (void)setVideoWithOnOff:(BOOL)onOrOff uid:(NSString *)uid success:(void (^)(BOOL))success failure:(void (^)(NSError *))failure;

//camera mode
- (void)setCameraMode:(MHLumiDeviceCameraMode)mode
              success:(void (^)(MHDeviceCamera *deviceCamera, MHLumiDeviceCameraMode mode))completedHandler
              failure:(FailedBlock)failure;

#pragma mark - 获取鱼眼校正的中心点偏移量
- (void)fetchCameraCenterPointOffsetSuccess:(void (^)(MHDeviceCamera *client))success failure:(void (^)(NSError *))failure;

#pragma mark - 图像反转
- (void)cameraOverturnWithSuccess:(void (^)(MHDeviceCamera *client))success failure:(void (^)(NSError *))failure;
@end
