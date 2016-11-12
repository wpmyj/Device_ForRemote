//
//  IRConstants.h
//  kookongIphone
//
//  Created by shuaiwen on 16/1/20.
//  Copyright © 2016年 shuaiwen. All rights reserved.
//

#ifndef IRConstants_h
#define IRConstants_h

#define AC_MODE_COOL  0
#define AC_MODE_HEAT  1
#define AC_MODE_AUTO  2
#define AC_MODE_FAN  3
#define AC_MODE_DRY  4

#define AC_WIND_SPEED_AUTO  0
#define AC_WIND_SPEED_LOW  1
#define AC_WIND_SPEED_MEDIUM  2
#define AC_WIND_SPEED_HIGH  3

#define AC_POWER_ON  0
#define AC_POWER_OFF  1

#define AC_UD_WIND_DIRECT_SWING  0
#define AC_LR_WIND_DIRECT_SWING  0

#define KEY_POWER  0

#define TAG_LEAD_CODE  300
#define TAG_ZERO_CODE  301
#define TAG_ONE_CODE  302
#define TAG_DELAY_CODE  303
#define TAG_FRAME_LENGTH  304
#define TAG_CODE_FORMAT  305
#define TAG_LOW_BIT_FIRST  306
#define TAG_REMOVE_TRAILER_ONE  307

#define TAG_ALG  1000
#define TAG_POWER1  1001
#define TAG_CODE_TEMPLATE  1002
#define TAG_TEMPERATURE1  1003
#define TAG_MODE1  1004
#define TAG_WIND_SPEED1  1005
#define TAG_LR_WIND_MODE1  1006
#define TAG_UD_WIND_MODE1  1007
#define TAG_CHECKSUM  1008
#define TAG_SOLO_FUNCTION  1009

#define TAG_AC_MODE_COOL_FUNCTION  1501
#define TAG_AC_MODE_HEAT_FUNCTION  1502
#define TAG_AC_MODE_AUTO_FUNCTION  1503
#define TAG_AC_MODE_FAN_FUNCTION  1504
#define TAG_AC_MODE_DRY_FUNCTION  1505
#define TAG_UD_WIND_MODE_SET  1506

#define TAG_REPEAT_COUNT  1508
#define TAG_BYTE_BIT_NUM  1509
#define TAG_CUSTOMIZED_WAVE_CODE  1510
#define TAG_CUSTOMIZED_AC_SCRIPT  1511
#define TAG_SCRIPT_LUA 1518
#define TAG_CUSTOMIZED_WAVE_CODE2 1514

#define TAG_REMOTE_PARAMS 99999

#define FUNCTION_POWER  1
#define FUNCTION_MODE  2
#define FUNCTION_TEMPERATURE_UP  3
#define FUNCTION_TEMPERATURE_DOWN  4
#define FUNCTION_WIND_SPEED  5
#define FUNCTION_UD_WIND_MODE_SWING  6
#define FUNCTION_UD_WIND_MODE_FIX  7


#pragma mark---------------------以下部分宏定义可以根据自身需求做修改-------------------
#define TEMPERATUREMIN 17//允许设定的温度的最小值
#define TEMPERATUREMAX 30//允许设定的温度的最大值
#define BUTTONTEMP1 17//温度键1 的温度值
#define BUTTONTEMP2 27//温度键2 的温度值
#define BUTTONTEMP3 20//温度键3 的温度值

//对应模式下的初始温度
//1.制冷
#define AC_MODE_COOLTEMP 26
//2.制热
#define AC_MODE_HEATTEMP 20
//3.自动
#define AC_MODE_AUTOTEMP 24
//4.送风
#define AC_MODE_FANTEMP 24
//5.除湿
#define AC_MODE_DRYTEMP 23

#define MODESTATEBUTTON_TAG 10000//模式button固定tag
 
#define WINDSTATEBUTTON_TAG 12000//风向button固定tag

#define WINDPOWERBUTTON_TAG 13000//风量button固定tag

#define TEMPERATUREBUTTON_TAG 14000//温度button固定tag
#endif /* IRConstants_h */
