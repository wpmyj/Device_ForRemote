//
//  MHDeviceAcpartner.h
//  MiHome
//
//  Created by guhao on 16/5/9.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHDeviceGateway.h"
#import "NonACManager.h"
#import "IRConstants.h"
#import "KKACManager.h"
#import <MiHomeKit/MHPlistCacheEngine.h>

typedef enum : NSInteger {
    POWER_ON_INDEX,//开
    POWER_OFF_INDEX,//关
    MODE_INDEX,//模式
    TEMP_PLUS_INDEX,//加温度
    TEMP_LESS_INDEX,//减温度
    SLEEP_INDEX,//睡眠
    TIMER_INDEX,//定时
    SWING_INDEX,//摆风
    FAN_SPEED_INDEX,//风速
    TOGGLE_INDEX,//toggle
    SCAN_INDEX,//扫描
    STAY_INDEX,//保持当前开关状态
    SCENE_ON_INDEX,//场景
    SCENE_OFF_INDEX,//场景
    SCENE_TOGGLE_INDEX,//场景
    SCENE_AC_INDEX,//场景开到指定状态
    SPCIACL_ON_INDEX,
    SPCIACL_OFF_INDEX,
    CUSTOM_FUNCTION_INDEX,//学习按键
    EXTRA_FUNCTION_INDEX,//高级SDK扩展键
    SPEED_COOL_INDEX,//速冷
} ACPARTNER_NON_PULSE_Id;

typedef NS_ENUM(NSInteger, ACPARTNER_COMMAND_Id) {
    POWER_COMMAND,//电源
    MODE_COMMAND,//模式
    TEMP_PLUS_COMMAND,//加温度
    TEMP_LESS_COMMAND,//减温度
    SLEEP_COMMAND,//睡眠
    TIMER_COMMAND,//定时
    SWING_COMMAND,//摆风
    FAN_SPEED_COMMAND,//风速
    LED_COMMAND,//LED
    COOL_COMMAND,//制冷
    HEAT_COMMAND,//制热
    dehumidify_COMMAND,//除湿
    UD_WIND_MODE_SWING_COMMAND,//上下摆风
    UD_WIND_MODE_FIX_COMMAND,//上下定风
    UD_WIND_MODE_COMMAND,//上下风向
    LR_WIND_MODE_COMMAND,//左右风向
    WIND_SPEED, //风量
    WIND_DIRECTION_COMMAND,//风向
};


typedef enum : NSInteger {
    AC_POWER_ID,//功率
 
} ACPARTNER_DEVICE_PROP_Id;
typedef enum : NSInteger {
    AC_STATE_ON,//开
    AC_STATE_OFF,//关
    AC_STATE_UNKNOW,//状态未知

} ACPARTNER_POWER_STATE;

typedef enum : NSInteger {
    PROP_TIMER,//场景
    PROP_POWER,//电源模式
    PROP_CHANGEIR,//电源模式
} ACPARTNER_PROP_TYPE;

#define kACTYPELISTKEY @"ACTYPELIST"
#define kHASSCANED     [NSString stringWithFormat:@"HASSCANED%@",[MHPassportManager sharedSingleton].currentAccount.userId]


#define ACDATAKEY                            @"ir_plan"
#define ACDATAINDEXKEY                       @"ir_plan_index"

#define kUNKNOWSTATE                         @"unknowState"
#define kCERTAINSTATE                        @"certainState"

#define kNONACMODEL                          @"010000000000000000000000"
#define kOFFCOMMAND                          @"0fffff00"


#define kACPARTNERTIMERID                   @"lumi_acpartner_timer"
#define kACPARTNERSLEEPTIMERID              @"lumi_acpartner_sleep_mode_timer"
#define kACPARTNERCOUNTDOWNTIMERID          @"lumi_acpartner_count_down_timer"
#define kAcpartnerCustomRemoteKeystring     @"lumi_acpartner_customFunction_remote"
#define kACNameKey                          @"name"
#define kACShortCmdKey                      @"shortCmd"
#define kACCmdKey                           @"cmd"

#define AddRemoteNotiName                     @"addRemoteNotification"
#define CancleAutoMatch                       @"lumi_cancleAutoMatch"

