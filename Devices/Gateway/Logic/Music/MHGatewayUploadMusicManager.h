//
//  MHGatewayRecordManager.h
//  MiHome
//
//  Created by Lynn on 10/27/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MiHomeKit/MiHomeKit.h>
#import "MHDeviceGateway.h"

#define UserDefinePdataKey @"lumi_gateway_usermusic_"
#define GatewayDownloadListKey @"lumi_gateway_downloadMusic_map"

@interface MHGatewayUploadMusicManager : NSObject

@property (nonatomic,strong) MHDeviceGateway *device;
@property (nonatomic,strong) void (^uploadProgressBlock)(CGFloat progress);

-(instancetype)initWithDevice:(MHDeviceGateway *)device;

//网关下载音乐列表
-(void)saveGatwayDownloadList:(id)json;
-(id)restoreGatwayDownloadList;
-(void)fetchGatewayDownloadListWithSuccess:(void (^)(id))success andfailure:(void (^)(NSError *))failure;
-(void)setGatewayDownloadListWithSuccess:(void (^)(id))success andfailure:(void (^)(NSError *))failure Value:(id)value;

//A - 读取配置文件，根据命名规则，设置mid，name ...
-(void)fetchUserDefineDataWithPageIndex:(int)pageIndex success:(void (^)(id))success andfailure:(void (^)(NSError *))failure;
//B - 获取文件上传的url
-(void)fetchUserDefineUploadURLWithSuccess:(void (^)(id))success andfailure:(void (^)(NSError *))failure Suffix:(NSString *)suffix;
//C - 上传文件音频文件
-(void)uploadFileWithSuccess:(void (^)(id))success andfailure:(void (^)(NSError *))failure URL:(NSString *)url Suffix:(NSString *)suffix FilePath:(NSURL *)filepath FileName:(NSString *)fileName;
//D - 设置配置文件
-(void)setUserDataWithSuccess:(void (^)(id))success andfailure:(void (^)(NSError *))failure PageIndex:(int)pageIndex Value:(id)value;
//E - 获取下载文件URL
-(void)fetchUserMusicURLWithSuccess:(void (^)(id))success andfailure:(void (^)(NSError *))failure Filename:(NSString *)filename;

@end
