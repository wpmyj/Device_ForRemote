//
//  MHLMLogKeyMap.m
//  MiHome
//
//  Created by Lynn on 2/1/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLMLogKeyMap.h"
#import "MHDeviceGatewayBase.h"

@implementation MHLMLogKeyMap

+ (NSString *)LMDeviceLogKeyMap:(NSString *)currentString log:(MHDataGatewayLog *)log {
    NSString *stringDetail = [NSString stringWithFormat:@"%@" ,currentString];
    
    if ([log.type isEqualToString:Gateway_Event] ) {
        if ([log.key isEqualToString:Gateway_Event_Motion_Motion]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.motion.motion",@"plugin_gateway","有人经过")];
        } else if ([log.key isEqualToString:Gateway_Event_Magnet_Open]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.magnet.open",@"plugin_gateway","门窗打开")];
        } else if ([log.key isEqualToString:Gateway_Event_Magnet_Close]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.magnet.close",@"plugin_gateway","门窗关闭")];
        } else if ([log.key isEqualToString:Gateway_Event_Magnet_No_Close]) {
            return nil;
        } else if ([log.key isEqualToString:Gateway_Event_Switch_Click]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.switch.click.once",@"plugin_gateway","单击")];
        } else if ([log.key isEqualToString:Gateway_Event_Switch_Double_Click]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.switch.click.twice",@"plugin_gateway","双击")];
        }
        else if ([log.key isEqualToString:Gateway_Event_Switch_Long_click_Press]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.switch.click.long.press",@"plugin_gateway","长按")];
        }
        //警戒日志
        else if ([log.key isEqualToString:Araming_Event_Magnet_Open]) {
            if (!log.deviceName) {
                log.deviceName = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.magnet",@"plugin_gateway","");
            }
            stringDetail = [stringDetail stringByAppendingString:[NSString stringWithFormat:@"%@ %@", log.deviceName,NSLocalizedStringFromTable(@"mydevice.gateway.arming.magnet.open",@"plugin_gateway","按键两次")]];
        }else if ([log.key isEqualToString:Araming_Event_Motion_Motion]) {
            if (!log.deviceName) {
                log.deviceName = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.motion",@"plugin_gateway","人体传感器");
            }
            stringDetail = [stringDetail stringByAppendingString:[NSString stringWithFormat:@"%@ %@", log.deviceName,NSLocalizedStringFromTable(@"mydevice.gateway.arming.motion.motion",@"plugin_gateway","按键两次")]];
        }else if ([log.key isEqualToString:Araming_Event_Switch_Click]) {
            if (!log.deviceName) {
                log.deviceName = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.switch",@"plugin_gateway","");
            }
            stringDetail = [stringDetail stringByAppendingString:[NSString stringWithFormat:@"%@ %@", log.deviceName,NSLocalizedStringFromTable(@"mydevice.gateway.arming.switch.click",@"plugin_gateway","按键两次")]];
        }
        else if ([log.key isEqualToString:Araming_Event_Cube_Alert]) {
            NSLog(@"%@", log.deviceClass);
            NSLog(@"%@", log.did);
            if (!log.deviceName) {
                log.deviceName = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.cube",@"plugin_gateway","");
            }
            stringDetail = [stringDetail stringByAppendingString:[NSString stringWithFormat:@"%@ %@", log.deviceName, NSLocalizedStringFromTable(@"mydevice.gateway.arming.cube.alert",@"plugin_gateway","按键两次")]];
        }

        
        //魔方
        else if ([log.key isEqualToString:Gateway_Event_Cube_flip90]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.cube.flip90",@"plugin_gateway","90")];
        }else if ([log.key isEqualToString:Gateway_Event_Cube_flip180]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.cube.flip180",@"plugin_gateway","180")];
        }else if ([log.key isEqualToString:Gateway_Event_Cube_move]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.cube.move",@"plugin_gateway","move")];
        }else if ([log.key isEqualToString:Gateway_Event_Cube_tap_twice]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.cube.tap_twice",@"plugin_gateway","tap")];
        }else if ([log.key isEqualToString:Gateway_Event_Cube_shakeair]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.cube.shake_air",@"plugin_gateway","shake")];
        }else if ([log.key isEqualToString:Gateway_Event_Cube_rotate]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.cube.rotate",@"plugin_gateway","rotate")];
        }
        
        
        
        //插座
        else if ([log.key isEqualToString:Gateway_Event_Plug_Change]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.plug.changed",@"plugin_gateway","change")];
        }
        
        //温湿度
        else if ([log.key isEqualToString:Gateway_Event_HT_dry_cold]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.drycold",@"plugin_gateway","dry cold")];
        }
        else if ([log.key isEqualToString:Gateway_Event_HT_humid_cold]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.humidcold",@"plugin_gateway","humid cold")];
        }
        else if ([log.key isEqualToString:Gateway_Event_HT_cold]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.cold",@"plugin_gateway","cold")];
        }
        else if ([log.key isEqualToString:Gateway_Event_HT_dry]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.dry",@"plugin_gateway","dry")];
        }
        else if ([log.key isEqualToString:Gateway_Event_HT_comfortable]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.comfortable",@"plugin_gateway","comfortable")];
        }
        else if ([log.key isEqualToString:Gateway_Event_HT_humid]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.humid",@"plugin_gateway","humid")];
        }
        else if ([log.key isEqualToString:Gateway_Event_HT_dry_hot]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.dryhot",@"plugin_gateway","dry hot")];
        }
        else if ([log.key isEqualToString:Gateway_Event_HT_humid_hot]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.humidhot",@"plugin_gateway","humid hot")];
        }
        
        //86单键无线开关
        else if ([log.key isEqualToString:Gateway_Event_SingleSwitch_click]
                 && [log.deviceClass isEqualToString:@"MHDeviceGatewaySensorSingleSwitch"]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.86switchV1.click",@"plugin_gateway","单击")];
        }
        else if ([log.key isEqualToString:Gateway_Event_SingleSwitch_double_click]
                 && [log.deviceClass isEqualToString:@"MHDeviceGatewaySensorSingleSwitch"]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.86switchV1.doubleClick",@"plugin_gateway","双击")];
        }
        
        //86双键无线开关
        else if ([log.key isEqualToString:Gateway_Event_DoubleSwitch_click_ch0]
                 && [log.deviceClass isEqualToString:@"MHDeviceGatewaySensorDoubleSwitch"]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.86switchV2.leftClick",@"plugin_gateway","左键单击")];
        }
        else if ([log.key isEqualToString:Gateway_Event_DoubleSwitch_double_click_ch0]
                  && [log.deviceClass isEqualToString:@"MHDeviceGatewaySensorDoubleSwitch"]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.86switchV2.leftDoubleClick",@"plugin_gateway","左键双击")];
        }
        else if ([log.key isEqualToString:Gateway_Event_DoubleSwitch_click_ch1]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.86switchV2.rightClick",@"plugin_gateway","右键单击")];
        }
        else if ([log.key isEqualToString:Gateway_Event_DoubleSwitch_double_click_ch1]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.86switchV2.rightdoubleClick",@"plugin_gateway","右键双击")];
        }
        else if ([log.key isEqualToString:Gateway_Event_DoubleSwitch_both_click]) {
            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.86switchV2.leftAndRightClick",@"plugin_gateway","左右同时按下")];
        }
        else if ([log.key isEqualToString:Gateway_Event_Smoke_Alarm]) {
//            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.86plugV2.rightdoubleClick",@"plugin_gateway","右键双击")];
            stringDetail = [stringDetail stringByAppendingString:[MHLMLogKeyMap LMNatgasAndSmokeValueText:log.value]];

        }
        else if ([log.key isEqualToString:Gateway_Event_Smoke_Self_Check]) {
//            stringDetail = [stringDetail stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.gateway.log.86plugV2.leftAndRightClick",@"plugin_gateway","左右同时按下")];
            stringDetail = [stringDetail stringByAppendingString:[MHLMLogKeyMap LMNatgasAndSmokeValueText:log.value]];
        }

    }
    
    return stringDetail;
}


