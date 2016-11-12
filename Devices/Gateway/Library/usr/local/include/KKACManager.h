//
//  ModeAndValue.h
//  kookongIphone
//
//  Created by shuaiwen on 16/3/2.
//  Copyright © 2016年 shuaiwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface KKACManager : NSObject
@property(nonatomic,copy)NSString * AC_RemoteId;
@property(nonatomic,strong)NSDictionary * airDataDict;
@property(nonatomic,copy)NSString * apikey;
/**
 *  处理红外码库数据
 */
-(void)airConditionModeDataHandle;


/**
 *  非首次登陆时，将上次使用后保存的空调的所有模式及模式下的状态值传值
 *
 *  @param modesta  模式
 *  @param powersta 开关
 *  @param temp     温度
 *  @param windp    风量
 *  @param winds    风向
 *  @param isShow   是否为显示在面板的那一组值
 */
-(void)readAirConditionStateAndValueWihtModestate:(int)modesta powerState:(int)powersta temperature:(int)temp windPower:(int)windp windState:(int)winds isShowState:(BOOL)isShow;//非首次使用传状态值


/**
 *  判断温度是否可控
 *
 *  @return YES:可控，NO:不可控
 */
-(BOOL)canControlTemp;//当前模式下温度是否可控


/**
 *  判断风量是否可控
 *
 *  @return YES:可控，NO:不可控
 */
-(BOOL)canControlWindPower;//当前模式下风量是否可控


/**
 *  判断风向是否可控
 *
 *  @return YES:可控，NO:不可控
 */
-(BOOL)canControlWindState;//风向按钮是否可以点击


/**
 *  判断按钮是否可以被点击
 *
 *  @param tag 传入风向类的button的tag值
 *  @param tag 传入温度类的button的tag值
 *  @param tag 传入风向类的button的tag值
 *  @param tag 传入风量类的button的tag值
 *
 *  @return YES：表示可以点击，NO：表示不可以被点击
 */
-(BOOL)canModeStateButtonClickWithTag:(NSInteger)tag;//模式button
-(BOOL)canTemperatureButtonClickWithTag:(NSInteger)tag;//温度button
-(BOOL)canWindStateButtonClickWithTag:(NSInteger)tag;//风向button
-(BOOL)canWindPowerButtonClickWithTag:(NSInteger)tag;//风量button


/**
 *  取到当前模式
 *
 *  @return 1501：制冷，1502：制热，1503：自动，1504：送风，1505：除湿
 */
-(int)getModeState;//得到当前模式


/**
 *  取到当前模式下的风量
 *
 *  @return -1：表示风量不可控，0：自动风量，1：低风量，2：中风量，3：高风量
 */
-(int)getWindPower;//得到当前模式的风量


/**
 *  取到当前的风向
 *
 *  @return -1：表示风向不可控，0：扫风，>0：固定风向
 */
-(int)getWindState;//得到当前风向


/**
 *  取到当前温度
 *
 *  @return int类型的值
 */
-(int)getTemperature;//得到当前模式的温度


/**
 *  取到当前的开关状态
 *
 *  @return 0：打开状态，1：关闭状态
 */
-(int)getPowerState;//得到开关状态


/**
 *  点击按钮，切换值
 *
 *  @param modest 模式（在接口：-(NSArray *)getAllModeState;取到所需传入的参数）
 *  @param modest 风量（在接口：-(NSArray *)getAllWindPower;取到所需传入的参数）
 *  @param modest 温度（温度为16~30，在接口：-(NSArray *)getLackOfTemperatureArray;取到限制设定的温度值）
 *  @param modest 开关（AC_POWER_ON：打开，AC_POWER_OFF：关闭）
 *  @param modest 风向（在接口：-(NSArray *)getAllWindState;取到所需传入的参数）
 */
-(void)changeModeStateWithModeState:(int)modest;//模式
-(void)changeWindPowerWithWindpower:(int)windp;//风量
-(void)changeTemperatureWithTemperature:(int)temp;//温度
-(void)changePowerStateWithPowerstate:(int)powersta;//开关
-(void)changeWindStateWithWindState:(int)windsta;//风向


/**
 *  取到空调所有支持的模式
 *
 *  @return 1501：制冷，1502：制热，1503：自动，1504：送风，1505：除湿
 */
-(NSArray *)getAllModeState;//得到空调所拥有的所有模式


/**
 *  取到当前模式下的所有的风量
 *
 *  @return 0：自动风量，1：低风量，2：中风量，3：高风量
 */
-(NSArray *)getAllWindPower;//得到当前模式下所有的风量


/**
 *  取到空调支持的所有的风向
 *
 *  @return 0：扫风，！0：固定风向
 */
-(NSArray *)getAllWindState;//得到空调的所有的风向


/**
 *  取到当前模式下限制设定的温度值集
 *
 *  @return 得到限制设定的温度集合，在改变温度时，要避免传入限制设定的温度值
 */
-(NSArray *)getLackOfTemperatureArray;//得到当前模式下所缺少的温度


/**
 *  取到遥控器参数
 *
 *  @return 将取到的遥控器参数直接发出
 */
-(NSArray *)getParams;


/**
 *  取到按键参数
 *
 *  @return 将取到的值发送出去
 */
-(NSArray *)getAirConditionInfrared;//得到空调红外码


/**
 *  取到空调支持的所有模式，及模式下的状态值
 *
 *  @return 根据自身需求去处理这些值
 */
-(NSArray *)getAirConditionAllModeAndValue;//得到所有的模式及模式下的状态值


/**
 *  该接口用来做测试用，直接对应的状态值，然后取得红外码
 *
 *  @param powersta   开关
 *  @param modesta    模式
 *  @param windSta    风向
 *  @param windPow    风量
 *  @param temperat   温度
 *  @param functionid 按键id（IRConstants.h对每种类型的functionid有明确的标注）
 *
 *  @return 将取到的值直接发送出去
 */
-(NSArray * )getAirConditionInfraredWithPower:(int)powersta modeState:(int)modesta windState:(int)windSta windPower:(int)windPow temperature:(int)temperat functionid:(int)functionid;
@end