extern NSArray *modeArray;
extern NSArray *windPowerArray;

//空调伴侣
@interface MHDeviceAcpartner : MHDeviceGateway

@property (nonatomic, retain) NSMutableArray *acTypeList;
@property (nonatomic, retain) NSMutableArray *codeList;
@property (nonatomic, assign) NSInteger usableCodeIndex;
@property (nonatomic, assign) NSInteger currentCodeIndex;
@property (nonatomic, retain) NSMutableArray *cmdMapList;
@property (nonatomic, retain) NSMutableArray *historyList;


@property (nonatomic, copy) NSDictionary *ACDataSource;//红外码库
@property (nonatomic, copy) NSString *ACRemoteId;//remoteid
@property (nonatomic, copy) NSString *apikey;
@property (nonatomic, copy) NSString *ACModel;//空调模型
@property (nonatomic, copy) NSString *ACCommand;//控制信息
@property (nonatomic, assign) NSUInteger brand_id;//品牌id
@property (nonatomic, copy) NSString *ACBrand;//品牌
@property (nonatomic, assign) int number;
@property (nonatomic, assign) NSInteger ACVersion;//暂时为1
@property (nonatomic, assign) int ACType;//类型 1.无状态 2.有状态 3.协议码
@property (nonatomic, copy) NSString *unknowState;//不缺定开关状态

//无状态 type = 1
@property (nonatomic, strong) NSMutableArray *pulseArray;
@property (nonatomic, copy) NSString *power;//开关状态
@property (nonatomic, retain) NSMutableArray *nonCodeList;
@property (nonatomic, retain) NSMutableArray *remoteNameList;


//有状态 /type = 2
@property (nonatomic, strong) KKACManager *kkAcManager;
@property (nonatomic, assign) int modeState;//模式
@property (nonatomic, assign) int powerState;//开关状态
@property (nonatomic, assign) int temperature;//温度
@property (nonatomic, assign) int windDirection;//风向
@property (nonatomic, assign) int windState;//风的状态（扫风／固定风）
@property (nonatomic, assign) int windPower;//风速
@property (nonatomic, assign) int ledState;//led
@property (nonatomic, retain) NSMutableArray *usableCodeList;

//定时
@property (nonatomic, assign) int timerPowerState;//开关
@property (nonatomic, assign) int timerACType;//type
@property (nonatomic, assign) int timerModeState;//模式
@property (nonatomic, assign) int timerTemperature;//温度
@property (nonatomic, assign) int timerWindDirection;//风向
@property (nonatomic, assign) int timerWindState;//风的状态（扫风／固定风）
@property (nonatomic, assign) int timerWindPower;//风速

@property (nonatomic,assign) CGFloat original_power;
@property (nonatomic,assign) CGFloat ac_power;
@property (nonatomic,assign) CGFloat pw_day;
@property (nonatomic,assign) CGFloat pw_month;
//倒计时
@property (nonatomic,strong) MHDataDeviceTimer *countDownTimer;
@property (nonatomic,assign) NSInteger pwHour;
@property (nonatomic,assign) NSInteger pwMinute;

//学习按键
@property (nonatomic, retain) NSMutableArray *customFunctionList;


- (void)registerAppAndInit;
//type为2时，设定指定状态定时，或者场景时，需要恢复kkSDK的状态
- (void)resetAcStatus;

#pragma mark - plug data
- (void)fetchPlugDataWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure;

- (void)savePlugData:(id)value andGroupType:(NSString *)groupType;

- (id)restorePlugData:(NSString *)groupType;


- (void)getACDeviceProp:(ACPARTNER_DEVICE_PROP_Id)propId
              success:(void (^)(id))success
              failure:(void (^)(NSError *error))failure;

- (void)getTimerListWithID:(NSString *)identify Success:(SucceedBlock)success failure:(FailedBlock)failure;


#pragma mark - 根据countdown timer 计算倒计时的时间长度－－ timer是按照时间执行的，倒计时显示距离现在的时间差
- (void)fetchCountDownTime:(void (^)(NSInteger hour, NSInteger minute))countDownTimer;

#pragma mark - 匹配空调
- (void)scanACType:(int)count success:(SucceedBlock)success
           failure:(FailedBlock)failure;

