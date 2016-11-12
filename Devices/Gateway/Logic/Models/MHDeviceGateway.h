//
//  MHDeviceGateway.h
//  MiHome
//
//  Created by Woody on 15/3/31.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>
#import "MHDeviceGatewayBase.h"
#import "MHDataGatewayLog.h"
#import "MHDataScene.h"

#define kGatewayModelV1     @"lumi.gateway.v1"
#define kGatewayModelV2     @"lumi.gateway.v2"
#define kGatewayModelV3     @"lumi.gateway.v3"
#define kACPartnerModelV1   @"lumi.acpartner.v1"

typedef enum : NSInteger {
    RGB_INDEX,
    ILLUMINATION_INDEX,
    MUTE_INDEX,
    ARMING_INDEX,
    GATEWAY_VOLUME_INDEX,
    ALARMING_VOLUME_INDEX,
    DOORBELL_VOLUME_INDEX,
    CLOCK_VOLUME_INDEX,
    FM_VOLUME_INDEX,
    CORRIDOR_LIGHT_INDEX,
    CORRIDOR_ON_TIME_INDEX,
    NIGHT_LIGHT_RGB_INDEX,
    ARMING_TIME_INDEX,
    DOORBELL_PUSH_INDEX,
    ARMING_DELAY_INDEX,
    GATEWAY_PROP_COUNTs,
} Gateway_Prop_Id;


typedef enum : NSUInteger {
    ARMING_PRO_REDFLASH,//网关警戒是否闪灯
    ARMING_PRO_ALARMDURATION,//警报时长
    ARMING_PRO_FM_LOW_RATE,//FM码率
} ARMING_PRO_ID;

typedef enum : NSInteger {
    BellGroup_Alarm,
    BellGroup_Door,
    BellGroup_Welcome,
} BellGroup;

typedef enum : NSUInteger{
    NightLightColorSences_Romantic,
    NightLightColorSences_Pink,
    NightLightColorSences_Golden,
    NightLightColorSences_MoonWhite,
    NightLightColorSences_Forest,
    NightLightColorSences_CharmBlue,
}NightLightColorSences;

#define kSELECTEDMUSIC @"SELECTEDMUSIC"

#define kMAXDEVICESPROPCOUNT 14

//多功能网关

@interface MHDeviceGateway : MHDeviceGatewayBase

@property (nonatomic, copy) NSString* corridor_light;   //是否允许开启路灯功能
@property (nonatomic, assign) NSInteger corridor_on_time;   //路灯被触发时的亮灯时间
@property (nonatomic, assign) NSInteger rgb;   //网关当前的亮度和颜色值
@property (nonatomic, assign) NSInteger night_light_rgb;   //夜灯亮灯时的亮度和颜色值
@property (nonatomic, assign) NSInteger corridor_light_rgb;   //路灯亮灯时的亮度和颜色值
@property (nonatomic, copy) NSString* mute;   //静音状态
@property (nonatomic, assign) NSInteger illumination;   //光照强度，只读
@property (nonatomic, copy) NSString* arming;   //布防状态：开/关/启动中(一分钟)
@property (nonatomic, assign) BOOL isShowAlarmDelay;   //是否支持自定义延时警戒
@property (nonatomic, assign) int arming_delay;  //延时警戒时间
@property (nonatomic, assign) NSUInteger arming_time;   //上次改变布防状态的时间，只读
@property (nonatomic, assign) NSInteger volume;   //网关播放声音时的音量(已弃用，为兼容老固件，保留)
@property (nonatomic, assign) NSInteger gateway_volume;   //系统提示音音量
@property (nonatomic, assign) NSInteger alarming_volume;   //报警音音量
@property (nonatomic, assign) NSInteger doorbell_volume;   //门铃音音量
@property (nonatomic, copy) NSString* doorbell_push;   //是否允许上报门铃响事件