+ (NSString *)LMNatgasAndSmokeValueText:(NSString *)value {
    NSString *text = @"未知日志";
    if ([value isEqualToString:@"[0]"]) {
        text = NSLocalizedStringFromTable(@"mydevice.gateway.log.smoke.disalarm",@"plugin_gateway","工作正常");
    }
    if ([value isEqualToString:@"[1]"]) {
        text = NSLocalizedStringFromTable(@"mydevice.gateway.log.somke.fire.alarm",@"plugin_gateway","触发报警");
    }

    if ([value isEqualToString:@"[2]"]) {
        text = NSLocalizedStringFromTable(@"mydevice.gateway.log.smoke.analog.alarm",@"plugin_gateway","模拟报警");
    }
    if ([value isEqualToString:@"[8]"]) {
        text = NSLocalizedStringFromTable(@"mydevice.gateway.log.smoke.lowpower",@"plugin_gateway","电池电量低");
    }
    if ([value isEqualToString:@"[64]"]) {
        text = NSLocalizedStringFromTable(@"mydevice.gateway.log.smoke.sensitivity",@"plugin_gateway","灵敏度故障报警");
    }
    if ([value isEqualToString:@"[32768]"]) {
        text = NSLocalizedStringFromTable(@"mydevice.gateway.log.smoke.IICCommunicationFailure",@"plugin_gateway","IIC通信故障");
    }
    if ([value isEqualToString:@"[]"]) {
        text = NSLocalizedStringFromTable(@"mydevice.gateway.log.smoke.selfcheak",@"plugin_gateway","自检成功");
    }
    return text;
}