- (void)deployACByModel:(NSArray *)modelCmd success:(SucceedBlock)success
                failure:(FailedBlock)failure;
- (void)setACByModel:(NSString *)modelCmd success:(SucceedBlock)success
             failure:(FailedBlock)failure;
- (void)stopScanSuccess:(SucceedBlock)success failure:(FailedBlock)failure;

- (void)getScanResultSuccess:(SucceedBlock)success failure:(FailedBlock)failure;
/**
 *  手动匹配
 *
 *  @param success success description
 *  @param failure failure description
 */
- (void)manualMatchSuccess:(SucceedBlock)success
                failure:(FailedBlock)failure;
/**
 *  开始遥控匹配
 *
 *  @param params  [ @(brandid), @(time)]
 *  @param success success description
 *  @param failure failure description
 */
- (void)startRemoteMatchParams:(NSArray *)params success:(SucceedBlock)success
                       failure:(FailedBlock)failure;
/**
 *  获取遥控匹配结果
 *
 *  @param success result返回[brandid, remoteid]
 *  @param failure failure description
 */
- (void)getRemoteMatchResultSuccess:(SucceedBlock)success
                       failure:(FailedBlock)failure;
/**
 *  结束遥控器匹配
 *
 *  @param success success description
 *  @param failure failure description
 */
- (void)endRemoteMatchSuccess:(SucceedBlock)success
                            failure:(FailedBlock)failure;
/**
 *  设置匹配的结果
 *
 *  @param success success description
 *  @param failure failure description
 */
- (void)setRemoteMatchResultSuccess:(SucceedBlock)success
                            failure:(FailedBlock)failure;

#pragma mark - 学习遥控器
/**
 *  开始学习遥控器
 *
 *  @param value   学习状态持续的时间
 *  @param success success description
 *  @param failure failure description
 */
- (void)startLearnRemoteValue:(NSNumber *)value success:(SucceedBlock)success
                       failure:(FailedBlock)failure;
/**
 *  学习结果
 *
 *  @param success string
 *  @param failure failure description
 */
- (void)getLearnRemoteResultSuccess:(SucceedBlock)success
                            failure:(FailedBlock)failure;
/**
 *  结束学习
 *
 *  @param success success description
 *  @param failure failure description
 */
- (void)endLearnRemoteSuccess:(SucceedBlock)success
                      failure:(FailedBlock)failure;
/**
 *  编辑学习的遥控器按键列表
 *
 *  @param valueList array @[ @{} ]
 *  @param success   success description
 *  @param failure   failure description
 */
- (void)editLearnedRemoteList:(NSMutableArray *)valueList
                      success:(SucceedBlock)success
                      failure:(FailedBlock)failure;
/**
 *  获取学习的遥控器按键列表
 *
 *  @param success array @[ object ] object:@{ @"name":@"", @"shortCmd":@"明文", @"cmd":@"密文"}
 *  @param failure failure
 */
- (void)getLearnedRemoteListSuccess:(SucceedBlock)success
                            failure:(FailedBlock)failure;

#pragma mark - 速冷模式
/**
 *  设置速冷模式
 *
 *  @param params  [int(enable), int(time_minute) , string(ht_did)未关联传@"" ]
 *  @param success success description
 *  @param failure failure description
 */
- (void)setCoolSpeed:(NSArray *)params
             success:(SucceedBlock)success
             failure:(FailedBlock)failure;
/**
 *  获取速冷模式的状态
 *
 *  @param success [int(enable), int(time_minute) , string(ht_did)未关联则为@"" ]
 *  @param failure failure description
 */
- (void)getCoolSpeedResultSuccess:(SucceedBlock)success
                          failure:(FailedBlock)failure;
#pragma mark - 睡眠模式
/**
 *  设置睡眠模式
 *
 *  @param params  params:   [int(enable), [string(cron_table_time0)/ uint(unix_time0) , int(temperature0)] , [string(cron_table_time1)/ uint(unix_time1) , int(temperature1)] ,[string(cron_table_time2)/ uint(unix_time2) , int(temperature2)] ,[string(cron_table_time3)/ uint(unix_time3) , int(temperature3)]  ]
 *  @param success success description
 *  @param failure failure description
 */