@property (nonatomic, retain) NSMutableDictionary* music_list;    //铃音列表 0：报警 1：门铃 2：欢迎 9：自定义
@property (nonatomic, strong) NSMutableArray* default_music_index;     //默认的铃音编号，0：报警 1：门铃 2：欢迎 9：自定义
@property (nonatomic, copy) NSArray *downloadMusicList;   //网关下载的铃声缓存
@property (nonatomic, retain) NSArray *initialMusicList; //初始的云端音乐列表

@property (nonatomic, retain) NSMutableDictionary *alarm_clock;    //闹钟数据
@property (nonatomic, assign) int alarm_clock_hour;         //小时（0~23）
@property (nonatomic, assign) int alarm_clock_min;          //分钟（0~59）
@property (nonatomic, assign) int alarm_clock_day;          //周几（二进制）0000001=周一，0011111=周一~周五 转换成整数
@property (nonatomic, assign) int alarm_clock_music;        //音乐序号 index
@property (nonatomic, assign) int alarm_clock_enable;       //使能 0 1
@property (nonatomic, assign) NSInteger clock_volume;       //闹钟音量（0~100）
@property (nonatomic, retain) MHDataDeviceTimer *alarm_clock_timer; //闹钟timer
@property (nonatomic, assign) int alarm_clock_duration;     //闹钟时长

@property (nonatomic,assign) NSInteger current_program;     //当前节目在频道里面的id
@property (nonatomic,assign) NSInteger current_type;        //当前节目的type，0表示live，1表示点播
@property (nonatomic,assign) NSInteger fm_volume;           //0~100,当前volume值，100声音最大,0静音
@property (nonatomic,assign) NSInteger current_status;      //正在播放或暂停
@property (nonatomic,assign) NSInteger current_sub;         //当前点播节目的声音id，直播时为无效属性
@property (nonatomic,assign) NSInteger current_duration;    //当前点播节目的声音总时长，单位为秒，直播时为无效属性
@property (nonatomic,assign) NSInteger current_progress;    //当前点播已播放时长，单位为秒，直播时为无效属性
@property (nonatomic,assign) NSInteger current_player;      //当前播放节目，０表示直播，１表示airplay,2表示点播

@property (nonatomic, copy) NSArray<MHDataScene *> *systemSceneList;


- (void)initPropertiesFromGateway:(MHDeviceGateway*)gateway;

+ (NSString* )getLogDetailString:(MHDataGatewayLog* )log;

- (NSDictionary* )requestJsonDictionaryPayloadWithMethodName:(NSString* )method value:(NSDictionary *)value;

#pragma mark - 子设备
- (MHDevice*)getSubDevice:(NSString* )sid;
- (MHDeviceGatewayBase* )getFirstMotionDevice;
- (MHDeviceGatewayBase* )getFirstMagnetDevice;
- (MHDeviceGatewayBase* )getFirstSwitchDevice;

#pragma mark - 属性设置
- (void)setProperty:(Gateway_Prop_Id)propId
              value:(id)value success:(void (^)(id))success
            failure:(void (^)(NSError *))failure;

- (void)getProperty:(Gateway_Prop_Id)propId
            success:(void (^)(id))success
            failure:(void (^)(NSError *))failure;

#pragma mark - get_device_prop/set_device_prop相关属性
- (void)setDeviceProp:(ARMING_PRO_ID)propId
                value:(id)value
              success:(void (^)(id respObj))success
              failure:(void (^)(NSError *))failure;
- (void)getDeviceProp:(ARMING_PRO_ID)propId
             allValue:(BOOL)isAll
              success:(void (^)(id))success
              failure:(void (^)(NSError *error))failure;

/**
 *  一次拉取多个设备属性,目前支持单火,插座,温湿度
 *
 *  @param devices 拉取属性的设备,只拉去开关状态的情况下,一次最多不超过14个(网关通信每次数据的长度不能超过750)
 *  @param success {"result":[["on","off"],[6365,2814],[]],"id":11}
 *  @param failure failure
 */