+ (NSString *)LMGatewayMusicNameMapWithGroup:(BellGroup)group index:(NSInteger)index {
    if (group == BellGroup_Alarm) {
        switch (index) {
            case 0:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.tone.name1",@"plugin_gateway","警车音1");
            case 1:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.tone.name2",@"plugin_gateway","警车音2");
            case 2:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.tone.name3",@"plugin_gateway","安全事故音");
            case 3:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.tone.name4",@"plugin_gateway","导弹倒计时");
            case 4:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.tone.name5",@"plugin_gateway","鬼叫声");
            case 5:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.tone.name6",@"plugin_gateway","狙击枪");
            case 6:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.tone.name7",@"plugin_gateway","激战声");
            case 7:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.tone.name8",@"plugin_gateway","空袭警报");
            case 8:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.tone.name9",@"plugin_gateway","狗叫声");
            default:
                return [NSString stringWithFormat:@"%@%d", NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.name",@"plugin_gateway","警报音"), (int)index+1];
        }
    } else if (group == BellGroup_Door) {
        switch (index) {
            case 0:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.click.tone1",@"plugin_gateway","门铃音");
            case 1:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.click.tone2",@"plugin_gateway","敲门音");
            case 2:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.click.tone3",@"plugin_gateway","搞笑音");
            case 3:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.click.tone4",@"plugin_gateway","闹钟音");
            case 4:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.click.tone5",@"plugin_gateway","闹钟音");
            case 5:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.click.tone6",@"plugin_gateway","闹钟音");
            case 6:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.click.tone7",@"plugin_gateway","闹钟音");
            case 7:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.click.tone8",@"plugin_gateway","闹钟音");
            default:
                return [NSString stringWithFormat:@"%@%d", NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.name",@"plugin_gateway","门铃音"), (int)index+1];
        }
    } else if (group == BellGroup_Welcome) {
        switch (index) {
            case 0:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.doubleclick.tone1",@"plugin_gateway","");
            case 1:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.doubleclick.tone2",@"plugin_gateway","");
            case 2:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.doubleclick.tone3",@"plugin_gateway","");
            case 3:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.doubleclick.tone4",@"plugin_gateway","");
            case 4:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.doubleclick.tone5",@"plugin_gateway","");
            case 5:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.doubleclick.tone6",@"plugin_gateway","");
            case 6:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.doubleclick.tone7",@"plugin_gateway","");
            case 7:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.doubleclick.tone8",@"plugin_gateway","");
            case 8:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.doubleclick.tone9",@"plugin_gateway","");
            case 9:
                return NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.doubleclick.tone10",@"plugin_gateway","");
            default:
                return [NSString stringWithFormat:@"%@%d", NSLocalizedStringFromTable(@"mydevice.gateway.setting.welcomebell.name",@"plugin_gateway","欢迎音"), (int)index+1];
        }
    }
    return nil;
}

@end