- (void)setSleepMode:(NSArray *)params
             success:(SucceedBlock)success
             failure:(FailedBlock)failure;
- (void)getSleepModeResultSuccess:(SucceedBlock)success
                   failure:(FailedBlock)failure;

#pragma mark - 读取空调的型号和状态和功率
/**
 *  获取空调数据
 *
 *  @param success 返回三个参数[ model, status, power]
 *  @param failure failure description
 */
- (void)getACTypeAndStatusSuccess:(SucceedBlock)success
                          failure:(FailedBlock)failure;
/**
 *  解析网关数据
 *
 *  @param status 同上
 *  @param repeat yes 轮询, no 初始化
 */
- (void)handleNewStatus:(NSArray *)status isRepeat:(BOOL)repeat;

- (int)writingToShowMode:(int)writing;

/**
 *  解析明文
 *
 *  @param hexInfo     16进制明文
 *  @param decimalInfo 10进制明文
 *  @param type        场景还是正常控制
 */
- (void)analyzeHexInfo:(NSString *)hexInfo decimalInfo:(int)decimalInfo type:(ACPARTNER_PROP_TYPE)type;

#pragma mark - 控制
- (void)sendCommand:(NSString *)command success:(SucceedBlock)success
            failure:(FailedBlock)failure;
/**
 *  学习按键控制命令
 *
 *  @param code    command
 *  @param success success description
 *  @param failure failure description
 */
- (void)sendIrCode:(NSString *)code success:(SucceedBlock)success
            failure:(FailedBlock)failure;

- (BOOL)judgeModeCanControl:(ACPARTNER_PROP_TYPE)type;
/**
 *  酷控码库下更改模式后更新下空调的各项数据
 */
- (void)updateCurrentModeStatus;
- (BOOL)judgeTempratureCanControl:(ACPARTNER_PROP_TYPE)type;
- (BOOL)judgeWindsCanControl:(ACPARTNER_PROP_TYPE)type;
- (BOOL)judgeSwipCanControl:(ACPARTNER_PROP_TYPE)type;
/**
 *  是否匹配空调
 *
 *  @return return value description
 */
- (BOOL)isACMatched;

- (NSString *)generateModelWithRemoteid:(NSString *)remoteid brandid:(NSInteger)brandid;
- (NSString *)getACCommand:(ACPARTNER_NON_PULSE_Id)index commandIndex:(ACPARTNER_COMMAND_Id)commandIndex isTimer:(BOOL)isTimer;

#pragma mark - 发送场景的cmd给空调伴侣
- (void)saveCommandMap:(NSString *)command success:(SucceedBlock)success failure:(FailedBlock)failure;
- (void)getCommandMapSuccess:(SucceedBlock)success failure:(FailedBlock)failure;
- (void)updateCommandMapSuccess:(SucceedBlock)success failure:(FailedBlock)failure;
#pragma mark - 获取空调列表和红外码库zip压缩
/**
 *  空调厂商列表
 *
 *  @param success 压缩数据
 *  @param failure failure description
 */
- (void)getACTypeListSuccess:(SucceedBlock)success
           Failure:(FailedBlock)failure;
/**
 *  查询所有拥有扩展码的遥控器id
 *
 *  @param success result[ array ]
 *  @param failure failure description
 */
- (void)getExtraIrCodeListSuccess:(SucceedBlock)success
                          Failure:(FailedBlock)failure;
/**
 *  是否为扩展码
 *
 *  @return return value description
 */
- (BOOL)isExtraRemoteId;

/**
 *  获取某个厂商的红外码库
 *
 *  @param brandId brandId 厂商id
 *  @param success 压缩数据
 *  @param failure failure description
 */
- (void)getIrCodeListWithBrandId:(NSInteger)brandId Success:(SucceedBlock)success
              Failure:(FailedBlock)failure;
- (void)uploadBrandName:(NSString *)brandName andBrandType:(NSString *)brandType Success:(SucceedBlock)success failure:(FailedBlock)failure;

#pragma mark - 缓存数据
- (void)saveACStatus;
- (void)restoreACStatus;
@end