- (void)gePropDevices:(NSArray *)devices success:(SucceedBlock)success
                     failure:(FailedBlock)failure;


#pragma mark - 开始、停止组网
- (void)startZigbeeJoinWithSuccess:(void (^)(id))success
                           failure:(void (^)(NSError *))failure;
- (void)stopZigbeeJoinWithSuccess:(void (^)(id))success
                          failure:(void (^)(NSError *))failure;
- (void)removeSubDevice:(NSString* )sid
                success:(void (^)(id))success
                failure:(void (^)(NSError *))failure;

#pragma mark - 音乐列表(旧网关)
- (void)getMusicListOfGroup:(NSInteger)idx
                    success:(void (^)(id))success
                    failure:(void (^)(NSError *))failure;
- (void)getDefaultMusicOfGroup:(NSInteger)idx
                       success:(void (^)(id))success
                       failure:(void (^)(NSError *))failure;
- (void)setDefaultMusicOfGroup:(NSInteger)idx
                       success:(void (^)(id))success
                       failure:(void (^)(NSError *))failure;
- (void)playMusicOfIndex:(NSInteger)idx;

#pragma mark - 用户自定义音乐列表
- (void)getCloudUserMusicListWithSuccess:(void (^)(id))success
                                 failure:(void (^)(NSError *))failure;
- (void)getMusicFreespaceSuccess:(void (^)(id))success
                         failure:(void (^)(NSError *))failure;
- (void)downloadUserMusicWithMid:(NSString*) musicName
                             url:(NSString*)musicUrl
                         success:(void (^)(id))success
                         failure:(void (^)(NSError *))failure;
- (void)deleteUserMusicWithMid:(NSString*)mid
                       success:(void (^)(id))success
                       failure:(void (^)(NSError *))failure;
- (void)playMusicWithMid:(NSString*)mid
                  volume:(NSInteger)vol
                 Success:(void (^)(id))success
                 failure:(void (^)(NSError *))failure;
- (void)setDefaultSoundWithGroup:(NSInteger)group
                         musicId:(NSString*)mid
                         Success:(void (^)(id))success
                         failure:(void (^)(NSError *))failure;
- (void)getDefaultSoundWithGroup:(NSInteger)group
                         Success:(void (^)(id))success
                         failure:(void (^)(NSError *))failure;
- (void)getMusicInfoWithGroup:(NSInteger)group
                      Success:(void (^)(id))success
                      failure:(void (^)(NSError *))failure;

- (void)fetchGatewayDownloadList;
- (NSArray *)restoreGatewayDownloadList;
- (NSString *)fetchGwDownloadMidName:(NSString *)mid;
- (NSString *)fetchGwDownloadTime:(NSString *)mid;

- (void)getDownloadMusicProgressWithSuccess:(SucceedBlock)success
                                    failure:(FailedBlock)failure ;

#pragma mark - FM
//method --- @"on" @"off" @"toggle" @"prev" @"next"
- (void)playRadioWithMethod:(NSString *)method
                 andSuccess:(SucceedBlock)success
                 andFailure:(FailedBlock)failure ;

- (void)playSpecifyRadioWithProgramID:(NSInteger)programID
                                  Url:(NSString *)url
                                 Type:(NSString *)type
                           andSuccess:(SucceedBlock)success
                           andFailure:(FailedBlock)failure;
//试听不同音量的，特定电台（在自动化中选择用到）
- (void)playSpecifyRadioForTryVolume:(NSInteger)programID
                              volume:(NSInteger)volume
                         withSuccess:(SucceedBlock)success
                             failure:(FailedBlock)failure;

- (void)radioVolumeControlWithDirection:(NSString *)direction
                                  Value:(NSInteger)value
                             andSuccess:(SucceedBlock)success
                             andFailure:(FailedBlock)failure;

- (void)setGatewayFMCollection:(NSArray *)radioList
                   withSuccess:(SucceedBlock)success
                    andFailure:(FailedBlock)failure ;

- (void)addChannels:(NSArray *)chs
     withCompletion:(void (^) (id obj))completion ;

- (void)removeChannels:(NSArray *)chs
        withCompletion:(void (^)(id obj))completion ;

- (void)fetchGatewayFMChannels:(NSInteger)startIndex
                   withSuccess:(SucceedBlock)success
                       failure:(FailedBlock)failure ;

- (void)fetchRadioDeviceStatusWithSuccess:(SucceedBlock)success
                               andFailure:(FailedBlock)failure;

#pragma mark - 联动
- (void)getBindListOfSensorsWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure;
- (void)getBindPageWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure;
/**
 * @brief 为自动化record生成extra字段，给record中的triggers和actions设置后返回
 */
- (void)prepareExtraValueForIFTRecord:(MHDataIFTTTRecord *)record
                           completion:(void (^)(MHDataIFTTTRecord *editedRecord))completion;

#pragma mark - 取消警报
- (void)disAlarmWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure;

#pragma mark - 取消播放铃音
- (void)setSoundPlaying:(NSString*)on success:(void (^)(id))success failure:(void (^)(NSError *))failure;
+ (NSString* )getBellNameOfGroup:(BellGroup)group index:(NSInteger)index;

#pragma mark - 获取所有设置感应夜灯开关的人体传感器的名称
- (NSString* )hasOpenNightLightMotionNames;

#pragma mark - 获取timer
- (NSString *)hasOpenNightLightTimer:(NSString *)title;
- (MHDataDeviceTimer *)hasOpenNightLightTimer;
- (void)removeOldTimerWithIdentify:(NSString *)identify
                     andTimerArray:(NSArray *)array;
//fm关机timer(保持一个)
- (void)addFMCloseNewTimer:(NSInteger)minutes WithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure ;
- (MHDataDeviceTimer *)hasFMCloseTimer;
- (void)deleteFMCloseTimerWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure ;

#pragma mark - 闹钟相关接口
- (void)getAlarmClockData:(SucceedBlock)success
                  failure:(FailedBlock)failure;
- (void)setAlarmClockDataWithEnable:(SucceedBlock)success
                            failure:(FailedBlock)failure ;
- (NSString *)parseDayValue:(int)day timer:(MHDataDeviceTimer *)timer;
- (void)parseDeviceValue:(id)dic;
- (void)saveClockStatus;
- (id)restoreClockStatus;

/**
 *  V3网关设置闹钟响铃时长
 *
 *  @param minute  分钟
 *  @param success success description
 *  @param failure failure description
 */
- (void)setClockAlarmTimeSpan:(int)minute Success:(SucceedBlock)success andFailure:(FailedBlock)failure;

#pragma mark - 设置色彩，获取色彩
- (void)setNightLightWithRGBA:(NightLightColorSences)rgba;
- (BOOL)getCurrentNightLightRGBACompareWith:(NightLightColorSences)rgba;
- (UIColor *)setBackgroundViewRGBA:(NightLightColorSences)rgba;

#pragma mark - 获取是否可以添加子设备的设备
/**
 *  
 *
 *  @param model 子设备model
 *
 *  @return 支持添加该子设备的网关model列表
 */
- (NSArray *)gatewayModelsWithSubdeviceModel:(NSString *)model;
- (void)getCanAddSubDevice ;
- (void)getPublicCanAddSubDevice;

- (void)getShareUserListSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure;


#pragma mark - 判断网关固件
- (void)versionControl:(void (^)(NSInteger retcode))hardwareUpdate;

#pragma mark - 判断是否需要建立默认联动
- (void)getLumiBlindWithSuccess:(void (^)(NSInteger retcode))success failure:(void(^)(NSError *))failre;

#pragma mark - 判断是否为网关300以上的网关，（即除了网关200这些旧网关)
- (BOOL)laterV3Gateway;
@end
